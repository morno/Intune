# Specify the path for the success indicator file
$successFilePath = "C:\temp\OpenVpn-SuccessIndicator.txt"

# Check if the success indicator file exists
if (Test-Path $successFilePath -PathType Leaf) {
    Write-Host "Detection: Success indicator found. OpenVPN Connect is installed and configured."
    exit 0  # Exit with code 0 to indicate success
} else {
    Write-Host "Detection: Success indicator not found. OpenVPN Connect is not installed or configured."
    exit 1  # Exit with code 1 to indicate failure
}
