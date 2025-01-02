$script_dir_name = $(Split-Path -Parent $PSCommandPath)
Set-Location $script_dir_name
$tmp_dir = Join-Path $env:TMP "dotfiles"
New-Item $tmp_dir -ItemType Directory -Force | Out-Null

function IsCommandExist($test_command) {
    if (Get-Command $test_command -ErrorAction SilentlyContinue) {
        return $true
    }
    return $false
}

# Install winget.
if (!(IsCommandExist "winget")) {
    Invoke-WebRequest -Uri https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml -OutFile "$tmp_dir\Microsoft.UI.Xaml.nupkg.zip"
    Expand-Archive "$tmp_dir\Microsoft.UI.Xaml.nupkg.zip" -DestinationPath "$tmp_dir\Microsoft.UI.Xaml.nupkg" -Force
    Add-AppxPackage -Path "$tmp_dir\Microsoft.UI.Xaml.nupkg\tools\AppX\x64\Release\*"

    Start-BitsTransfer -Source https://aka.ms/getwinget -Destination "$tmp_dir"
    Add-AppxPackage -Path "$tmp_dir\getwinget"

    Remove-Item -Path "$tmp_dir\*" -Recurse -Force
}

# Install apps.
winget import apps.json --accept-package-agreements --accept-source-agreements

# Install PSWindowsUpdate.
Get-PackageProvider -Name "NuGet" -Force
Install-Module -Name PSWindowsUpdate -Force

# Remove desktop shortcuts.
Remove-Item $env:USERPROFILE\Desktop\* -Include *.lnk
Remove-Item $env:PUBLIC\Desktop\* -Include *.lnk
