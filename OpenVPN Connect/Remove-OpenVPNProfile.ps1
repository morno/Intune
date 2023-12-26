# Specify the path to the OpenVPN Connect executable
$openVpnConnectExecutable = "C:\Program Files\OpenVPN Connect\openvpnconnect.exe"

# Specify the VPN profile name to remove
$vpnProfileToRemove = "OpenVPN"

# Specify the path for the success indicator file
$successFilePath = "C:\temp\OpenVpn-SuccessIndicator.txt"

# Check if OpenVPN Connect executable exists
if (-not (Test-Path $openVpnConnectExecutable -PathType Leaf)) {
    Write-Host "Error: OpenVPN Connect executable not found at $openVpnConnectExecutable"
    exit 1
}

# Remove the VPN profile
try {
    # Execute OpenVPN Connect with the --remove-profile option
    Start-Process -FilePath $openVpnConnectExecutable -ArgumentList "--remove-profile=$vpnProfileToRemove" -Wait

    Write-Host "VPN profile '$vpnProfileToRemove' has been successfully removed."

    # Remove the success indicator file
    Remove-Item -Path $successFilePath -Force
    Write-Host "Success indicator file '$successFilePath' has been removed."
}
catch {
    Write-Host "Error: $_.Exception.Message"
    exit 1
}
