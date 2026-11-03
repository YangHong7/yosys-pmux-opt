param([Parameter(Mandatory=$true)][string]$CaseName)
& (Join-Path $PSScriptRoot 'run_all.ps1') --case $CaseName @args
exit $LASTEXITCODE
