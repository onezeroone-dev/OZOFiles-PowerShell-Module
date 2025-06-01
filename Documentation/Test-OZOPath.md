# Test-OZOPath
This function is part of the [OZOFiles PowerShell Module](../README.md).

## Description
Determines if a path exists and is readable. Optionally tests if the path is writable.

## Syntax
```
Test-OZOPath
    -Path     <String>
    -Writable <Switch>
```

## Parameters
|Parameter|Description|
|---------|-----------|
|`Path`|The path to test. Returns _True_ if the path exists and is readable and otherwise returns _False_.|
|`Writable`|Determines if the path is writable. Returns _True_ if the path is writable and otherwise returns _False_.|

## Examples
### Example 1
```powershell
Test-OZOPath -Path "C:\Windows\notepad.exe"
True
```

### Example 2
```powershell
Test-OZOPath -Path "C:\Windows\notepad.exe" -Writable
False
```

## Outputs
`System.Boolean`
