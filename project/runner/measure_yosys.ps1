param(
    [Parameter(Mandatory=$true)][string]$Executable,
    [Parameter(Mandatory=$true)][string]$Script,
    [Parameter(Mandatory=$true)][string]$YosysLog,
    [Parameter(Mandatory=$true)][string]$StdoutLog,
    [Parameter(Mandatory=$true)][string]$StderrLog,
    [Parameter(Mandatory=$true)][string]$MeasurementFile,
    [Parameter(Mandatory=$true)][string]$WorkingDirectory
)
$ErrorActionPreference = 'Stop'
# Type compilation, path preparation and opening output files precede timing.
if (-not ('PmuxWindowsMeasurement' -as [type])) {
    Add-Type -Path (Join-Path $PSScriptRoot 'windows_measurement.dll')
}
$measurement = [PmuxWindowsMeasurement]::new(
    $Executable, $Script, $YosysLog, $StdoutLog, $StderrLog,
    $WorkingDirectory, $env:PMUX_SYNTH_RUNTIME_PATH
)
try {
    $elapsed = Measure-Command {
        $measurement.Start()
        $measurement.Wait()
    }
    # PeakWorkingSetSize is the OS high-water mark, not a maximum of RSS polls.
    $peakBytes = $measurement.ReadPeakWorkingSet()
    $measurement.FinishLogs()
    $exitCode = $measurement.ExitCode
    $accountingValid = ($peakBytes -gt 0 -and $elapsed.TotalSeconds -gt 0)
    $result = [ordered]@{
        return_code = $exitCode
        wall_seconds = $elapsed.TotalSeconds
        peak_memory_bytes = $peakBytes
        peak_memory_mb = ($peakBytes / 1MB)
        resource_accounting_valid = $accountingValid
        time_source = 'PowerShell Measure-Command.TotalSeconds'
        memory_source = 'GetProcessMemoryInfo.PeakWorkingSetSize, Yosys main process only'
        sampling_boundary = 'Process creation through Yosys exit; wrapper initialization and proof excluded'
    }
    $result | ConvertTo-Json | Set-Content -LiteralPath $MeasurementFile -Encoding UTF8
    exit $exitCode
} finally {
    $measurement.Dispose()
}
