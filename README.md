# 基于 Yosys 的 PMUX 结构优化设计

本项目基于 Yosys v0.69，面向 Cyclone IV 四输入 LUT 综合流程，通过自定义 `pmux_opt` Pass 和配套 ABC9 命令流减少组合逻辑资源。工程提供 Windows 原生基线版、优化版、运行依赖、测试案例及统一测试入口。

## 优化方法

`pmux_opt` 依据网表连接与函数关系识别候选结构，完成以下五类优化：

- **P1：成对选择结构共享**，提取两个输出之间可复用的数据选择网络。
- **P2：优先选择链重组**，将符合条件的多级 MUX 链改为并行选择结构。
- **P3：比较逻辑共享与使能条件利用**，共享公共比较信息，并利用写入条件化简数据和控制逻辑。
- **P4：小规模查表逻辑分解与共享**，构造适合 LUT4 的函数分解，并复用不同输出间的中间函数。
- **P5：完整译码选择网络区域重组**，重建二进制选择树或汇总路径条件，减少多层选择开销。

五类规则统一接入 `synth_intel` 的 `map_bram` 之后、`map_ffram` 之前。ABC9 阶段从同一份 Pass 输出生成“重写后映射”和“直接映射”两路候选，优先选择 LUT 数较少的结果，同数量时比较 LUT 深度。

## 测试结果

面积统计最终映射的 `cycloneiv_lcell_comb` 与独立 NOT 数量之和，DFF 单列。基线使用原版 Pass 流程与原版 ABC9 命令流；优化版使用完整 `pmux_opt` 与配套 ABC9 命令流。

| 案例 | 基线组合逻辑 | 优化后组合逻辑 | 削减率 | DFF（基线→优化） | LUT 深度（基线→优化） |
|---|---:|---:|---:|---:|---:|
| test1 | 288 | 184 | 36.11% | 222→222 | 4→4 |
| test2 | 25 | 15 | 40.00% | 0→0 | 2→2 |
| test3 | 13 | 8 | 38.46% | 17→14 | 3→3 |
| test4 | 36 | 26 | 27.78% | 10→10 | 3→2 |
| balanced | 426 | 366 | 14.08% | 12→12 | 10→9 |
| pipeline | 450 | 348 | 22.67% | 24→24 | 4→6 |
| crossbar | 408 | 361 | 11.52% | 10→10 | 6→7 |
| feedback | 368 | 299 | 18.75% | 16→16 | 7→7 |
| nested | 413 | 378 | 8.47% | 12→12 | 10→10 |

- 九例逐例平均削减率为 **24.21%**，组合逻辑合计 **2427→1985**，DFF 合计 **323→320**。
- 原始 RTL 与基线网表、原始 RTL 与优化网表、基线与优化网表三组等价性比较，共 **27 项全部通过**。

### 十轮效率测试

时间统计从 Yosys 启动到退出的完整综合墙钟时间，内存统计 Yosys 主进程峰值工作集。开销按 `(优化版 − 基线) / 基线 × 100%` 计算，负值表示优化版耗时或内存更低。九例各测十轮，结果如下：

| 案例 | 时间参考均值 | 时间十轮范围 | 内存参考均值 | 内存十轮范围 | 两项均 ≤5% 轮数 |
|---|---:|---:|---:|---:|---:|
| test1 | −11.69% | −23.89%～−8.08% | −3.94% | −5.34%～−3.21% | 10/10 |
| test2 | −2.03% | −11.95%～+2.36% | +0.25% | −1.34%～+1.36% | 10/10 |
| test3 | −0.35% | −5.74%～+3.23% | +0.07% | −0.49%～+0.56% | 10/10 |
| test4 | −4.38% | −12.62%～+2.47% | −1.35% | −2.58%～+0.21% | 10/10 |
| balanced | −8.81% | −18.21%～+2.61% | −4.90% | −7.65%～−2.96% | 10/10 |
| pipeline | −13.75% | −18.48%～−10.94% | −1.26% | −1.86%～−0.49% | 10/10 |
| crossbar | −1.96% | −6.38%～+2.52% | +5.12% | +4.23%～+6.42% | 5/10 |
| feedback | −3.53% | −7.05%～+0.60% | −1.94% | −2.76%～−0.72% | 10/10 |
| nested | −8.97% | −16.66%～−3.82% | −1.44% | −2.79%～+0.84% | 10/10 |

- 九例十轮时间开销均低于 5%，最高为 test3 的 **3.23%**；八例在十轮中时间与内存均达标。
- crossbar 内存开销均值为 **+5.12%**，范围 **+4.23%～+6.42%**，仅高于 5% 阈值 0.12 个百分点，十轮中 5 轮两项同时达标。
- 十轮的逐轮测量样本、时间复核记录、综合网表与等价性证明保存在 `project/runs/<批次>/`(由于runs具体产物包括预热、两版综合结果、效率统计、等价性验证以及可能的复核数据，体积较大，目录下仅保留十轮中最近一轮的结果)，批次汇总报告保存在 `project/reports/`，详细分析见设计报告第 3.4 节。

## 快速运行

### 1. 运行环境与验证工具

运行环境为 **Windows 10/11 x64**。Python 和综合运行依赖已包含在 `runtime/`，解压完整运行包后即可测量优化率、时间和内存。等价性验证使用以下工具套件，需单独下载：

[Windows x64 OSS CAD Suite 20260830 下载页面](https://github.com/YosysHQ/oss-cad-suite-build/releases/tag/2026-08-30)

解压后将 `oss-cad-suite` 文件夹放在工程根目录，与 `run.cmd` 同级，确保存在 `oss-cad-suite/bin/eqy.exe`。套件完整时执行三组等价性验证；未准备好时显示提示并继续综合和效率测量，各案例与汇总表的等价性标记为“未进行”。

验证套件已安装在其他位置时，可将 `project/runner/environment.ps1` 中的 `$suiteRoot` 改为该套件目录的绝对路径，例如 `$suiteRoot = 'D:\Tools\oss-cad-suite'`。

### 2. 检查环境并执行测试

在工程根目录打开 PowerShell：

```powershell
.\run.cmd --check          # 检查运行环境
.\run.cmd                  # 运行全部九个正式案例
.\run.cmd --case test3     # 运行单个案例
.\run.cmd --help           # 查看参数
```

也可直接双击 `run.cmd` 运行全部九例。入口依次完成预热、两版综合与指标采集、必要的时间复核、可用时的三组等价性证明及结果汇总。

补充案例单独运行：

```powershell
.\run.cmd --cases-dir project/cases/P2
.\run.cmd --cases-dir project/cases/pressure
```

P2 输入变体及压力测试的结果单独统计。压力测试的验证工具配置和已完成证明范围见设计报告第三部分。

### 3. 查看结果

- **控制台**：逐例结果和本批汇总。
- **`project/reports/`**：各批次汇总报告。
- **`project/runs/<批次>/`**：输入副本、运行配置、综合日志、网表、测量样本和等价性证明记录。

## 工程目录

```text
pmux/
├─ README.md                  项目概览与快速运行
├─ run.cmd                    Windows 统一测试入口
├─ yosys-v0.69-base/build/     基线版完整构建产物
├─ yosys-v0.69-opt/build/      优化版完整构建产物
├─ runtime/                   便携 Python 与综合运行依赖
├─ oss-cad-suite/              自行准备的验证工具
└─ project/
   ├─ src/                    优化源码与接入文件
   ├─ cases/                  九个正式案例及专项、压力案例
   ├─ runner/                 综合、测量、验证与汇总脚本
   ├─ reports/                批次报告
   └─ runs/                   原始运行记录
```

交付的两版程序目录仅保留完整 `build/`，优化设计源码保存在 `project/src/`；重新编译时按下文下载完整 Yosys 源码并放入对应文件。

## 构建环境

直接运行交付程序时，按前面的“快速运行”准备验证套件即可。重新编译时，另外安装下面的开发工具。

| 项目 | 本项目构建配置 |
|---|---|
| 操作系统 | Windows 11 x64；运行入口支持 Windows 10/11 x64 |
| 工具链 | MSYS2 **UCRT64**，GCC / libstdc++，使用 UCRT 运行库 |
| GCC / G++ | 16.2.0，目标平台 `x86_64-w64-mingw32`，C++20 |
| CMake | 4.4.4；Yosys v0.69 要求至少 3.28 |
| 生成器 | Ninja 1.13.2 |
| GNU Make / Flex / Bison | 4.4.1 / 2.6.4 / 3.8.2 |
| 构建用 Python | 原构建记录为 3.13.9；下文显式指定 MSYS2 UCRT64 的 Python |
| 构建模式 | Release；CMake 的 Release 编译参数为 `-O3 -DNDEBUG` |
| 主要功能配置 | ABC、Tcl、Readline、libffi、zlib、Slang 保持启用；Python 嵌入接口保持关闭 |
| Yosys | v0.69，提交 `9f75ca1f9834a39a863915b5dae0c7b1e33533bc` |
| ABC 子模块 | 提交 `a51bf4a7bb38ce06ea3a544b1463b40832213917` |

两版使用相同工具链、构建配置和 ABC 子模块版本。优化版增加 `pmux_opt`、Intel 流程接入及 ABC9 默认命令流修改，ABC 算法源码保持原版。

测试入口使用 `runtime/python/` 中的便携 Python 3.13.9；等价性证明使用 OSS CAD Suite 内的 Python、EQY、SBY 和证明工具。构建用 Python 负责构建阶段的代码生成，由 CMake 配置。

## 从源码重新编译

以下步骤直接在工程根目录准备两份源码，分别编译后即可使用现有测试入口。

### 1. 安装 MSYS2 与构建工具

从 [MSYS2 官网](https://www.msys2.org/)安装，以下以 `C:\msys64` 为安装路径。在开始菜单打开 **MSYS2 UCRT64** 终端，执行：

```bash
pacman -Syu
```

若更新提示关闭终端，完成后重新打开 MSYS2 UCRT64，再执行一次 `pacman -Syu`。随后在同一终端安装：

```bash
pacman -S --needed git make flex bison mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-cmake mingw-w64-ucrt-x86_64-ninja mingw-w64-ucrt-x86_64-python mingw-w64-ucrt-x86_64-pkgconf mingw-w64-ucrt-x86_64-zlib mingw-w64-ucrt-x86_64-libffi mingw-w64-ucrt-x86_64-readline mingw-w64-ucrt-x86_64-tcl
```

各工具的用途如下：

| 工具或库 | 用途 |
|---|---|
| Git | 下载 Yosys 及 ABC、Slang 等子模块 |
| GCC / G++ | 编译 C/C++ 源码 |
| CMake | 检查依赖、选择编译器、生成构建规则 |
| Ninja | 按 CMake 生成的规则执行并行编译与链接 |
| Flex / Bison | 生成词法、语法分析器 |
| Python | 执行构建阶段的代码生成脚本 |
| pkgconf | 向 CMake 提供开发库的头文件和链接信息 |
| zlib / libffi / Readline / Tcl | 提供压缩、外部调用、命令行编辑及 Tcl 支持 |
| Make / Bash | 提供构建辅助和验证脚本使用的 Unix 工具环境 |

MSYS2 采用滚动更新，安装时获得的工具版本以本机输出为准。环境选择及更新方法见 [MSYS2 环境说明](https://www.msys2.org/docs/environments/)和[更新说明](https://www.msys2.org/docs/updating/)。

### 2. 配置 PowerShell 构建终端

安装完成后，在**本工程根目录**打开 PowerShell。以下下载、配置、编译和检查命令均在该窗口按顺序执行；`$msysRoot` 改为实际安装位置。

```powershell
$pmuxRoot = (Get-Location).Path
$msysRoot = 'C:\msys64'
$ucrtRoot = Join-Path $msysRoot 'ucrt64'
$ucrtBin = Join-Path $ucrtRoot 'bin'
$msysBin = Join-Path $msysRoot 'usr\bin'
$env:PATH = "$ucrtBin;$msysBin;$env:PATH"
$env:MSYSTEM = 'UCRT64'
$env:PKG_CONFIG_PATH = "$ucrtRoot\lib\pkgconfig;$ucrtRoot\share\pkgconfig"

Get-Command gcc,g++,cmake,ninja,git,make,flex,bison,python,pkg-config | Select-Object Name,Source
gcc --version
g++ --version
cmake --version
ninja --version
python --version
make --version
flex --version
bison --version
```

这里将 UCRT64 工具目录放在 PATH 前面，并指定开发库查询目录。检查 GCC/G++、CMake、Ninja、Python 和 pkg-config 来自 `ucrt64/bin/`，Git、Make、Flex、Bison 来自 `usr/bin/`。设置仅作用于当前终端；重新打开窗口后再次执行本步骤。

### 3. 准备 base 和 opt 源码目录

先在资源管理器中删除工程根目录原有的 `yosys-v0.69-base/`、`yosys-v0.69-opt/` 两个构建产物目录。保留 `project/`、`runtime/`、`oss-cad-suite/` 和根目录脚本。

回到前面已配置好环境的 PowerShell，在工程根目录下载 v0.69 源码及子模块，命名为 base，再复制一份作为 opt：

```powershell
Set-Location $pmuxRoot

git clone --branch v0.69 --single-branch --recurse-submodules https://github.com/YosysHQ/yosys.git yosys-v0.69-base

Copy-Item -LiteralPath .\yosys-v0.69-base -Destination .\yosys-v0.69-opt -Recurse -Force
```

等待下载成功后再执行复制。`--recurse-submodules` 会一并下载 ABC、Slang 等构建所需子模块。可执行以下命令查看 Yosys 和 ABC 的版本，分别应对应前面环境表中的提交：

```powershell
git -C .\yosys-v0.69-base rev-parse HEAD
git -C .\yosys-v0.69-base\abc rev-parse HEAD
```

### 4. 将优化文件放入 opt

在工程根目录执行以下复制命令，base 保持原版：

```powershell
Copy-Item .\project\src\pmux .\yosys-v0.69-opt\passes\pmux -Recurse -Force
Copy-Item .\project\src\CMakeLists.txt .\yosys-v0.69-opt\passes\CMakeLists.txt -Force
Copy-Item .\project\src\synth_intel.cc .\yosys-v0.69-opt\techlibs\intel\synth_intel.cc -Force
Copy-Item .\project\src\abc9.cc .\yosys-v0.69-opt\passes\techmap\abc9.cc -Force
```

| 交付文件 | opt 源码中的位置 | 作用 |
|---|---|---|
| `project/src/pmux/` | `passes/pmux/` | Pass 实现及子目录构建规则 |
| `project/src/CMakeLists.txt` | `passes/CMakeLists.txt` | 注册新增 Pass 目录 |
| `project/src/synth_intel.cc` | `techlibs/intel/synth_intel.cc` | 在统一综合位置调用 Pass |
| `project/src/abc9.cc` | `passes/techmap/abc9.cc` | 设置两路候选 ABC9 默认命令流 |

### 5. 进入 base 配置并编译

在同一 PowerShell 中进入 base 目录，先配置，再编译：

```powershell
Set-Location .\yosys-v0.69-base

cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release "-DCMAKE_C_COMPILER=$ucrtBin/gcc.exe" "-DCMAKE_CXX_COMPILER=$ucrtBin/g++.exe" "-DCMAKE_PREFIX_PATH=$ucrtRoot" "-DPython_EXECUTABLE=$ucrtBin/python.exe" "-DPython3_EXECUTABLE=$ucrtBin/python.exe"

cmake --build build --parallel 4
```

### 6. 进入 opt 配置并编译

base 编译完成后，进入同级的 opt 目录，采用相同参数：

```powershell
Set-Location ..\yosys-v0.69-opt

cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release "-DCMAKE_C_COMPILER=$ucrtBin/gcc.exe" "-DCMAKE_CXX_COMPILER=$ucrtBin/g++.exe" "-DCMAKE_PREFIX_PATH=$ucrtRoot" "-DPython_EXECUTABLE=$ucrtBin/python.exe" "-DPython3_EXECUTABLE=$ucrtBin/python.exe"

cmake --build build --parallel 4
```

两次配置均成功后再执行各自的编译命令；出现错误时先处理错误，再继续后续步骤。主要参数含义如下：

- `-S .`：以当前目录为源码目录；`-B build`：将产物保存到当前目录下的 `build/`。
- `-G Ninja`、`Release`：选择 Ninja 构建规则和发布构建配置。
- `CMAKE_C_COMPILER` / `CMAKE_CXX_COMPILER`：固定 UCRT64 编译器。
- `CMAKE_PREFIX_PATH`：在 UCRT64 安装目录查询开发库。
- `Python*_EXECUTABLE`：固定构建用 Python；Flex、Bison、pkg-config 从第2步配置的 PATH 查找。
- `--parallel 4`：最多同时执行四个构建任务，可根据本机内存调整。

每版都会一并构建 Yosys 和配套 `yosys-abc.exe`。其余功能选项保持 v0.69 默认值。

### 7. 检查产物并运行测试

回到工程根目录，检查两个程序的版本及优化命令：

```powershell
Set-Location $pmuxRoot

.\yosys-v0.69-base\build\yosys.exe -V
.\yosys-v0.69-opt\build\yosys.exe -V
.\yosys-v0.69-opt\build\yosys.exe -Q -p "help pmux_opt"
.\yosys-v0.69-opt\build\yosys.exe -Q -p "help abc9"
```

两版应显示 Yosys 0.69，优化版能够显示 `pmux_opt` 帮助，其 ABC9 默认命令流包含两处 `&save -a`。产物分别位于：

```text
yosys-v0.69-base/build/
yosys-v0.69-opt/build/
```

保留两份完整 `build/`，其中包含 Yosys、ABC、共享库及 `share/` 器件数据。现有测试入口直接读取这两个目录，执行：

```powershell
.\run.cmd --check
.\run.cmd
```

测试会核对面积、效率和三组等价性结果。更换工具链时，同步更新 `runtime/msys64/` 中新程序所需的运行 DLL 及 Tcl 运行库，保持与构建时所用版本一致。

### 后续增量编译

修改 opt 源码后，进入该目录再次执行编译即可：

```powershell
Set-Location "$pmuxRoot\yosys-v0.69-opt"
cmake --build build --parallel 4
```

修改 `project/src/` 中的交付副本时，先按第4步复制到 opt 源码树，再编译。更换编译器或构建配置时，重新运行对应目录中的 CMake 配置命令。
