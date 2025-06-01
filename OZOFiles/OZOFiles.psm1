# CLASSES
Class OZODirectorySummary {
    # PROPERTIES: Booleans, DateTimes, Int64s, Strings
    [Boolean]  $Validates            = $true
    [DateTime] $newestChildWriteTime = (Get-Date -Year 1970 -Month 01 -Day 01 -Hour 00 -Minute 00 -Second 00)
    [Int32]    $longLength           = 0
    [Int64]    $totalSizeBytes       = 0
    [String]   $Path                 = $null
    # PROPERTIES: FileSystemInfo Lists
    [System.Collections.Generic.List[System.IO.FileSystemInfo]] $longPaths    = @()
    [System.Collections.Generic.List[System.IO.FileSystemInfo]] $problemPaths = @()
    # PROPERTIES: String Lists
    [System.Collections.Generic.List[String]] $objectSIDs = @()
    # METHODS
    # Constructor method
    OZODirectorySummary($LongLength,$Path) {
        # Set properties
        $this.longLength = $longLength
        $this.Path       = $Path
        # Call ValidateEnvironment to set Validates
        If ($this.ValidateEnvironment() -eq $true) {
            # Path is valid; get directory summary
            $this.GetDirectorySummary()
        } Else {
            # Path is not valid
            $this.Validates -eq $false
        }
    }
    # Validate environment method
    Hidden [Boolean] ValidateEnvironment() {
        # Control variable
        [Boolean] $Return = $true
        # Determine if the path exists and is readable
        If ([Boolean](Test-OZOPath -Path $this.Path) -eq $true) {
            # Path exists and is readable
            $this.Path = (Get-Item -Path $this.Path).FullName
        } Else {
            # Path does not exist or is not readable
            Write-OZOProvider -Message ($this.Path + " does not exist or is not readable.") -Level "Error"
            $Return = $false
        }
        # Return
        return $Return
    }
    # Get directory summary method
    Hidden [Void] GetDirectorySummary() {
        # Get the Last Write Time for the path
        $this.newestChildWriteTime = (Get-Item -Path $this.Path).LastWriteTime
        # Iterate through the object SIDs for the path *including* inhertance and *non-recursive*
        ForEach ($identityReference in (Get-Item -Path $this.Path | Get-Acl).Access.IdentityReference) {
            [String] $sid = $identityReference.Translate([System.Security.Principal.SecurityIdentifier]).Value
            # Determine if this SID is already found in objectSIDs; and if not, add it
            If ($this.objectSIDs -NotContains $sid) { $this.objectSIDs.Add($sid) }
        }
        # Iterate through the children of the path (recursive)
        ForEach ($childItem in (Get-ChildItem -Path $this.Path -Recurse)) {
            # Try to get the item
            Try {
                Get-Item -path $childItem.FullName -ErrorAction Stop
                # Success; iterate through the object SIDs for this child item *not including* inheritance
                ForEach ($identityReference in ($childItem | Get-Acl | Where-Object {$_.IsInherited -eq $false}).Access.IdentityReference) {
                    [String] $sid = $identityReference.Translate([System.Security.Principal.SecurityIdentifier]).Value
                    # Determine if this SID is already found in objectSIDs; and if not, add it
                    If ($this.objectSIDs -NotContains $sid) { $this.objectSIDs.Add($sid) }
                }
                # Determine if the write time of this child is more recent than the stored value; and if yes, update newestChildWriteTime
                If ($childItem.LastWriteTime -gt $this.newestChildWriteTime) { $this.newestChildWriteTime = $childItem.LastWriteTime }
                # Add the length of this item to totalSizeBytes
                $this.totalSizeBytes = $this.totalSizeBytes + $childItem.Length
                # Determine the length of this item is greater than or equal to the long path length
                If ($childItem.FullName.Length -ge $this.longLength) {
                    # Item length is greater than or equal to the long length; add to long paths list
                    $this.longPaths.Add($childItem)
                }
            } Catch {
                # Failure; add to problem paths list
                Add-Member -InputObject $childItem -MemberType NoteProperty -Name "ErrorMessage" -Value $_
                $this.problemPaths.Add($childItem)
            }
        }
    }
}

# FUNCTIONS
Function Get-OZOChildWriteTime {
    <#
        .SYNOPSIS
        See description.
        .DESCRIPTION
        Returns the newest or oldest write time for all files within a given path. Returns the newest write time when executed with no parameters.
        .PARAMETER Oldest
        Return the oldest date time.
        .PARAMETER Path
        The path to inspect. Defaults to the current directory. If Path is invalid or inaccessible, the script returns a datetime object representing 1970-01-01 00:00:00.
        .EXAMPLE
        Get-OZOChildWriteTime -Path (Join-Path -Path $Env:USERPROFILE -ChildPath "Git")
        Saturday, February 15, 2025 17:44:45
        .EXAMPLE
        Get-OZOChildWriteTime -Path (Join-Path -Path $Env:USERPROFILE -ChildPath "Git") -Oldest
        Friday, February 9, 2024 18:03:56
        .LINK
        https://github.com/onezeroone-dev/OZOFiles-PowerShell-Module/blob/main/Documentation/Get-OZOChildWriteTime.md
    #>
    [CmdLetBinding(SupportsShouldProcess = $true)] Param(
        [Parameter(Mandatory=$false,HelpMessage="Include punctuation and spacing")][Switch]$Oldest,
        [Parameter(Mandatory=$false,HelpMessage="The path to inspect")][String]$Path = (Get-Location)
        
    )
    # Get datetime objects
    [DateTime] $newestChildWriteTime = (Get-Date -Year 1970 -Month 01 -Day 01 -Hour 00 -Minute 00 -Second 00)
    [DateTime] $oldestChildWriteTime = (Get-Date)
    # Determine if the path is valid
    If ((Test-OZOPath -Path $Path) -eq $true) {
        # Iterate through the children of the path
        ForEach ($childItem in (Get-ChildItem -Recurse -Path $Path)) {
            # Determine if the write time is newer than the current newestChildWriteTime
            If ($childItem.LastWriteTime -gt $newestChildWriteTime) {
                # Write time is newer; update newestChildWriteTime
                $newestChildWriteTime = $childItem.LastWriteTime
            }
            # Determine if the write time is older than the current oldestChildWriteTime
            If ($childItem.LastWriteTime -lt $oldestChildWriteTIme) {
                # Write time is older; update oldestChildWriteTime
                $oldestChildWriteTime = $childItem.LastWriteTime
            }
        }
        # Determine if Oldest was specified
        If ($Oldest -eq $true) {
            # Oldest was specified; return with oldestChildWriteTime
            return $oldestChildWriteTime
        } Else {
            # Oldest was not specified; return with newestChildWriteTime
            return $newestChildWriteTime
        }
    } Else {
        # Path is invalid; return datetime object representing 1970-01-01 00:00:00
        return $newestChildWriteTime
    }
}

Function Get-OZODirectorySummary {
    <#
        .SYNOPSIS
        See description.
        .DESCRIPTION
        Returns an OZODirectorySummary object.
        .PARAMETER LongLength
        Number of characters in a long path. Defaults to 256.
        .PARAMETER Path
        The path to inspect.
        .EXAMPLE
        $ozoDirectorySummary = (Get-OZODirectorySummary -Path "C:\Temp")
        .LINK
        https://github.com/onezeroone-dev/OZOFiles-PowerShell-Module/blob/main/Documentation/Get-OZODirectorySummary.md
    #>
    [CmdLetBinding()] Param (
        [Parameter(Mandatory=$false,HelpMessage="Number of characters in a long path")][Int32]$LongLength = 256,
        [Parameter(Mandatory=$true,HelpMessage="Path to inspect")][String]$Path
    )
    return [OZODirectorySummary]::new($LongLength,$Path)
}

Function Get-OZOFileIsLocked {
    <#
        .SYNOPSIS
        See description.
        .DESCRIPTION
        Returns True if the Path is locked or False if the path is not locked, does not exist, is not accessible, is read-only, or is a directory.
        .PARAMETER Path
        The path of the file to inspect.
        .EXAMPLE
        Get-OZOFileIsLocked -Path "C:\Temp\test.txt"
        False
        .LINK
        https://github.com/onezeroone-dev/OZOFiles-PowerShell-Module/blob/main/Documentation/Get-OZOFileIsLocked.md
    #>
    # Parameters
    [CmdletBinding()] Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)][Alias("FullName","PSPath")][String[]]$Path
    )
    # Try to get the item
    Try {
        $Item = (Get-Item -Path $Path -ErrorAction Stop)
        # Success; determine if Item is a file
        If ($Item.PSIsContainer -eq $false) {
            # Item is a file; try to open it
            Try {
                $fileStream = [System.IO.File]::Open($Item.FullName,"Open","Write")
                $fileStream.Close()
                $fileStream.Dispose()
                # Success
                return $false
            } Catch {
                # Failure
                return $true
            }
        } Else {
            # Item is a directory
            return $false
        }
    } Catch {
        # Failure
        return $false
    }
}

Function Get-OZOFileToBase64 {
    <#
        .SYNOPSIS
        See description.
        .DESCRIPTION
        Returns a Base-64 string representing a valid file, or "File not found" if the file does not exist or cannot be read.
        .PARAMETER Path
        The path to the file to convert to a base-64 string.
        .EXAMPLE
        Get-OZOFileToBase64 -Path .\README.md
        IyBPWk8gUG93ZXJTaGVsbCBNb2R1bGUgSW5zdGFsbGF... <snip>
        .LINK
        https://github.com/onezeroone-dev/OZOFiles-PowerShell-Module/blob/main/Documentation/Get-OZOFileToBase64.md
    #>
    [CmdLetBinding(SupportsShouldProcess = $true)] Param(
        [Parameter(Mandatory=$true,HelpMessage="The path to the file to convert to a base-64 string",ValueFromPipeline=$true)][String]$Path
    )
    # Determine if Path is readable
    If ((Test-OZOPath -Path $Path) -eq $true) {
        # Path is readable; convert file to base-64 string
        return [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes((Resolve-Path -Path $Path)))
    } Else {
        # Path is not readable; report
        return "File not found"
    }
}

Function Set-OZOBase64ToFile {
    <#
        .SYNOPSIS
        See description.
        .DESCRIPTION
        Writes a base-64 string to disk as a file. Returns _True_ on success and otherwise _False_.
        .PARAMETER Base64
        The base-64 string to convert.
        .PARAMETER Path
        The output file path. If the file exists, it will be overwritten.
        .EXAMPLE
        Set-OZOBase64ToFile -Base64 "IyBPWk8gUG93ZXJTaGVsbCBNb2R1bGUgSW5zdGFsbGF..." -Path .\README.md
        True
        .LINK
        https://github.com/onezeroone-dev/OZOFiles-PowerShell-Module/blob/main/Documentation/Set-OZOBase64ToFile.md
    #>
    [CmdLetBinding(SupportsShouldProcess = $true)] Param(
        [Parameter(Mandatory=$true,HelpMessage="The base-64 string",ValueFromPipeline=$true)][String]$Base64,
        [Parameter(Mandatory=$true,HelpMessage="The output file path")][String]$Path
    )
    # Split Directory from Path
    [String] $Directory = (Split-Path -Path $Path -Parent)
    # Ensure the Directory exists and is writable
    If ((Test-OZOPath -Path $Directory -Writable) -eq $true) {
        # Path
        [System.IO.File]::WriteAllBytes($Path,[Convert]::FromBase64String($Base64))
        # Determine if the file exists
        If ((Test-Path -Path $Path) -eq $true) {
            # File exists
            return $true
        } Else {
            # File does not exist
            return $false
        }
    }
}

Function Test-OZOPath {
    <#
        .SYNOPSIS
        See description.
        .DESCRIPTION
        Determines if a path exists and is readable. Optionally tests if the path is writable.
        .PARAMETER Path
        The path to test. Returns TRUE if the path exists and is readable and otherwise returns FALSE.
        .PARAMETER Writable
        Determines if the path is writable. Returns TRUE if the path is writable and otherwise returns FALSE.
        .EXAMPLE
        Test-OZOPath -Path "C:\Windows\notepad.exe"
        True
        .EXAMPLE
        Test-OZOPath -Path "C:\Windows\notepad.exe" -Writable
        False
        .LINK
        https://github.com/onezeroone-dev/OZOFiles-PowerShell-Module/blob/main/Documentation/Test-OZOPath.md
    #>
    [CmdLetBinding(SupportsShouldProcess = $true)] Param(
        [Parameter(Mandatory=$true,HelpMessage="The path to test",ValueFromPipeline=$true)][String]$Path,
        [Parameter(Mandatory=$false,HelpMessage="Test if Path is writable")][Switch]$Writable
    )
    # Booleans for readable and writable
    [Boolean] $isReadable = $false
    [Boolean] $isWritable = $false
    # Object to hold path properties
    [System.IO.FileSystemInfo] $Item = $null
    # Try to get the item
    Try {
        $Item = Get-Item -Path $Path -ErrorAction Stop
        # Success; Determine if path is a File
        If ((Test-Path -Path $Path -PathType Leaf -ErrorAction SilentlyContinue) -eq $true) {
            # File; if not read only, set readable and writable
            $isReadable = -Not $Item.IsReadOnly
            $isWritable = $Item.IsReadOnly
        } Else {
            # Directory
            [String] $TestPath = (Join-Path -Path $Path -ChildPath (New-Guid).Guid)
            # Set readable
            $isReadable = [Boolean](Get-ChildItem -Path $Path -ErrorAction SilentlyContinue)
            # Try to write a file
            Try {
                New-Item -ItemType File -Path $TestPath -ErrorAction Stop | Out-Null
                # Success; set writable to True and clean up
                $isWritable = $true
                Remove-Item -Path $TestPath -ErrorAction Stop
            } Catch {
                # Failure; set writable to False
                $isWritable = $false
            }
        }
    } Catch {
        # Failure; path does not exist or is not accessible; set readable and writable
        $isReadable = $false
        $isWritable = $false
    }
    # Determine if Writable was specified
    If ($Writable -eq $true) {
        # return Writable
        return $isWritable
    } Else {
        # return Readable
        return $isReadable
    }
}

Export-ModuleMember -Function Get-OZOChildWriteTime,Get-OZODirectorySummary,Get-OZOFileIsLocked,Get-OZOFileToBase64,Set-OZOBase64ToFile,Test-OZOPath
