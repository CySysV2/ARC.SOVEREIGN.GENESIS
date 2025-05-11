# Quantum Harmonic Q: Drive Mapping Script (Production)
$drive = "Q:"
$unc = "\\Bbs\gcc.lfn.drive"
$user = "blockchainsyndicate@outlook.com"
$pass = "f0rdude+"

# Remove Q: if already mapped (handles conflicts)
if (Get-PSDrive Q -ErrorAction SilentlyContinue) {
    try { Remove-PSDrive Q -Force } catch {}
}

# Map Q: to UNC with credentials
$securePass = ConvertTo-SecureString $pass -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($user, $securePass)
New-PSDrive -Name Q -PSProvider FileSystem -Root $unc -Persist -Credential $cred

# Optionally ensure MeshSync subfolder exists
if (!(Test-Path "Q:\MeshSync")) {
    New-Item -ItemType Directory -Path "Q:\MeshSync" -Force | Out-Null
}
