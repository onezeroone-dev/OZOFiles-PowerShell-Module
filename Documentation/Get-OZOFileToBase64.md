# Get-OZOFileToBase64
This function is part of the [OZOFiles PowerShell Module](../README.md).

## Description
Returns a Base-64 string representing a valid file, or "File not found" if the file does not exist or cannot be read.

## Syntax
```
Get-OZOFileToBase64
    -Path <String>
```

## Parameters
|Parameter|Description|
|---------|-----------|
|`Path`|The path to the file to convert to a base-64 string.|

## Examples
```powershell
Get-OZOFileToBase64 -Path ".\README.md"
IyBPWk8gUG93ZXJTaGVsbCBNb2R1bGUgSW5zdGFsbGF... <snip>
```

## Outputs
`System.String`
