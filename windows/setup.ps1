$script_dir_name = $(Split-Path -Parent $PSCommandPath)
Set-Location $script_dir_name

function IsCommandExist($test_command) {
    if (Get-Command $test_command -ErrorAction SilentlyContinue) {
        return $true
    }
    return $false
}

# Change power config.
powercfg /h OFF
powercfg /change monitor-timeout-ac 0
powercfg /change standby-timeout-ac 0

# Disable WinRE.
reagentc /disable

# Apply custom registory settings.
reg import setup.reg

# Pass remote desktop connections.
Enable-NetFirewallRule -Group "@FirewallAPI.dll,-28752"

# Enable Sudo command.
if (IsCommandExist "sudo") {
    sudo config --enable disableInput
}

# Configure file associations.
Dism.exe /Online /Import-DefaultAppAssociations:AppAssociations.xml

# Disable folder name localization.
$target_ini = Get-ChildItem $env:USERPROFILE -Depth 2 -filter desktop.ini -Hidden
foreach ($ini in $target_ini) {
    $(Get-Content $ini.FullName) -Replace "^LocalizedResourceName", ";LocalizedResourceName" | Set-Content $ini.FullName -Force
}

# Configure Quick Access (Explorer).
$ShellObj = New-Object -ComObject shell.application
$ShellObj.Namespace($env:USERPROFILE).Self.InvokeVerb("pintohome")
$quick_access=$ShellObj.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}").Items()
$criteria = @("Pictures","Videos","Music","ピクチャ","ビデオ","ミュージック")
$target = ($quick_access | where {$_.name -in $criteria})
if ($null -ne $target) {
    $target.InvokeVerb("unpinfromhome")
}

# Restart Explorer.
taskkill /f /im explorer.exe
start explorer.exe
