# Test-OZOPath
This function is part of the [OZOFiles PowerShell Module](../README.md).

## Description
Determines if a path exists and is readable. Optionally tests if the path is writable.

## Syntax
```
Test-OZOPath
    -Path <String>
```

## Parameters
|Parameter|Description|
|---------|-----------|
|`Path`|The path to test. Returns TRUE if the path exists and is readable and otherwise returns FALSE.|
|`Writable`|Determines if the path is writable. Returns TRUE if the path is writable and otherwise returns FALSE.|

## Examples
```powershell
Test-OZOPath -Path ".\README.md"
True
```

## Outputs
`System.Boolean`
