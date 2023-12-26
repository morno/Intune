# Intune
Intune Scripts for deploying stuff as a intunewin file

Openvpn connect needs a config file called Config.ovpn and the intune installation command is "powershell.exe -ExecutionPolicy Bypass -File Import-OpenVPNConfig.ps1" the uninstall command is "powershell.exe -ExecutionPolicy Bypass -File Remove-OpenVPNConfig.ps1".
The installation script creates a file in C:\temp called OpenVpn-SuccessIndicator.txt its so that intune knows that its installed. the detection script looks for that file.
the uninstall command removes that file.
