# Specify the path to the OpenVPN Connect executable
$openVpnConnectExecutable = "C:\Program Files\OpenVPN Connect\openvpnconnect.exe"

# Specify the path to your OpenVPN configuration file (.ovpn)
$profileFilePath = "$PSScriptRoot\Config.ovpn"

# Name the connection profile
$vpnname = "BohusVPN"

# Specify the path for the error log
$errorLogPath = "C:\temp\OpenVpn-ErrorLog.txt"

# Function to display and log errors
function Log-Error {
    param([string]$errorMessage)
    Write-Host "Error: $errorMessage"
    Add-Content -Path $errorLogPath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $errorMessage"
}

# Check if OpenVPN Connect executable exists
try {
    if (-not (Test-Path $openVpnConnectExecutable -PathType Leaf)) {
        throw "OpenVPN Connect executable not found at $openVpnConnectExecutable"
    }

    # Check if the OpenVPN profile file exists
    if (-not (Test-Path $profileFilePath -PathType Leaf)) {
        throw "OpenVPN profile file not found at $profileFilePath"
    }

    # Start OpenVPN Connect and import the profile
    Start-Process -FilePath $openVpnConnectExecutable -ArgumentList "--import-profile=$profileFilePath --name=$vpnname" -Wait

    Write-Host "OpenVPN Connect import completed."

    # Start OpenVPN Connect
    Start-Process -FilePath $openVpnConnectExecutable

    Write-Host "OpenVPN Connect has been launched."
}
catch {
    Log-Error -errorMessage $_.Exception.Message
    exit 1
}

# Indicate success by creating a file
$successFilePath = "C:\temp\OpenVpn-SuccessIndicator.txt"
New-Item -Path $successFilePath -ItemType File -Force