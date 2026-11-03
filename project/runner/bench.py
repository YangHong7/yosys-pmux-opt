#!/usr/bin/env python3
"""Batch PMUX validation runner. Uses only the Python standard library."""

from __future__ import annotations

import argparse
import json
import os
import platform
import re
import shutil
import subprocess
import sys
import unicodedata
from datetime import datetime
from pathlib import Path
from typing import Any


PMUX_ROOT = Path(os.environ.get("PMUX_ENGINEERING_ROOT", str(Path(__file__).resolve().parent.parent.parent)))
PROJECT_ROOT = PMUX_ROOT / "project"
RUNNER_DIR = PROJECT_ROOT / "runner"
SYNTHESIS_SCRIPT = RUNNER_DIR / "synthesis.ys"
CASES_DIR = PROJECT_ROOT / "cases"
RESULT_ROOT = PROJECT_ROOT
RUNS_DIR = RESULT_ROOT / "runs"
REPORTS_DIR = RESULT_ROOT / "reports"

BASE_YOSYS = PMUX_ROOT / "yosys-v0.69-base" / "build" / "yosys.exe"
OPT_YOSYS = PMUX_ROOT / "yosys-v0.69-opt" / "build" / "yosys.exe"
PMUX_SOURCE = PMUX_ROOT / "project" / "src" / "pmux" / "pmux_opt.cc"
PMUX_PASS = "pmux_opt"
SYNTH_FAMILY = "cycloneiv"
LOGIC_CELL_TYPE = "cycloneiv_lcell_comb"
NOT_CELL_TYPES = ("$not", "$_NOT_")
LOGIC_CELL_TYPES = (LOGIC_CELL_TYPE, *NOT_CELL_TYPES)
DFF_CELL_TYPE = "dffeas"
METRIC_VERSION = "20261030_windows_batch_warmup_each_case_once_review5"

POWERSHELL = os.environ.get("PMUX_POWERSHELL", "powershell.exe")
MEASUREMENT_SCRIPT = RUNNER_DIR / "measure_yosys.ps1"
EQY_DONE_RE = re.compile(r"DONE \((PASS|FAIL|UNKNOWN), rc=(-?\d+)\)")


def now_iso() -> str:
    return datetime.now().astimezone().isoformat(timespec="seconds")


def portable_record(value: Any) -> Any:
    if isinstance(value, dict):
        return {key: portable_record(item) for key, item in value.items()}
    if isinstance(value, list):
        return [portable_record(item) for item in value]
    alias = str(PMUX_ROOT).rstrip("\\/")
    physical = os.environ.get("PMUX_PHYSICAL_ROOT", alias).rstrip("\\/")
    if isinstance(value, str) and alias.lower() != physical.lower():
        if value.lower() == alias.lower():
            return physical
        if value.lower().startswith(alias.lower() + "\\") or value.lower().startswith(alias.lower() + "/"):
            return physical + value[len(alias):]
    return value


def write_json(path: Path, value: Any) -> None:
    path.write_text(json.dumps(portable_record(value), ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def command_text(args: list[str]) -> str:
    return subprocess.list2cmdline([str(arg) for arg in args])


def command_environment(args: list[str]) -> dict[str, str]:
    env = os.environ.copy()
    if args and Path(args[0]).resolve() in (BASE_YOSYS.resolve(), OPT_YOSYS.resolve()):
        runtime = env.get("PMUX_SYNTH_RUNTIME_PATH", "")
        if runtime:
            env["PATH"] = runtime + os.pathsep + env.get("PATH", "")
        if env.get("PMUX_SYNTH_TCL_LIBRARY"):
            env["TCL_LIBRARY"] = env["PMUX_SYNTH_TCL_LIBRARY"]
    return env


class RunLogger:
    def __init__(self, path: Path) -> None:
        self.path = path
        self.path.parent.mkdir(parents=True, exist_ok=True)

    def write(self, message: str) -> None:
        with self.path.open("a", encoding="utf-8") as stream:
            stream.write(f"{now_iso()} | {message}\n")


def console_line(label: str, passed: bool, detail: str = "") -> None:
    width = sum(2 if unicodedata.east_asian_width(c) in ("W", "F") else 1 for c in label)
    title = label + " " * max(1, 30 - width)
    print(f"  {title}{'通过' if passed else '失败'}" + (f"  {detail}" if detail else ""), flush=True)


def stage_title(label: str) -> str:
    names = {"prepare": "输入检查",
             "baseline": "原版综合", "optimized": "优化版综合",
             "baseline_vs_optimized": "等价：原版与优化版",
             "rtl_vs_baseline": "等价：RTL与原版", "rtl_vs_optimized": "等价：RTL与优化版"}
    parts = label.split(":")
    title = names.get(parts[-1], parts[-1])
    if parts[0].startswith("pair") and parts[0][4:].isdigit():
        title = f"复核 {int(parts[0][4:])}/5 " + title
    return title


def run_command(args: list[str], cwd: Path, output_log: Path, logger: RunLogger, label: str, quiet: bool = False) -> int:
    output_log.parent.mkdir(parents=True, exist_ok=True)
    logger.write(f"START {label} | cwd={cwd} | command={command_text(args)}")
    with output_log.open("w", encoding="utf-8") as stream:
        stream.write(f"$ {command_text(args)}\n\n")
        stream.flush()
        completed = subprocess.run(
            args,
            cwd=cwd,
            stdout=stream,
            stderr=subprocess.STDOUT,
            text=True,
            check=False,
            env=command_environment(args),
        )
    if not quiet:
        console_line(stage_title(label), completed.returncode == 0, "" if completed.returncode == 0 else f"返回码 {completed.returncode}")
    logger.write(f"END {label} | rc={completed.returncode} | log={output_log}")
    return completed.returncode


def capture_version(args: list[str]) -> str:
    completed = subprocess.run(args, text=True, encoding="utf-8", errors="replace",
                               capture_output=True, check=False, env=command_environment(args))
    text = (completed.stdout or completed.stderr).strip()
    return text.splitlines()[0] if text else f"unavailable (rc={completed.returncode})"


def cpu_model() -> str:
    return platform.processor() or "unknown"


def unique_run_id(mode: str, case_name: str | None) -> str:
    stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    base = f"{stamp}_{mode}" if case_name is None else f"{stamp}_{mode}_{case_name}"
    candidate = base
    index = 1
    while (RUNS_DIR / candidate).exists() or (REPORTS_DIR / f"{candidate}.md").exists():
        candidate = f"{base}_{index:02d}"
        index += 1
    return candidate


def discover_cases(directory: Path = CASES_DIR) -> list[Path]:
    found = sorted(
        [path for suffix in ("*.v", "*.sv") for path in directory.glob(suffix)],
        key=lambda path: path.name.lower(),
    )
    stems: dict[str, Path] = {}
    for path in found:
        key = path.stem.lower()
        if key in stems:
            raise RuntimeError(f"duplicate case name: {stems[key].name} and {path.name}")
        stems[key] = path
    return found


def resolve_case(value: str, directory: Path = CASES_DIR) -> Path:
    cases = discover_cases(directory)
    requested = Path(value).name.lower()
    requested_stem = Path(requested).stem
    matches = [path for path in cases if path.name.lower() == requested or path.stem.lower() == requested_stem]
    if len(matches) != 1:
        available = ", ".join(path.stem for path in cases) or "<none>"
        raise RuntimeError(f"case '{value}' not found uniquely; available: {available}")
    return matches[0]


def read_measurement(path: Path) -> dict[str, Any]:
    if not path.is_file():
        return {"wall_seconds": None, "peak_memory_mb": None,
                "resource_accounting_valid": False}
    return json.loads(path.read_text(encoding="utf-8-sig"))


def cell_metrics(by_type: dict[str, int], total: int) -> dict[str, Any]:
    luts = int(by_type.get(LOGIC_CELL_TYPE, 0))
    inverters = sum(int(by_type.get(kind, 0)) for kind in NOT_CELL_TYPES)
    return {"total": total, "lut": luts, "not": inverters,
            "logic": luts + inverters, "dff": int(by_type.get(DFF_CELL_TYPE, 0)),
            "by_type": by_type}


def source_path(path: Path) -> str:
    return str(path.relative_to(PROJECT_ROOT)) if path.is_relative_to(PROJECT_ROOT) else str(path)


def efficiency_metrics(baseline: dict[str, Any], optimized: dict[str, Any]) -> dict[str, Any]:
    def overhead(field: str) -> float | None:
        base, opt = baseline.get(field), optimized.get(field)
        return 100.0 * (opt / base - 1.0) if base is not None and base > 0 and opt is not None else None
    time, memory = overhead("wall_seconds"), overhead("peak_memory_mb")
    valid = time is not None and memory is not None
    return {"time_overhead_percent": time, "memory_overhead_percent": memory,
            "metrics_available": valid,
            "time_within_5percent": valid and time <= 5.0 + 1e-9,
            "memory_within_5percent": valid and memory <= 5.0 + 1e-9,
            "full_score_conditions_met": valid and time <= 5.0 + 1e-9 and memory <= 5.0 + 1e-9,
            "any_over_15percent": valid and (time > 15.0 + 1e-9 or memory > 15.0 + 1e-9),
            "within_60s": optimized.get("wall_seconds") is not None and optimized["wall_seconds"] <= 60.0,
            "within_2gb": optimized.get("peak_memory_mb") is not None and optimized["peak_memory_mb"] <= 2048.0}


def parse_cell_metrics(path: Path) -> dict[str, Any] | None:
    if not path.exists():
        return None
    data = json.loads(path.read_text(encoding="utf-8"))
    design = data.get("design")
    if not isinstance(design, dict) or "num_cells" not in design:
        modules = data.get("modules", {})
        candidates = [module for module in modules.values() if isinstance(module, dict) and "num_cells" in module]
        if len(candidates) != 1:
            return None
        design = candidates[0]
    by_type = {
        str(name): int(count)
        for name, count in design.get("num_cells_by_type", {}).items()
    }
    return cell_metrics(by_type, int(design["num_cells"]))




def run_yosys_branch(case_root: Path, branch: str, script: Path,
                     yosys_binary: Path, logger: RunLogger, quiet: bool = False) -> dict[str, Any]:
    branch_dir = case_root / branch
    timing_dir = branch_dir / "timing"
    timing_dir.mkdir(parents=True, exist_ok=True)
    yosys_log = timing_dir / "yosys.log"
    console_log = timing_dir / "console.log"
    stderr_log = timing_dir / "stderr.log"
    wrapper_log = timing_dir / "measurement-wrapper.log"
    measurement_file = timing_dir / "measurement.json"
    args = [POWERSHELL, "-NoLogo", "-NoProfile", "-NonInteractive",
            "-ExecutionPolicy", "Bypass", "-File", str(MEASUREMENT_SCRIPT),
            "-Executable", str(yosys_binary), "-Script", str(script),
            "-YosysLog", str(yosys_log), "-StdoutLog", str(console_log),
            "-StderrLog", str(stderr_log), "-MeasurementFile", str(measurement_file),
            "-WorkingDirectory", str(branch_dir)]
    label = f"{case_root.name}:{branch}"
    rc = run_command(args, branch_dir, wrapper_log, logger, label, quiet=True)
    measurement = read_measurement(measurement_file)
    metrics = {field: measurement.get(field) for field in ("wall_seconds", "peak_memory_mb")}
    valid = (rc == 0 and measurement.get("return_code") == 0
             and measurement.get("resource_accounting_valid", False)
             and metrics["wall_seconds"] is not None and metrics["wall_seconds"] > 0
             and metrics["peak_memory_mb"] is not None and metrics["peak_memory_mb"] > 0)
    if not valid:
        logger.write(f"METRIC ERROR {label} | inspect {wrapper_log}; no value is inferred from CPU logs")
    logger.write(f"MEASURE {label} | wall={metrics['wall_seconds']}s | peak={metrics['peak_memory_mb']}MiB")
    if not quiet:
        console_line(stage_title(label), valid, sample_description(metrics))
    return {"return_code": rc, "metrics_available": valid, "metrics": metrics,
            "measurement": measurement,
            "files": {"yosys_log": str(yosys_log), "console_log": str(console_log),
                      "stderr_log": str(stderr_log), "wrapper_log": str(wrapper_log),
                      "measurement": str(measurement_file)}}


def run_eqy(case_root: Path, logger: RunLogger) -> dict[str, Any]:
    eqy_dir = case_root / "eqy"
    eqy_dir.mkdir(parents=True, exist_ok=True)
    shutil.copy2(RUNNER_DIR / "dffeas_unmap.v", eqy_dir / "dffeas_unmap.v")
    template = (RUNNER_DIR / "compare.eqy").read_text(encoding="utf-8")
    rtl_script = "read_verilog -sv input/source.v\nprep -auto-top -flatten\nmemory_map\nclk2fflogic\nopt_clean\nrename -top top\nrename -hide"
    gold_script = template.split("[gold]\n", 1)[1].split("\n[gate]", 1)[0].strip()
    checks = {
        "baseline_vs_optimized": template,
        "rtl_vs_baseline": template.replace(gold_script, rtl_script, 1).replace(
            "read_rtlil optimized/formal.rtlil", "read_rtlil baseline/formal.rtlil"),
        "rtl_vs_optimized": template.replace(gold_script, rtl_script, 1),
    }
    results = {}
    for name, config in checks.items():
        config_path = eqy_dir / f"{name}.eqy"
        config_path.write_text(config, encoding="utf-8")
        work_dir = eqy_dir / name
        output_log = eqy_dir / f"{name}.log"
        rc = run_command(["eqy", "-j", "1", "-d", work_dir.relative_to(case_root).as_posix(),
                          config_path.relative_to(case_root).as_posix()],
                         case_root, output_log, logger, f"{case_root.name}:eqy:{name}", quiet=True)
        log_text = output_log.read_text(encoding="utf-8", errors="replace")
        done = EQY_DONE_RE.findall(log_text)
        status = done[-1][0] if done else "ERROR"
        partitions = sorted(path.stem for path in (work_dir / "partitions").glob("*.json"))
        # A successful multi-partition run is deliberately NOT accepted here.
        global_ok = len(partitions) == 1 and partitions[0].endswith(".whole")
        coverage_ok = False
        if global_ok:
            partition = json.loads((work_dir / "partitions" / f"{partitions[0]}.json").read_text())["partition"]
            modules = json.loads((case_root / "baseline" / "netlist.json").read_text())["modules"]
            top = next(module for module in modules.values() if int(str(module.get("attributes", {}).get("top", "0")), 2))
            ports = top["ports"]
            expected_outputs = {name: list(range(len(port["bits"]))) for name, port in ports.items() if port["direction"] == "output"}
            coverage_ok = (partition["outbits"] == expected_outputs and not partition["crossbits"] and
                all(name in ports and ports[name]["direction"] == "input" and
                    all(0 <= bit < len(ports[name]["bits"]) for bit in bits)
                    for name, bits in partition["inbits"].items()))
        passed = (rc == 0 and bool(done) and done[-1] == ("PASS", "0") and
                  "Successfully proved designs equivalent" in log_text and global_ok and coverage_ok)
        console_line(stage_title(name), passed, "" if passed else f"状态 {status}，见日志")
        results[name] = {"status": status, "return_code": rc, "passed": passed,
                         "global_partition_check": global_ok, "whole_output_coverage": coverage_ok, "partitions": partitions,
                         "log": str(output_log)}
    passed = all(item["passed"] for item in results.values())
    return {
        "status": "PASS" if passed else "FAIL",
        "passed": passed,
        "mode": "eqy_abc9_post_whole_design_pdr",
        "checks": results,
        "log": results["baseline_vs_optimized"]["log"],
        "work_dir": str(eqy_dir),
    }


def warmup_baseline(case_root: Path, logger: RunLogger, index: int, total: int) -> dict[str, Any]:
    """One baseline run per selected case, all before any formal measurements."""
    warm_root = case_root / "warmup"
    sample_root = warm_root / "run01"
    (sample_root / "input").mkdir(parents=True)
    shutil.copy2(case_root / "input" / "source.v", sample_root / "input" / "source.v")
    sample = run_yosys_branch(sample_root, "baseline", SYNTHESIS_SCRIPT, BASE_YOSYS, logger, quiet=True)
    record = {"index": 1, "return_code": sample["return_code"],
              "metrics": sample["metrics"], "files": sample["files"],
              "metrics_available": sample["metrics_available"]}
    console_line(f"预热 {index}/{total} {case_root.name}", sample["metrics_available"], sample_description(sample["metrics"]))
    snapshot = {"passed": sample["metrics_available"], "completed": 1,
                "scope": "batch start, baseline once per selected case",
                "included_in_final_metrics": False, "runs": [record]}
    write_json(warm_root / "samples.json", snapshot)
    return snapshot


def sample_description(metrics: dict[str, Any]) -> str:
    wall, memory = metrics.get("wall_seconds"), metrics.get("peak_memory_mb")
    if wall is None or memory is None:
        return "测量失败，见原始记录"
    return f"墙钟时间 {wall*1000:10.3f} ms  峰值内存占用 {memory:8.3f} MiB"


def apply_measurement_review(case_root: Path, baseline_run: dict[str, Any],
                             optimized_run: dict[str, Any], baseline_cells: dict[str, Any],
                             optimized_cells: dict[str, Any], logger: RunLogger) -> dict[str, Any]:
    initial = {"baseline": dict(baseline_run["metrics"]),
               "optimized": dict(optimized_run["metrics"])}
    first_eff = efficiency_metrics(initial["baseline"], initial["optimized"])
    triggered = initial["baseline"]["wall_seconds"] < 1.0 and first_eff["time_overhead_percent"] > 5.0
    result = {"warmup_count": 1, "warmup_scope": "batch start, baseline once per selected case", "initial_metrics": initial,
              "small_case_definition": "initial baseline wall_seconds < 1.0",
              "review_triggered": triggered, "review_pairs": [],
              "time_selection": "initial single run", "memory_selection": "initial single-run peaks",
              "memory_policy": "conservative: choose paired peak sample with worst relative overhead"}
    print(
        f"  首测: 墙钟时间 {initial['baseline']['wall_seconds']*1000:.3f} → "
        f"{initial['optimized']['wall_seconds']*1000:.3f} ms，开销 {first_eff['time_overhead_percent']:+.2f}%；"
        f"峰值内存占用 {initial['baseline']['peak_memory_mb']:.3f} → "
        f"{initial['optimized']['peak_memory_mb']:.3f} MiB，开销 {first_eff['memory_overhead_percent']:+.2f}%",
        flush=True,
    )
    if not triggered:
        print("  时间复核: 不触发（需同时满足原版<1秒且时间开销>5%）；采用首测。", flush=True)
        return result
    print("  时间复核: 已触发，追加5组原版→优化版；时间采用5组各自均值。", flush=True)
    pairs = []
    stable = True
    for index in range(1, 6):
        root = case_root / "review" / f"pair{index:02d}"
        (root / "input").mkdir(parents=True)
        shutil.copy2(case_root / "input" / "source.v", root / "input" / "source.v")
        base = run_yosys_branch(root, "baseline", SYNTHESIS_SCRIPT, BASE_YOSYS, logger)
        opt = run_yosys_branch(root, "optimized", SYNTHESIS_SCRIPT, OPT_YOSYS, logger)
        if not base["metrics_available"] or not opt["metrics_available"]:
            result.update({"passed": False, "error": "review measurement failed"})
            return result
        pair_eff = efficiency_metrics(base["metrics"], opt["metrics"])
        print(f"  {'复核开销' + ' ' * 22}      时间 {pair_eff['time_overhead_percent']:+8.2f}%  内存 {pair_eff['memory_overhead_percent']:+8.2f}%", flush=True)
        cell_match = (parse_cell_metrics(root / "baseline" / "stat.json") == baseline_cells and
                      parse_cell_metrics(root / "optimized" / "stat.json") == optimized_cells)
        stable = stable and cell_match
        pairs.append({"index": index, "baseline": base["metrics"], "optimized": opt["metrics"],
                      "cells_unchanged": cell_match,
                      "baseline_record": base["files"]["measurement"],
                      "optimized_record": opt["files"]["measurement"]})
    write_json(case_root / "review" / "samples.json", {"pairs": pairs})
    baseline_run["metrics"]["wall_seconds"] = sum(p["baseline"]["wall_seconds"] for p in pairs) / 5
    optimized_run["metrics"]["wall_seconds"] = sum(p["optimized"]["wall_seconds"] for p in pairs) / 5
    all_pairs = [{"index": 0, **initial}, *pairs]
    worst = max(all_pairs, key=lambda p: p["optimized"]["peak_memory_mb"] / p["baseline"]["peak_memory_mb"])
    baseline_run["metrics"]["peak_memory_mb"] = worst["baseline"]["peak_memory_mb"]
    optimized_run["metrics"]["peak_memory_mb"] = worst["optimized"]["peak_memory_mb"]
    result.update({"passed": stable, "review_pairs": pairs, "stable": stable,
                   "time_selection": "ratio of separate five-review wall-time means; initial sample excluded",
                   "memory_selection": f"worst paired peak overhead among initial + review samples; pair={worst['index']}",
                   "selected_metrics": {"baseline": dict(baseline_run["metrics"]), "optimized": dict(optimized_run["metrics"])}})
    return result


def run_case(case_file: Path, run_root: Path, logger: RunLogger, warmup: dict[str, Any]) -> dict[str, Any]:
    case_name = case_file.stem
    case_root = run_root / "cases" / case_name
    input_dir = case_root / "input"
    common_dir = case_root / "common"
    baseline_dir = case_root / "baseline"
    optimized_dir = case_root / "optimized"
    for directory in (input_dir, common_dir, baseline_dir, optimized_dir):
        directory.mkdir(parents=True, exist_ok=True)
    frozen_source = input_dir / "source.v"
    if not frozen_source.is_file():
        raise RuntimeError("case input was not frozen before batch warmup")

    result: dict[str, Any] = {
        "case": case_name,
        "source": source_path(case_file),
        "status": "RUNNING",
    }

    prepare_args = [str(BASE_YOSYS), "-Q", "-d", "-l", str(common_dir / "yosys.log"),
                    "-s", str(RUNNER_DIR / "prepare.ys")]
    prepare_rc = run_command(prepare_args, common_dir, common_dir / "console.log", logger, f"{case_name}:prepare")
    result["prepare"] = {
        "return_code": prepare_rc,
        "input_cells": (
            metrics["total"]
            if (metrics := parse_cell_metrics(common_dir / "stat.json")) is not None
            else None
        ),
        "measured": False,  # Preparation is separate from graded synthesis timing.
    }
    if prepare_rc != 0 or result["prepare"]["input_cells"] is None:
        result["status"] = "PREPARE_FAIL"
        write_json(case_root / "result.json", result)
        return result

    result["warmup"] = warmup
    if not result["warmup"]["passed"]:
        result["status"] = "WARMUP_FAIL"
        write_json(case_root / "result.json", result)
        return result

    baseline_run = run_yosys_branch(case_root, "baseline", SYNTHESIS_SCRIPT, BASE_YOSYS, logger)
    optimized_run = run_yosys_branch(case_root, "optimized", SYNTHESIS_SCRIPT, OPT_YOSYS, logger)

    baseline_cells = parse_cell_metrics(baseline_dir / "stat.json")
    optimized_cells = parse_cell_metrics(optimized_dir / "stat.json")
    result["baseline"] = {"cells": baseline_cells, "run": baseline_run, "metrics": baseline_run["metrics"]}
    result["optimized"] = {"cells": optimized_cells, "run": optimized_run, "metrics": optimized_run["metrics"]}
    result["synthesis_diagnostics"] = {
        branch: re.findall(r"ABC: Error: .+", (case_root / branch / "timing" / "yosys.log").read_text(encoding="utf-8", errors="replace"))
        for branch in ("baseline", "optimized")}
    branches_ok = baseline_run["return_code"] == 0 and optimized_run["return_code"] == 0
    cells_ok = baseline_cells is not None and optimized_cells is not None
    if not branches_ok or not cells_ok:
        result["status"] = "SYNTH_FAIL"
        write_json(case_root / "result.json", result)
        return result

    if not baseline_run["metrics_available"] or not optimized_run["metrics_available"]:
        result["status"] = "METRIC_FAIL"
        write_json(case_root / "result.json", result)
        return result
    result["measurement_protocol"] = apply_measurement_review(
        case_root, baseline_run, optimized_run, baseline_cells, optimized_cells, logger)
    if result["measurement_protocol"].get("passed") is False:
        result["status"] = "REVIEW_FAIL"
        write_json(case_root / "result.json", result)
        return result
    result["efficiency"] = efficiency_metrics(baseline_run["metrics"], optimized_run["metrics"])

    baseline_logic = int(baseline_cells["logic"])
    optimized_logic = int(optimized_cells["logic"])
    reduction_cells = baseline_logic - optimized_logic
    reduction_percent = 100.0 * reduction_cells / baseline_logic if baseline_logic else None
    result["cell_reduction"] = {
        "logic_cells": reduction_cells,
        "percent": reduction_percent,
        "dff_delta": int(optimized_cells["dff"]) - int(baseline_cells["dff"]),
        "dff_nonincrease": int(optimized_cells["dff"]) <= int(baseline_cells["dff"]),
    }
    result["eqy"] = run_eqy(case_root, logger)
    other_nonincrease = all(optimized_cells["by_type"].get(kind, 0) <= baseline_cells["by_type"].get(kind, 0)
                           for kind in set(baseline_cells["by_type"]) | set(optimized_cells["by_type"])
                           if kind not in LOGIC_CELL_TYPES and kind != DFF_CELL_TYPE)
    result["cell_reduction"]["other_cells_nonincrease"] = other_nonincrease
    result["status"] = "PASS" if (result["eqy"]["passed"]
        and other_nonincrease and reduction_cells >= 0) else "VALIDATION_FAIL"
    write_json(case_root / "result.json", result)
    return result


def fmt_number(value: Any, digits: int = 2, suffix: str = "") -> str:
    if value is None:
        return "N/A"
    return f"{float(value):.{digits}f}{suffix}"


def build_summary(run_id: str, mode: str, results: list[dict[str, Any]], manifest: dict[str, Any]) -> dict[str, Any]:
    complete = [r for r in results if r.get("baseline", {}).get("cells") is not None
                and r.get("optimized", {}).get("cells") is not None]
    def total(branch: str, field: str) -> int:
        return sum(int(r[branch]["cells"][field]) for r in complete)
    def values(branch: str, field: str) -> list[float]:
        return [r[branch]["metrics"][field] for r in complete if r[branch]["metrics"].get(field) is not None]
    def efficiency_values(field: str) -> list[float]:
        return [r["efficiency"][field] for r in results if r.get("efficiency", {}).get(field) is not None]
    failed = [r["case"] for r in results if r.get("status") != "PASS"]
    valid = bool(results) and not failed
    rates = [r["cell_reduction"]["percent"] for r in complete if r.get("cell_reduction", {}).get("percent") is not None]
    base_logic, opt_logic = total("baseline", "logic"), total("optimized", "logic")
    base_wall, opt_wall = values("baseline", "wall_seconds"), values("optimized", "wall_seconds")
    base_mem, opt_mem = values("baseline", "peak_memory_mb"), values("optimized", "peak_memory_mb")
    time_overheads, mem_overheads = efficiency_values("time_overhead_percent"), efficiency_values("memory_overhead_percent")
    return {"run_id": run_id, "mode": mode, "status": "PASS" if valid else "FAIL",
            "metric_version": METRIC_VERSION, "started_at": manifest["started_at"], "finished_at": now_iso(),
            "measurements_per_branch": "one initial; conditional five-review pairs", "case_count": len(results),
            "eqy_passed": sum(bool(r.get("eqy", {}).get("passed")) for r in results),
            "failed_cases": failed,
            "eqy_failed_cases": [r["case"] for r in results if r.get("eqy") and not r["eqy"]["passed"]],
            "baseline_cells_total": total("baseline", "total"), "optimized_cells_total": total("optimized", "total"),
            "baseline_logic_cells_total": base_logic, "optimized_logic_cells_total": opt_logic,
            "baseline_lut_total": total("baseline", "lut"), "optimized_lut_total": total("optimized", "lut"),
            "baseline_not_total": total("baseline", "not"), "optimized_not_total": total("optimized", "not"),
            "baseline_dff_total": total("baseline", "dff"), "optimized_dff_total": total("optimized", "dff"),
            "average_reduction_percent": sum(rates) / len(rates) if rates else None,
            "weighted_reduction_percent": 100.0 * (base_logic - opt_logic) / base_logic if base_logic else None,
            "dff_nonincrease_all": valid and all(r["cell_reduction"]["dff_nonincrease"] for r in results),
            "other_cells_nonincrease_all": valid and all(r["cell_reduction"]["other_cells_nonincrease"] for r in results),
            "optimization_valid": valid,
            "baseline_wall_seconds_sum": sum(base_wall) if base_wall else None,
            "optimized_wall_seconds_sum": sum(opt_wall) if opt_wall else None,
            "optimized_wall_seconds_max": max(opt_wall) if opt_wall else None,
            "baseline_yosys_peak_memory_mb_max": max(base_mem) if base_mem else None,
            "optimized_yosys_peak_memory_mb_max": max(opt_mem) if opt_mem else None,
            "max_case_time_overhead_percent": max(time_overheads) if time_overheads else None,
            "max_case_memory_overhead_percent": max(mem_overheads) if mem_overheads else None,
            "efficiency_full_score_conditions_met": valid and all(r["efficiency"]["full_score_conditions_met"] for r in results),
            "cases_exceeding_5percent": [r["case"] for r in results if r.get("efficiency", {}).get("metrics_available") and not r["efficiency"]["full_score_conditions_met"]],
            "cases_exceeding_15percent": [r["case"] for r in results if r.get("efficiency", {}).get("any_over_15percent")],
            "local_limit_60s_pass": valid and all(r["efficiency"]["within_60s"] for r in results),
            "local_limit_2gb_pass": valid and all(r["efficiency"]["within_2gb"] for r in results),
            "max_input_cells": max(((r.get("prepare", {}).get("input_cells") or 0) for r in results), default=0),
            "results": results}


def efficiency_table(results: list[dict[str, Any]]) -> list[str]:
    lines = [
        "|案例|墙钟时间 原→优 ms（含ABC）|时间开销|主进程峰值内存占用 原→优 MiB|内存开销|两项均≤5%|",
        "|---|---:|---:|---:|---:|---|",
    ]
    for result in results:
        base = result.get("baseline", {}).get("metrics", {})
        opt = result.get("optimized", {}).get("metrics", {})
        efficiency = result.get("efficiency", {})
        def wall_ms(metrics: dict[str, Any]) -> str:
            value = metrics.get("wall_seconds")
            return fmt_number(value * 1000 if value is not None else None, 3)
        status = ("PASS" if efficiency.get("full_score_conditions_met") else "FAIL") if efficiency.get("metrics_available") else "N/A"
        lines.append(
            f"|{result['case']}|{wall_ms(base)}→{wall_ms(opt)}|"
            f"{fmt_number(efficiency.get('time_overhead_percent'), 2, '%')}|"
            f"{fmt_number(base.get('peak_memory_mb'), 2)}→{fmt_number(opt.get('peak_memory_mb'), 2)}|"
            f"{fmt_number(efficiency.get('memory_overhead_percent'), 2, '%')}|{status}|"
        )
    return lines


def terminal_table(headers: list[str], rows: list[list[str]],
                   left_columns: tuple[int, ...] = (0,)) -> list[str]:
    def width(text: str) -> int:
        return sum(2 if unicodedata.east_asian_width(char) in ("W", "F") else 1
                   for char in text)
    widths = [max(width(row[i]) for row in [headers, *rows])
              for i in range(len(headers))]
    def render(row: list[str]) -> str:
        cells = []
        for i, text in enumerate(row):
            space = " " * (widths[i] - width(text))
            cells.append(text + space if i in left_columns else space + text)
        return "| " + " | ".join(cells) + " |"
    return [render(headers), "|-" + "-|-".join("-" * n for n in widths) + "-|",
            *(render(row) for row in rows)]


def terminal_case_tables(results: list[dict[str, Any]]) -> list[str]:
    structure = []
    resources = []
    def count(value: Any) -> str:
        return str(value) if value is not None else "N/A"
    def pair(base: dict[str, Any], opt: dict[str, Any], key: str) -> str:
        return f"{count(base.get(key))} -> {count(opt.get(key))}"
    def wall(metrics: dict[str, Any]) -> str:
        value = metrics.get("wall_seconds")
        return fmt_number(value * 1000 if value is not None else None, 3)
    for result in results:
        base = result.get("baseline", {}).get("cells") or {}
        opt = result.get("optimized", {}).get("cells") or {}
        structure.append([
            result["case"],
            count(result.get("prepare", {}).get("input_cells")),
            pair(base, opt, "lut"), pair(base, opt, "not"), pair(base, opt, "logic"), pair(base, opt, "dff"),
            fmt_number(result.get("cell_reduction", {}).get("percent"), 2, "%"),
            result.get("eqy", {}).get("status", "N/A"),
        ])
        bm = result.get("baseline", {}).get("metrics") or {}
        om = result.get("optimized", {}).get("metrics") or {}
        ef = result.get("efficiency") or {}
        state = ("PASS" if ef.get("full_score_conditions_met") else "FAIL") if ef.get("metrics_available") else "N/A"
        resources.append([
            result["case"], f"{wall(bm)} -> {wall(om)}",
            fmt_number(ef.get("time_overhead_percent"), 2, "%"),
            f"{fmt_number(bm.get('peak_memory_mb'), 2)} -> {fmt_number(om.get('peak_memory_mb'), 2)}",
            fmt_number(ef.get("memory_overhead_percent"), 2, "%"), state,
        ])
    return [
        "电路规模（原版 -> 优化版；优化率按LUT+独立NOT计算，输入cell为Pass插入前）：",
        *terminal_table(["案例", "输入cell", "LUT", "独立NOT", "LUT+NOT", "DFF", "逻辑优化率", "EQY"],
                        structure, (0, 7)),
        "",
        "单案例效率（时间为首测或5组复核均值；内存为主进程峰值，均不含EQY）：",
        *terminal_table(["案例", "墙钟时间 ms", "时间开销", "峰值内存占用 MiB", "内存开销", "两项均≤5%"],
                        resources, (0, 5)),
    ]


def render_report(summary: dict[str, Any], manifest: dict[str, Any], run_root: Path) -> str:
    efficiency = "PASS" if summary["efficiency_full_score_conditions_met"] else "FAIL"
    lines = [
        "# PMUX 优化结果", "",
        "时间为 PowerShell Measure-Command 墙钟时间，内存为 Yosys 主进程峰值内存占用。整批正式测量前，所选案例各用原版预热一次，之后不再逐例预热；小于1秒且时间首测开销超过5%时追加5组复核，以两版各自均值计算时间开销。内存保守采用最坏配对峰值样本，全部记录保留。", "",
        f"平均优化率：**{fmt_number(summary['average_reduction_percent'], 2, '%')}**；"
        f"等价通过：**{summary['eqy_passed']}/{summary['case_count']}**；"
        f"本地效率阈值检查：**{efficiency}**。",
        "", "## 面积与等价", "",
        "|案例|状态|LUT 原→优|独立NOT 原→优|LUT+NOT 原→优|优化率|FF 原→优|EQY|",
        "|---|---|---:|---:|---:|---:|---:|---|",
    ]
    for result in summary["results"]:
        base = result.get("baseline", {}).get("cells") or {}
        opt = result.get("optimized", {}).get("cells") or {}
        lines.append(
            f"|{result['case']}|{result['status']}|{base.get('lut', 'N/A')}→{opt.get('lut', 'N/A')}|"
            f"{base.get('not', 'N/A')}→{opt.get('not', 'N/A')}|"
            f"{base.get('logic', 'N/A')}→{opt.get('logic', 'N/A')}|"
            f"{fmt_number(result.get('cell_reduction', {}).get('percent'), 2, '%')}|"
            f"{base.get('dff', 'N/A')}→{opt.get('dff', 'N/A')}|"
            f"{result.get('eqy', {}).get('status', 'NOT_RUN')}|"
        )
    lines += ["", "## 时间与内存", ""] + efficiency_table(summary["results"])
    lines += ["", "## 时间复核", "", "|案例|是否触发|已完成组数|时间取值|", "|---|---|---:|---|"]
    for item in summary["results"]:
        protocol = item.get("measurement_protocol", {})
        triggered = protocol.get("review_triggered", False)
        lines.append(f"|{item['case']}|{'是' if triggered else '否'}|{len(protocol.get('review_pairs', []))}|{'5组各自均值' if triggered else '首测'}|")
    failures = []
    for result in summary["results"]:
        if result["status"] != "PASS":
            reason = result.get("error") or result["status"]
            failures.append(f"- {result['case']}：{reason}。日志目录：{run_root / 'cases' / result['case']}")
            for name, proof in result.get("eqy", {}).get("checks", {}).items():
                if not proof["passed"]:
                    failures.append(f"- {result['case']}/{name}：{proof['status']}；日志：{proof['log']}")
        elif not result.get("efficiency", {}).get("full_score_conditions_met"):
            failures.append(f"- {result['case']}：时间或内存开销不满足逐例5%要求。")
    if failures:
        lines += ["", "## 未通过项", ""] + failures
    lines += ["", "## 逐次测量（预热不计入正式结果）", "",
              "|案例|阶段|原版 ms|优化版 ms|原版 MiB|优化版 MiB|", "|---|---|---:|---:|---:|---:|"]
    def sample_row(case, stage, base, opt):
        def value(data, key, scale=1):
            x = data.get(key)
            return f"{x*scale:.3f}" if x is not None else "—"
        return f"|{case}|{stage}|{value(base, 'wall_seconds', 1000)}|{value(opt, 'wall_seconds', 1000)}|{value(base, 'peak_memory_mb')}|{value(opt, 'peak_memory_mb')}|"
    for item in summary["results"]:
        case = item["case"]
        for sample in item.get("warmup", {}).get("runs", []):
            lines.append(sample_row(case, f"预热{sample['index']}", sample.get("metrics", {}), {}))
        protocol = item.get("measurement_protocol", {})
        first = protocol.get("initial_metrics", {})
        if first:
            lines.append(sample_row(case, "首测", first.get("baseline", {}), first.get("optimized", {})))
        for pair in protocol.get("review_pairs", []):
            lines.append(sample_row(case, f"复核{pair['index']}", pair["baseline"], pair["optimized"]))
    lines += ["", f"原始记录：{run_root}", ""]
    return "\n".join(lines)




def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run PMUX baseline/optimized equivalence benchmarks.")
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--case", help="case stem or file name from cases/")
    mode.add_argument("--all", action="store_true", help="run every .v/.sv file in cases/")
    parser.add_argument("--cases-dir", type=Path, default=CASES_DIR, help="case directory (default: project/cases; optional official pressure set)")
    mode.add_argument("--check", action="store_true", help="check the Windows environment and binaries without running cases")
    parser.add_argument("--output-dir", type=Path, default=RESULT_ROOT, help="results directory containing runs/ and reports/ (default: project/)")
    args = parser.parse_args()
    args.cases_dir = args.cases_dir.resolve()
    if not args.cases_dir.is_dir():
        parser.error("--cases-dir must be an existing directory")
    args.output_dir = args.output_dir.expanduser().resolve()
    physical_root = PMUX_ROOT.resolve()
    if args.output_dir.is_relative_to(physical_root):
        args.output_dir = PMUX_ROOT / args.output_dir.relative_to(physical_root)
    return args


def main() -> int:
    global RESULT_ROOT, RUNS_DIR, REPORTS_DIR
    args = parse_args()
    RESULT_ROOT = args.output_dir
    RUNS_DIR = RESULT_ROOT / "runs"
    REPORTS_DIR = RESULT_ROOT / "reports"
    if sys.platform != "win32":
        print("ERROR: run this entry in Windows PowerShell", file=sys.stderr)
        return 2

    required_paths = {
        "baseline Yosys": BASE_YOSYS,
        "optimized Yosys": OPT_YOSYS,
        "pmux_opt source": PMUX_SOURCE,
    }
    missing = [f"{label}: {path}" for label, path in required_paths.items() if not path.is_file()]
    if missing:
        print("ERROR: required build artifact missing:\n  " + "\n  ".join(missing), file=sys.stderr)
        return 2

    suite = Path(os.environ.get("OSS_CAD_SUITE", PMUX_ROOT / "oss-cad-suite")).resolve()
    for tool in ("eqy", "sby", "yosys", "yosys-abc"):
        actual = shutil.which(tool)
        expected = suite / "bin" / f"{tool}.exe"
        if actual is None or Path(actual).resolve() != expected.resolve():
            print(f"ERROR: formal tool must come from the configured suite: {tool}; use run_all.ps1 or run_case.ps1", file=sys.stderr)
            return 2
    if not os.environ.get("PMUX_SYNTH_RUNTIME_PATH"):
        print("ERROR: synthesis runtime environment missing; use the PowerShell entry scripts", file=sys.stderr)
        return 2

    baseline_version = capture_version([str(BASE_YOSYS), "-V"])
    optimized_version = capture_version([str(OPT_YOSYS), "-V"])
    if "Yosys 0.69" not in baseline_version or "Yosys 0.69" not in optimized_version:
        print("ERROR: both branches must use Yosys 0.69", file=sys.stderr)
        print(f"  baseline:  {baseline_version}", file=sys.stderr)
        print(f"  optimized: {optimized_version}", file=sys.stderr)
        return 2

    if not SYNTHESIS_SCRIPT.is_file():
        print("ERROR: shared synthesis script missing: synthesis.ys", file=sys.stderr)
        return 2
    missing_tools = [tool for tool in ("eqy", "sby", "yosys", "yosys-abc", "bash", "make") if not shutil.which(tool)]
    if missing_tools:
        print("ERROR: missing formal tools: " + ", ".join(missing_tools), file=sys.stderr)
        return 2
    for binary in (BASE_YOSYS, OPT_YOSYS, BASE_YOSYS.with_name("yosys-abc.exe"), OPT_YOSYS.with_name("yosys-abc.exe")):
        if not binary.is_file():
            print(f"ERROR: executable missing or not executable: {binary}", file=sys.stderr)
            return 2
        with binary.open("rb") as stream:
            if stream.read(2) != b"MZ":
                print(f"ERROR: expected a Windows PE executable: {binary}", file=sys.stderr)
                return 2
    if args.check:
        print(f"Environment: Windows ({platform.release()})")
        print(f"Baseline EXE: {portable_record(str(BASE_YOSYS))}")
        print(f"Optimized EXE: {portable_record(str(OPT_YOSYS))}")
        print("Version: Yosys 0.69 (both branches); runtime check only, no compiler required")
        print(f"Cases: {len(discover_cases(args.cases_dir))}")
        print(f"Results: {portable_record(str(RESULT_ROOT))}")
        print("CHECK PASS: binaries, formal tools and shared synthesis script are available")
        return 0

    try:
        case_files = discover_cases(args.cases_dir) if args.all else [resolve_case(args.case, args.cases_dir)]
        if not case_files:
            raise RuntimeError("no .v or .sv cases found")
    except RuntimeError as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 2

    mode = "batch" if args.all else "single"
    run_id = unique_run_id(mode, None if args.all else case_files[0].stem)
    run_root = RUNS_DIR / run_id
    run_root.mkdir(parents=True)
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)
    logger = RunLogger(run_root / "run.log")

    manifest: dict[str, Any] = {
        "run_id": run_id,
        "mode": mode,
        "started_at": now_iso(),
        "measurements_per_branch": "one initial; conditional five-review pairs",
        "metric_version": METRIC_VERSION,
        "cases_directory": str(args.cases_dir),
        "project_root": str(PROJECT_ROOT),
        "environment": {
            "python_executable": str(Path(sys.executable).resolve()),
            "python_version": platform.python_version(),
            "baseline_yosys": baseline_version,
            "optimized_yosys": optimized_version,
            "eqy": capture_version(["eqy", "--version"]),
            "formal_yosys": capture_version(["yosys", "-V"]),
            "formal_stack_patch": (
                json.loads((RUNNER_DIR / "formal_stack_patch.json").read_text(encoding="utf-8-sig"))
                if (RUNNER_DIR / "formal_stack_patch.json").is_file() else None
            ),
            "sby": capture_version(["sby", "--version"]),
            "kernel": platform.release(),
            "cpu": cpu_model(),
        },
        "binaries": {
            "baseline": {"path": str(BASE_YOSYS)},
            "optimized": {"path": str(OPT_YOSYS)},
        },
        "synthesis": {
            "command": "synth_intel",
            "family": SYNTH_FAMILY,
            "top": "auto",
            "logic_cell_metric": "final mapped stat -json: cycloneiv_lcell_comb + $not/$_NOT_",
            "time_metric": "PowerShell Measure-Command.TotalSeconds: Yosys launch through exit, including ABC wait",
            "memory_metric": "Windows GetProcessMemoryInfo.PeakWorkingSetSize, Yosys only, bytes/1048576 (MiB)",
            "efficiency_full_score": "local check: every case selected wall-time and conservative paired peak-memory overhead <=5%",
            "measurement_protocol": "batch-start baseline warmup once per selected case; baseline then optimized; if initial baseline<1s and time overhead>5%, five additional pairs, ratio of separate time means; worst paired memory sample retained",
            "memory_review_policy": "conservative engineering convention; official time-review answer does not specify averaging memory",
            "proof_top_rename": "top (alpha-renaming only, no state/input/output relaxation)",
            "dff_metric": f"final mapped stat -json num_cells_by_type[{DFF_CELL_TYPE}]",
            "equivalence_checkpoint": "baseline vs optimized after map_luts/ABC9, both before final Cyclone IV map_cells",
            "equivalence_checks": ["RTL vs baseline", "RTL vs optimized", "baseline vs optimized"],
            "equivalence_mode": "EQY, one whole-design partition, hidden internal match points, SBY ABC PDR",
        },
        "pmux_pass": {
            "source": str(PMUX_SOURCE),
            "pass": PMUX_PASS,
        },
        "cases": [
            {
                "name": case.stem,
                "path": source_path(case),
            }
            for case in case_files
        ],
    }
    write_json(run_root / "manifest.json", manifest)
    logger.write(f"RUN START | id={run_id} | mode={mode} | cases={len(case_files)} | measurements_per_branch=1")

    # Freeze all inputs and finish the entire warmup phase before measurement.
    warmups: dict[str, dict[str, Any]] = {}
    print(f"\n整批预热：所选 {len(case_files)} 个案例各运行原版一次，不计入正式指标。", flush=True)
    for case_index, case_file in enumerate(case_files, 1):
        case_root = run_root / "cases" / case_file.stem
        (case_root / "input").mkdir(parents=True, exist_ok=True)
        shutil.copy2(case_file, case_root / "input" / "source.v")
        try:
            warmups[case_file.stem] = warmup_baseline(case_root, logger, case_index, len(case_files))
        except Exception as error:
            logger.write(f"WARMUP ERROR | case={case_file.stem} | {type(error).__name__}: {error}")
            warmups[case_file.stem] = {"passed": False, "completed": 0,
                                      "included_in_final_metrics": False, "runs": [], "error": str(error)}
    manifest["warmup"] = {"scope": "batch start", "baseline_runs_per_case": 1,
                          "case_count": len(case_files), "included_in_final_metrics": False}
    write_json(run_root / "manifest.json", manifest)
    print("预热阶段完成，开始正式测试（原版→优化版）。", flush=True)

    results: list[dict[str, Any]] = []
    for case_index, case_file in enumerate(case_files, 1):
        print(f"\n[{case_index}/{len(case_files)}] {case_file.stem}", flush=True)
        try:
            results.append(run_case(case_file, run_root, logger, warmups[case_file.stem]))
        except Exception as error:  # Preserve the batch and remaining cases.
            logger.write(f"UNEXPECTED CASE ERROR | case={case_file.stem} | {type(error).__name__}: {error}")
            results.append({"case": case_file.stem, "source": source_path(case_file), "status": "RUNNER_ERROR", "error": str(error)})

    summary = build_summary(run_id, mode, results, manifest)
    manifest["finished_at"] = summary["finished_at"]
    manifest["status"] = summary["status"]
    write_json(run_root / "manifest.json", manifest)
    write_json(run_root / "summary.json", summary)
    report_path = REPORTS_DIR / f"{run_id}.md"
    report_path.write_text(render_report(portable_record(summary), portable_record(manifest), Path(portable_record(str(run_root)))), encoding="utf-8")
    logger.write(f"RUN END | status={summary['status']} | report={report_path}")

    print("=== PMUX validation summary ===")
    print(f"Mode:        {mode}")
    print(f"Status:      {summary['status']}")
    print(f"EQY:         {summary['eqy_passed']}/{summary['case_count']} PASS")
    print(f"Logic cells: {summary['baseline_logic_cells_total']} -> {summary['optimized_logic_cells_total']}")
    print(f"Avg rate:    {fmt_number(summary['average_reduction_percent'], 2, '%')}")
    print(f"DFF:         {summary['baseline_dff_total']} -> {summary['optimized_dff_total']}")
    print()
    print("\n".join(terminal_case_tables(summary["results"])))
    print("时间复核汇总：")
    for item in summary["results"]:
        protocol = item.get("measurement_protocol", {})
        if not protocol:
            detail = "未完成测量"
        elif protocol.get("review_triggered"):
            detail = f"已复核 {len(protocol.get('review_pairs', []))}/5 组；时间取复核均值，内存取最坏配对样本"
        else:
            detail = "未触发复核；采用首测时间和峰值内存"
        title = item["case"]
        width = sum(2 if unicodedata.east_asian_width(c) in ("W", "F") else 1 for c in title)
        print(f"  {title}" + " " * max(1, 30 - width) + detail)
    print(f"Efficiency full score: {summary['efficiency_full_score_conditions_met']}")
    if summary["failed_cases"]:
        print(f"Failed:      {', '.join(summary['failed_cases'])}")
    print(f"Report:      {portable_record(str(report_path))}")
    print(f"Run files:   {portable_record(str(run_root))}")
    return 0 if summary["status"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())
