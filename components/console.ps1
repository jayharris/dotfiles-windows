# Utilities to manage PowerShell Consoles
# Based on code from ConCFG: https://github.com/lukesampson/concfg/

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.ComTypes;

namespace dotfiles {
    public class ShortcutManager {
        public static void ResetConsoleProperties(string path) {
            if (!System.IO.File.Exists(path)) { return; }

            var file = new ShellLink() as IPersistFile;
            if (file == null) { return; }

            file.Load(path, 2 /* STGM_READWRITE */);
            var data = (IShellLinkDataList) file;

            data.RemoveDataBlock( 0xA0000002 /* NT_CONSOLE_PROPS_SIG */);
            file.Save(path, true);

            Marshal.ReleaseComObject(data);
            Marshal.ReleaseComObject(file);
        }
    }

    [ComImport, Guid("00021401-0000-0000-C000-000000000046")]
    class ShellLink { }

    [ComImport, Guid("45e2b4ae-b1c3-11d0-b92f-00a0c90312e1"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    interface IShellLinkDataList {
        void AddDataBlock(IntPtr pDataBlock);
        void CopyDataBlock(uint dwSig, out IntPtr ppDataBlock);
        void RemoveDataBlock(uint dwSig);
        void GetFlags(out uint pdwFlags);
        void SetFlags(uint dwFlags);
    }
}
'@

function Verify-Elevated {
    # Get the ID and security principal of the current user account
    $myIdentity=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $myPrincipal=new-object System.Security.Principal.WindowsPrincipal($myIdentity)
    # Check to see if we are currently running "as Administrator"
    return $myPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Verify-PowershellShortcut {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string] $Path
    )

    if (!(Test-Path $Path -PathType Leaf)) { return $false }
    if ([System.IO.Path]::GetExtension($Path) -ne ".lnk") { return $false; }

    $shell = New-Object -COMObject WScript.Shell -Strict
    $shortcut = $shell.CreateShortcut("$(Resolve-Path $Path)")

    $result = ($shortcut.TargetPath -eq "$env:WINDIR\system32\WindowsPowerShell\v1.0\powershell.exe") -or `
      ($shortcut.TargetPath -eq "$env:WINDIR\syswow64\WindowsPowerShell\v1.0\powershell.exe")
    [Runtime.Interopservices.Marshal]::ReleaseComObject($shortcut) | Out-Null
    return $result
}

function Verify-BashShortcut {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string] $Path
    )

    if (!(Test-Path $Path -PathType Leaf)) { return $false }
    if ([System.IO.Path]::GetExtension($Path) -ne ".lnk") { return $false; }

    $shell = New-Object -COMObject WScript.Shell -Strict
    $shortcut = $shell.CreateShortcut("$(Resolve-Path $Path)")

    $result = ($shortcut.TargetPath -eq "$env:WINDIR\system32\bash.exe")
    [Runtime.Interopservices.Marshal]::ReleaseComObject($shortcut) | Out-Null
    return $result
}

function Reset-PowerShellShortcut {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string] $Path
    )

    if (!(Test-Path $Path)) { Return }

    if (Test-Path $Path -PathType Container) {
        Get-ChildItem $Path | ForEach {
            Reset-PowerShellShortcut $_.FullName
        }
        Return
    }

    if (Verify-PowershellShortcut $Path) {
        $filePath = Resolve-Path $Path

        try {
            [dotfiles.ShortcutManager]::ResetConsoleProperties($filePath)
            $shell = New-Object -COMObject WScript.Shell -Strict
            $shortcut = $shell.CreateShortcut("$(Resolve-Path $path)")
            $shortcut.Arguments = "-nologo"
            $shortcut.Save()
            [Runtime.Interopservices.Marshal]::ReleaseComObject($shortcut) | Out-Null
            [Runtime.Interopservices.Marshal]::ReleaseComObject($shell) | Out-Null
        }
        catch [UnauthorizedAccessException] {
            Write-Warning "warning: admin permission is required to remove console props from $path"
        }
    }
}

function Reset-BashShortcut {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string] $Path
    )

    if (!(Test-Path $Path)) { Return }

    if (Test-Path $Path -PathType Container) {
        Get-ChildItem $Path | ForEach {
            Reset-BashShortcut $_.FullName
        }
        Return
    }

    if (Verify-BashShortcut $Path) {
        $filePath = Resolve-Path $Path

        try {
            [dotfiles.ShortcutManager]::ResetConsoleProperties($filePath)
            $shell = New-Object -COMObject WScript.Shell -Strict
            $shortcut = $shell.CreateShortcut("$(Resolve-Path $path)")
            $shortcut.Save()
            [Runtime.Interopservices.Marshal]::ReleaseComObject($shortcut) | Out-Null
            [Runtime.Interopservices.Marshal]::ReleaseComObject($shell) | Out-Null
        }
        catch [UnauthorizedAccessException] {
            Write-Warning "warning: admin permission is required to remove console props from $path"
        }
    }
}

function Reset-AllPowerShellShortcuts {
    @(`
        "$ENV:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs",`
        "$ENV:USERPROFILE\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\StartMenu",`
        "$ENV:USERPROFILE\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar",`
        "$ENV:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"`
    ) | ForEach { Reset-PowerShellShortcut $_ }
}

function Reset-AllBashShortcuts {
    @(`
        "$ENV:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs",`
        "$ENV:USERPROFILE\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\StartMenu",`
        "$ENV:USERPROFILE\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar",`
        "$ENV:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"`
    ) | ForEach { Reset-BashShortcut $_ }
}

function Convert-ConsoleColor {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$rgb
    )

    if ($rgb -notmatch '^#[\da-f]{6}$') {
        write-Error "Invalid color '$rgb' should be in RGB hex format, e.g. #000000"
        Return
    }
    $num = [Convert]::ToInt32($rgb.substring(1,6), 16)
    $bytes = [BitConverter]::GetBytes($num)
    [Array]::Reverse($bytes, 0, 3)
    return [BitConverter]::ToInt32($bytes, 0)
}

