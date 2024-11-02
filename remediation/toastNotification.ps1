<#
Version: 1.0
Author: Jannik Reinhard (jannikreinhard.com)
Script: Get-PendingRebootNotificationRemediation
Description:
Remediation script to display toast notification for pending reboot
Release notes:
Version 1.0: Init
#>

function Register-NotificationApp {
    param (
        [string]$AppID,
        [string]$AppDisplayName
    )

    [int]$ShowInSettings      = 0
    [int]$IconBackgroundColor = 0

    $IconUri          = "C:\Windows\ImmersiveControlPanel\images\logo.png"
    $AppRegPath       = "HKCU:\Software\Classes\AppUserModelId"
    $RegPath          = "$AppRegPath\$AppID"
    $NotificationsReg = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings'

    if (-not (Test-Path -Path "$NotificationsReg\$AppID")) {
        New-Item -Path "$NotificationsReg\$AppID" -Force
        New-ItemProperty -Path "$NotificationsReg\$AppID" -Name 'ShowInActionCenter' -Value 1 -PropertyType 'DWORD' -Force
    }

    if ((Get-ItemProperty -Path "$NotificationsReg\$AppID" -Name 'ShowInActionCenter' -ErrorAction SilentlyContinue).ShowInActionCenter -ne '1') {
        New-ItemProperty -Path "$NotificationsReg\$AppID" -Name 'ShowInActionCenter' -Value 1 -PropertyType 'DWORD' -Force
    }

    try {
        if (-not (Test-Path $RegPath)) {
            New-Item -Path $AppRegPath -Name $AppID -Force | Out-Null
        }

        $DisplayName = Get-ItemProperty -Path $RegPath -Name DisplayName -ErrorAction SilentlyContinue |
            Select-Object -ExpandProperty DisplayName -ErrorAction SilentlyContinue

        if ($DisplayName -ne $AppDisplayName) {
            New-ItemProperty -Path $RegPath -Name DisplayName -Value $AppDisplayName -PropertyType String -Force | Out-Null
        }

        $ShowInSettingsValue = Get-ItemProperty -Path $RegPath -Name ShowInSettings -ErrorAction SilentlyContinue |
            Select-Object -ExpandProperty ShowInSettings -ErrorAction SilentlyContinue

        if ($ShowInSettingsValue -ne $ShowInSettings) {
            New-ItemProperty -Path $RegPath -Name ShowInSettings -Value $ShowInSettings -PropertyType DWORD -Force | Out-Null
        }

        New-ItemProperty -Path $RegPath -Name iconUri -Value $IconUri -PropertyType ExpandString -Force | Out-Null
        New-ItemProperty -Path $RegPath -Name IconBackgroundColor -Value $IconBackgroundColor -PropertyType ExpandString -Force | Out-Null
    }
    catch {
        # Handle exceptions if needed
    }
}

function Create-Action {
    param (
        [string]$ActionName
    )

    $MainRegPath  = "HKCU:\SOFTWARE\Classes\$ActionName"
    $CommandPath  = "$MainRegPath\shell\open\command"
    $CmdScript    = "C:\Users\Public\Documents\$ActionName.cmd"

    New-Item -Path $CommandPath -Force
    New-ItemProperty -Path $MainRegPath -Name "URL Protocol" -Value "" -PropertyType String -Force | Out-Null
    Set-ItemProperty -Path $MainRegPath -Name "(Default)" -Value "URL:$ActionName Protocol" -Force | Out-Null
    Set-ItemProperty -Path $CommandPath -Name "(Default)" -Value $CmdScript -Force | Out-Null
}

# Encode the image in base64: https://www.base64-image.de/
$ToastImageBase64 = ""

############################################# Variables ########################################################
# Toast Text
$ToastTitle          = "Companyname IT Support"
$ToastHeadline       = "A reboot of your system is required!!"
$ToastText           = "We have installed updates on your system and a reboot is required. You should reboot your system as soon as possible. If now is the right time, perform the reboot now."
$ToastMessage        = "`nRun reboot now?"
$ToastLogoPath       = "C:\Windows\ImmersiveControlPanel\images\logo.png"
$ToastImagePath      = "$env:TEMP\ToastImage.png"
$ScriptExecutionPath = "C:\Users\Public\Documents"

################################################# Action #########################################################
$ActionScriptCmdReboot = @'
shutdown -r
'@

$ActionScriptCmdReboot | Out-File -FilePath "$ScriptExecutionPath\ActionReboot.cmd" -Force -Encoding ASCII
Create-Action -ActionName "ActionReboot"

############################################## Notification #####################################################
# Create PNG file from Base64 string
[byte[]]$Bytes = [Convert]::FromBase64String($ToastImageBase64)
[System.IO.File]::WriteAllBytes($ToastImagePath, $Bytes)

# Create toast notification XML
[xml]$Toast = @"
<toast scenario="reminder">
    <visual>
        <binding template="ToastGeneric">
            <image placement="hero" src="$ToastImagePath" />
            <image placement="appLogoOverride" hint-crop="circle" src="$ToastLogoPath" />
            <text>$ToastHeadline</text>
            <text>$ToastText</text>
            <group>
                <subgroup>
                    <text hint-style="body" hint-wrap="true">$ToastMessage</text>
                </subgroup>
            </group>
        </binding>
    </visual>
    <actions>
        <action activationType="protocol" arguments="ActionReboot:" content="Reboot Now" />
    </actions>
</toast>
"@

Register-NotificationApp -AppID $ToastTitle -AppDisplayName $ToastTitle

# Create toast notification
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null
$ToastXml = New-Object -TypeName Windows.Data.Xml.Dom.XmlDocument
$ToastXml.LoadXml($Toast.OuterXml)

# Show the toast
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($ToastTitle).Show($ToastXml)
