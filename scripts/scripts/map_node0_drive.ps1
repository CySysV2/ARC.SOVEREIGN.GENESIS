# PowerShell script to persistently map Node0 sync folder as Q: for stack sync
# Author: Cascade AI (Windsurf)
# Last updated: 2025-05-09
#
# Security Note: For production, consider using Windows Credential Manager or a secure vault for passwords.

$drive = 'Q:'
$share = '\\Bbs\gcc.lfn.drive'
$user = 'blockchainsyndicate@outlook.com'
$pass = 'f0rdude+'

# Remove existing mapping if present
try {
    net use $drive /delete /yes | Out-Null
} catch {}

# Map the drive persistently
$netUseCmd = "net use $drive $share /user:$user $pass /persistent:yes"
Invoke-Expression $netUseCmd

# Verify mapping
$mapping = net use | Select-String $drive
if ($mapping) {
    Write-Host "Drive $drive mapped successfully to $share."
} else {
    Write-Host "Failed to map drive $drive. Check credentials and network connectivity."
}
