# Get-OZODirectorySummary
This function is part of the [OZOFiles PowerShell Module](../README.md).

## Description
Returns an OZODirectorySummary object.

## Syntax
```
Get-OZODirectorySummary
    -Path <String>
```
## Parameters
|Parameter|Description|
|---------|-----------|
|`Path`|The path to inspect.|

## Examples
```powershell
Get-OZODirectorySummary -Path (Join-Path -Path $Env:USERPROFILE -ChildPath "Downloads")

Validates            : True
newestChildWriteTime : 5/19/2025 13:43:51
longLength           : 256
totalSizeBytes       : 4280832613
Path                 : C:\Users\aliev\Downloads
longPaths            : {}
problemPaths         : {}
objectSIDs           : {S-1-5-18, S-1-5-32-544, S-1-5-21-1004336348-1177238915-682003330-1191}
```

## Outputs
`PSCustomOBject`

## Notes
For more information, please see the [`OZODirectorySummary` class definition](OZODirectorySummary.md)
