# Run from any directory. Only the verification suite's Yosys is modified.
param([string]$SuiteRoot)
$ErrorActionPreference = 'Stop'
if (-not $SuiteRoot) {
    $engineeringRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $SuiteRoot = Join-Path $engineeringRoot 'oss-cad-suite'
}
$exe = Join-Path $SuiteRoot 'bin\yosys.exe'
$backup = $exe + '.stack2m-original'
$record = Join-Path $PSScriptRoot 'formal_stack_patch.json'
$bytes = [IO.File]::ReadAllBytes($exe)
if ($bytes.Length -lt 512 -or $bytes[0] -ne 0x4d -or $bytes[1] -ne 0x5a) {
    throw 'Expected a Windows PE executable.'
}
$pe = [BitConverter]::ToInt32($bytes, 0x3c)
if ($pe -lt 0 -or $pe + 112 -gt $bytes.Length -or [BitConverter]::ToUInt32($bytes,$pe) -ne 0x4550) {
    throw 'Invalid PE header.'
}
$optional = $pe + 24
if ([BitConverter]::ToUInt16($bytes,$optional) -ne 0x20b) { throw 'Expected a PE32+ x64 executable.' }
$reserveOffset = $optional + 72
$checksumOffset = $optional + 64
$originalReserve = [BitConverter]::ToUInt64($bytes,$reserveOffset)
$targetReserve = [uint64](128MB)
if ($originalReserve -eq $targetReserve) {
    'Verification Yosys already reserves 128 MiB of stack; no changes.'
    exit 0
}
if ($originalReserve -ne 2MB) { throw "Unexpected existing stack reserve: $originalReserve; no changes." }
$running = Get-CimInstance Win32_Process | Where-Object { $_.ExecutablePath -eq $exe }
if ($running) { throw 'Verification Yosys is running; retry after the test has finished.' }
if (Test-Path -LiteralPath $backup) {
    $backupBytes = [IO.File]::ReadAllBytes($backup)
    $same = $backupBytes.Length -eq $bytes.Length
    for ($i=0; $same -and $i -lt $bytes.Length; $i++) {
        if ($bytes[$i] -ne $backupBytes[$i]) { $same = $false }
    }
    if (-not $same) {
        throw 'A different backup already exists; refusing overwrite.'
    }
} else { Copy-Item -LiteralPath $exe -Destination $backup }

if (-not ('PmuxPeChecksum' -as [type])) {
    Add-Type -TypeDefinition @'
using System.Runtime.InteropServices;
public static class PmuxPeChecksum {
    [DllImport("imagehlp.dll", CharSet=CharSet.Unicode, EntryPoint="MapFileAndCheckSumW")]
    public static extern uint Calculate(string filename, out uint oldSum, out uint newSum);
}
'@
}
try {
    $newBytes = [byte[]]$bytes.Clone()
    [BitConverter]::GetBytes($targetReserve).CopyTo($newBytes,$reserveOffset)
    [IO.File]::WriteAllBytes($exe,$newBytes)
    [uint32]$oldChecksum=0; [uint32]$newChecksum=0
    $rc = [PmuxPeChecksum]::Calculate($exe,[ref]$oldChecksum,[ref]$newChecksum)
    if ($rc -ne 0) { throw "PE checksum calculation failed: $rc" }
    [BitConverter]::GetBytes($newChecksum).CopyTo($newBytes,$checksumOffset)
    [IO.File]::WriteAllBytes($exe,$newBytes)
    $actual = [IO.File]::ReadAllBytes($exe)
    if ([BitConverter]::ToUInt64($actual,$reserveOffset) -ne $targetReserve) { throw 'Stack header verification failed.' }
    # Only SizeOfStackReserve and the PE checksum may differ from the backup.
    for ($i=0; $i -lt $bytes.Length; $i++) {
        if (($i -ge $reserveOffset -and $i -lt $reserveOffset+8) -or
            ($i -ge $checksumOffset -and $i -lt $checksumOffset+4)) { continue }
        if ($bytes[$i] -ne $actual[$i]) { throw "Unexpected changed byte: $i" }
    }
    $data = [ordered]@{
        applied_at = [DateTimeOffset]::Now.ToString('o')
        target = 'oss-cad-suite/bin/yosys.exe'
        backup = 'oss-cad-suite/bin/yosys.exe.stack2m-original'
        previous_reserve_bytes = $originalReserve
        new_reserve_bytes = $targetReserve
        stack_commit_bytes = [BitConverter]::ToUInt64($actual,$optional+80)
        checksum = $newChecksum
        scope = 'Verification only. Only PE stack reserve and checksum changed; code sections unchanged.'
    }
    $data | ConvertTo-Json | Set-Content -LiteralPath $record -Encoding UTF8
    $data | ConvertTo-Json
} catch {
    Copy-Item -LiteralPath $backup -Destination $exe -Force
    throw
}
