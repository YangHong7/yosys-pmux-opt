# Private, relocatable runtime. No installed MSYS2/Python/WSL is used.
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$engineeringRoot = Split-Path -Parent $projectRoot
$physicalEngineeringRoot = $engineeringRoot
# Some bundled tool launchers cannot start from Unicode/space paths. A private
# DOS drive alias keeps every executable path short and ASCII for this run.
if ($engineeringRoot -match '[^\x21-\x7e]' -or $engineeringRoot.Length -gt 55) {
    $usedDrives = @(Get-PSDrive -PSProvider FileSystem | Select-Object -ExpandProperty Name)
    $subst = Join-Path $env:SystemRoot 'System32\subst.exe'
    foreach ($letter in @('Z','Y','X','W','V','U','T','S','R','Q','P','O','N','M','L')) {
        if ($usedDrives -contains $letter) { continue }
        & $subst ($letter + ':') $physicalEngineeringRoot
        if ($LASTEXITCODE -eq 0) {
            $pmuxTemporaryDrive = $letter + ':'
            $engineeringRoot = $pmuxTemporaryDrive + '\'
            break
        }
    }
    if (-not $pmuxTemporaryDrive) { throw '环境检查未通过：没有可用的临时盘符，请释放一个 L 至 Z 之间的盘符后重试。' }
}
$env:PMUX_ENGINEERING_ROOT = $engineeringRoot
$env:PMUX_PHYSICAL_ROOT = $physicalEngineeringRoot
$runtimeRunner = Join-Path $engineeringRoot 'project\runner'
$suiteRoot = Join-Path $engineeringRoot 'oss-cad-suite'
$msysRoot = Join-Path $engineeringRoot 'runtime\msys64'
$ucrtBin = Join-Path $msysRoot 'ucrt64\bin'
$msysBin = Join-Path $msysRoot 'usr\bin'
$nativeTcl = Join-Path $msysRoot 'ucrt64\lib\tcl8.6'
foreach ($required in @(
    (Join-Path $engineeringRoot 'runtime\python\python.exe'),
    (Join-Path $ucrtBin 'libstdc++-6.dll'),
    (Join-Path $nativeTcl 'init.tcl'),
    (Join-Path $PSScriptRoot 'windows_measurement.dll')
)) {
    if (-not (Test-Path -LiteralPath $required -PathType Leaf)) {
        throw "环境检查未通过：运行依赖文件缺失，请检查交付目录是否完整。`n  缺失文件：$required"
    }
}
$windowsRoot = $env:SystemRoot
$windowsPowerShell = Join-Path $windowsRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$osPath = @((Join-Path $windowsRoot 'System32'), $windowsRoot,
            (Join-Path $windowsRoot 'System32\Wbem'), (Split-Path -Parent $windowsPowerShell)) -join ';'
$env:PATH = "$(Join-Path $suiteRoot 'bin');$(Join-Path $suiteRoot 'lib');$ucrtBin;$msysBin;$osPath"
$env:PMUX_SYNTH_RUNTIME_PATH = "$ucrtBin;$msysBin"
$env:PMUX_SYNTH_TCL_LIBRARY = $nativeTcl
$env:MSYS2_ROOT = $msysRoot
$env:OSS_CAD_SUITE = $suiteRoot
$env:YOSYSHQ_ROOT = $suiteRoot.TrimEnd('\') + '\'
$env:PYTHON_EXECUTABLE = Join-Path $suiteRoot 'lib\python3.exe'
Remove-Item Env:PYTHONHOME -ErrorAction SilentlyContinue
Remove-Item Env:PYTHONPATH -ErrorAction SilentlyContinue
Remove-Item Env:TCL_LIBRARY -ErrorAction SilentlyContinue
Remove-Item Env:TK_LIBRARY -ErrorAction SilentlyContinue
$formalTcl = Join-Path $suiteRoot 'lib\tcl8.6'
if (Test-Path -LiteralPath (Join-Path $formalTcl 'init.tcl')) { $env:TCL_LIBRARY = $formalTcl }
$env:SSL_CERT_FILE = Join-Path $suiteRoot 'etc\cacert.pem'
$env:PYTHONUTF8 = '1'
$env:PYTHONIOENCODING = 'utf-8'
$env:PYTHONDONTWRITEBYTECODE = '1'
$env:LANG = 'C'
$env:LC_ALL = 'C'
$env:MSYSTEM = 'UCRT64'
$env:MSYS2_PATH_TYPE = 'inherit'
Remove-Item Env:SHELLOPTS -ErrorAction SilentlyContinue
$env:BASH_ENV = (Join-Path $runtimeRunner 'bash_environment.sh').Replace('\', '/')
$env:MAKEFLAGS = 'SHELL=/usr/bin/bash'
$env:YOSYS = 'yosys'
$env:ABC = 'yosys-abc'
$env:PMUX_POWERSHELL = $windowsPowerShell
$runnerPython = Join-Path $engineeringRoot 'runtime\python\python.exe'

