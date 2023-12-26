# OpenVPN Profile Import Script

This PowerShell script automates the process of importing an OpenVPN connection profile using OpenVPN Connect.

## Usage

1. **Download OpenVPN Connect:**
   - Ensure that OpenVPN Connect is installed on your machine.

2. **Configure Script:**
   - Open the `import-openvpnprofile.ps1` script.
   - Modify the variables at the beginning of the script to specify the path to the OpenVPN Connect executable, the path to your OpenVPN configuration file (.ovpn), the name for the connection profile, and the path for the error log.

3. **Run the Script:**
   - Execute the script in a PowerShell environment.

4. **Outcome:**
   - The script will import the specified OpenVPN profile and launch OpenVPN Connect.

## Notes

- Ensure that the OpenVPN Connect executable and the OpenVPN configuration file paths are correctly set in the script.
- Check the error log for any issues during the import process.

---

*This script is provided as-is, without warranty or support. Use it at your own risk.*

README for detection.ps1

# OpenVPN Profile Detection Script

This PowerShell script is designed for detecting the success of the OpenVPN profile import process.

## Usage

1. **Configure Script:**
   - Open the `detection.ps1` script.
   - Modify the variable at the beginning of the script to specify the path to the success indicator file.

2. **Run the Script:**
   - Execute the script in a PowerShell environment.

3. **Outcome:**
   - The script checks for the presence of the success indicator file.
   - If the file exists, it indicates a successful OpenVPN profile import; otherwise, it indicates failure.

## Notes

- Ensure that the success indicator file path is correctly set in the script.
- Integrate this script into your deployment process to determine the success of the OpenVPN profile import.

---

*This script is provided as-is, without warranty or support. Use it at your own risk.*

README for remove-openvpnprofile.ps1


# OpenVPN Profile Removal Script

This PowerShell script automates the process of removing a previously imported OpenVPN connection profile using OpenVPN Connect.

## Usage

1. **Configure Script:**
   - Open the `remove-openvpnprofile.ps1` script.
   - Modify the variables at the beginning of the script to specify the path to the OpenVPN Connect executable, the name of the VPN profile to remove, and the path for the success indicator file.

2. **Run the Script:**
   - Execute the script in a PowerShell environment.

3. **Outcome:**
   - The script will remove the specified VPN profile and the associated success indicator file.

## Notes

- Ensure that the OpenVPN Connect executable path, VPN profile name, and success indicator file path are correctly set in the script.
- Check the console output for status messages.

---

*This script is provided as-is, without warranty or support. Use it at your own risk.*

