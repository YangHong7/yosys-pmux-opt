$runnerArguments = @($args)
$pmuxTemporaryDrive = $null
$benchExit = 1
try {
    . (Join-Path $PSScriptRoot 'environment.ps1')
    $hasMode = @('--case', '--all', '--check', '--help', '-h') | Where-Object { $runnerArguments -contains $_ }
    $benchArguments = @('--all') + $runnerArguments
    if ($hasMode) { $benchArguments = @($runnerArguments) }
    & $runnerPython (Join-Path $PSScriptRoot 'bench.py') @benchArguments
    $benchExit = $LASTEXITCODE
} catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    $benchExit = 1
} finally {
    if ($pmuxTemporaryDrive) {
        & (Join-Path $env:SystemRoot 'System32\subst.exe') $pmuxTemporaryDrive /D
    }
}
exit $benchExit
