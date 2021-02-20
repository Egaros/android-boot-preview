<#
    Cloned from SammyKrosoft/Powershell/How-To-Load-WPF-Form-XAML.ps1
    Modified & used under the MIT License (https://github.com/SammyKrosoft/PowerShell/blob/master/LICENSE.MD)
#>
#—————————————————————————————————————————————————————————————————————————————+—————————————————————
# VARIABLES
$ffmpegLocation = 'ffmpeg.exe'
$TempLocation = "$PSScriptRoot\Temp\"

# Basic settings
Set-Location $PSScriptRoot
Add-Type -AssemblyName PresentationFramework, PresentationCore, System.Windows.Forms

# Load a WPF GUI from a XAML file
[Xml] $xaml = Get-Content GUI.xaml
$tempform = [Windows.Markup.XamlReader]::Load([System.Xml.XmlNodeReader]::New($xaml))
$wpf = [Hashtable]::Synchronized(@{})
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]").Name.
    ForEach({$wpf.Add($_, $tempform.FindName($_))})

# Import GUI Control functions
Import-Module "$PSScriptRoot\ABP-Functions.ps1",
              "$PSScriptRoot\ABP-Import.ps1",
              "$PSScriptRoot\ABP-Generate.ps1",
              "$PSScriptRoot\ABP-Playback.ps1"

# Cleanup on close
$wpf.ABP.Add_Closing({Remove-Module 'ABP-*'})

# Load WPF >> Using method from https://gist.github.com/altrive/6227237
$wpf.ABP.Dispatcher.InvokeAsync({$wpf.ABP.ShowDialog()}).Wait() | Out-Null
