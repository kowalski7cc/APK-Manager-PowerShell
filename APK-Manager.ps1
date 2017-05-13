Function Invoke-APKBackup
{
    $packages = adb shell pm list packages
    Write-Host ""
    $total = $packages.Length
    Write-Host ""
    Write-Host "$total packages found."
    Write-Host "These APKs will be downloaded"
    foreach ($pkg in $packages)
    {
        Write-Host $pkg.Substring(8)
    }
    Pause
    $c = 1
    $t = $packages.Length
    foreach ($pkg in $packages)
    {   
        Clear-Host
        $cpkg = $pkg.Substring(8)
        Write-Progress -Activity "Downloading APKs from terminal" -CurrentOperation "Donwloading $cpkg ($c of $t)" -PercentComplete (($c/$t)*100)
        $c++
        $path = adb shell pm path $cpkg
        if($path -like '*priv-app*')
        {
            continue
        }
        adb pull $path.Substring(8) "$cpkg.apk"
    }
    Clear-Host
    Write-Host "Backup complete for $total items"
}

function Invoke-APKRestore
{
    $total = 0
    Write-Host "These APKs will be restored on your phone:"
    foreach($file in Get-ChildItem)
    {
        if([System.IO.Path]::GetExtension($file) -eq ".apk")
        {
            $apk = [System.IO.Path]::GetFileNameWithoutExtension($file)
            Write-Host $apk
            $total++
        }
    }
    Write-Host ""
    Write-Host "$total APKs found."
    Write-Host "These packages will be installed on your phone."
    Pause
    $c = 1
    foreach($file in Get-ChildItem)
    {
        if([System.IO.Path]::GetExtension($file) -eq ".apk")
        {
            Clear-Host
            $cfile = [System.IO.Path]::GetFileNameWithoutExtension($file)
            Write-Progress -Activity "Restoring APKs on your phone" -CurrentOperation "Installing $cfile ($c of $total)" -PercentComplete (($c/$total)*100)
            adb install $file
            $c++
        }
    }
    Clear-Host
    Write-Host "Restore complete for $total items"
}


function Remove-APKBackup
{
    $files = Get-ChildItem
    foreach($file in Get-ChildItem)
    {
        if([System.IO.Path]::GetExtension($file) -eq ".apk")
        {
            $apk = [System.IO.Path]::GetFileNameWithoutExtension($file)
            Write-Host $apk
            $total++
        }
    }
    Write-Host ""
    Write-Host "$total APKs found."
    Write-Host "These packages will be deleted permanently."
    Pause
    foreach($file in Get-ChildItem)
    {
        if([System.IO.Path]::GetExtension($file) -eq ".apk")
        {
            Clear-Host
            $cfile = [System.IO.Path]::GetFileNameWithoutExtension($file)
            Write-Progress -Activity "Deleting APKs from your PC" -CurrentOperation "Deleting $cfile ($c of $total)" -PercentComplete (($c/$total)*100)
            Remove-Item $file
            $c++
        }
    }
    Clear-Host
    Write-Host "Deleted $total items."
}


Write-Host "##############################"
Write-Host "# Android APK backup manager #"
Write-Host "#           By Kowalski7cc   #"
Write-Host "##############################"
Write-host ""
Write-Host "Waiting for phone"
adb wait-for-device
adb devices


$title = "Select operation mode"
$message = "Select if backup or restore your APKs"
$backup = New-Object System.Management.Automation.Host.ChoiceDescription "&Backup", "Copy all your APKs from your phone to your PC."
$restore = New-Object System.Management.Automation.Host.ChoiceDescription "&Restore", "Installs back your APKs to your phone."
$clean = New-Object System.Management.Automation.Host.ChoiceDescription "&Clean", "Delete backupped APKs."
$options = [System.Management.Automation.Host.ChoiceDescription[]]($backup, $restore, $clean)
$result = $host.ui.PromptForChoice($title, $message, $options, 0)
switch($result)
{
    0 {Invoke-APKBackup}
    1 {Invoke-APKRestore}
    2 {Remove-APKBackup}
}