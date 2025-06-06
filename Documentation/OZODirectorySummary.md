# OZODirectorySummary Class
This class is part of the [OZOFiles PowerShell Module](../README.md).

## Usage
Use the [`Get-OZODirectorySummary`](Get-OZODirectorySummary.md) function to return an object of this class.

## Definition
### Associations
```
+ $Validates:Boolean             = $true
+ $newestChildWriteTime:DateTime = (Get-Date -Year 1970 -Month 01 -Day 01 -Hour 00 -Minute 00 -Second 00)
+ $longLength:Int32              = 0
+ $totalSizeBytes:Int64          = 0
+ $Path:String                   = $null
+ $objectSIDs:System.Collections.Generic.List[String]                     = @()
+ $longPaths:System.Collections.Generic.List[System.IO.FileSystemInfo]    = @()
+ $problemPaths:System.Collections.Generic.List[System.IO.FileSystemInfo] = @()
```
### Operations
```
+ OZODirectorySummary($LongLength,$Path):void
- ValidateEnvironment():Boolean
- GetDirectorySummary():Boolean
```
