# Get-OZOChildWriteTime
This function is part of the [OZOFiles PowerShell Module](../README.md).

## Description
Returns the newest or oldest write time for all files within a given path. Returns the newest write time when executed with no parameters.

## Syntax
```
Get-OZOChildWriteTime
    -Oldest
    -Path   <String>
```
## Parameters
|Parameter|Description|
|---------|-----------|
|`Oldest`|Return the oldest date time.|
|`Path`|The path to inspect. Defaults to the current directory. If Path is invalid or inaccessible, the script returns a datetime object representing 1970-01-01 00:00:00.|

## Examples

### Example 1
```powershell
Get-OZOChildWriteTime -Path (Join-Path -Path $Env:USERPROFILE -ChildPath "Git")
Saturday, February 15, 2025 17:44:45
```

### Example 2
```powershell
Get-OZOChildWriteTime -Path (Join-Path -Path $Env:USERPROFILE -ChildPath "Git") -Oldest
Friday, February 9, 2024 18:03:56
```

## Outputs
`System.DateTime`
