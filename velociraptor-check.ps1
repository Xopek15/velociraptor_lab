
$msi = "C:\VelociraptorLab\velociraptor-windows-client.msi"
$log = "C:\VelociraptorLab\install.log"

# Check installation file
if (-not (Test-Path $msi)) {
    Write-Host "MSI file not found"
    exit 1
}

# Check existing service
$service = Get-Service -Name Velociraptor -ErrorAction SilentlyContinue

if (-not $service) {
    # Install Velociraptor client
    $p = Start-Process msiexec.exe `
        -ArgumentList "/i `"$msi`" /qn /norestart /L*v `"$log`"" `
        -Wait -PassThru

    Write-Host "Installer exit code: $($p.ExitCode)"

    if ($p.ExitCode -notin @(0, 3010)) {
        Write-Host "Installation failed"
        exit 1
    }
}

# Check service status
Get-Service -Name Velociraptor

# Check service configuration
Get-CimInstance Win32_Service `
    -Filter "Name='Velociraptor'" |
    Select-Object Name, State, PathName

# Check connection to server
Test-NetConnection velociraptor.lab -Port 8000

# Show installation log
if (Test-Path $log) {
    Get-Content $log -Tail 15
}
