# Get-OZOFileToBase64
This function is part of the [OZOFiles PowerShell Module](../README.md).

## Description
Returns _True_ if the Path is locked or _False_ if the path is not locked, does not exist, is not accessible, or is a directory.

## Syntax
```
Get-OZOFileIsLocked
    -Path <String>
```

## Parameters
|Parameter|Description|
|---------|-----------|
|`Path`|The path of the file to inspect.|

## Examples
```powershell
Get-OZOFileIsLocked -Path "C:\Temp\test.txt"
False
```

## Outputs
`System.Boolean`
