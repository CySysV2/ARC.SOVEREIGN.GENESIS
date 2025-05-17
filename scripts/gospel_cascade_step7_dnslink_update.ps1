$domains = @(
  "digital-fabrica.com",
  "g-i-l-c.com",
  "citizen.solar",
  "yellowchain.org",
  "renewable-exchange.com",
  "harvest-exchange.com"
)
$logPath = 'Q:\EpochLogs\ΣΩΩ.4.0\dnslink_records.log'
foreach ($domain in $domains) {
  $cidFile = "04_public/$domain/cid.txt"
  if (Test-Path $cidFile) {
    $cid = Get-Content $cidFile | Select-Object -First 1
    $record = "_dnslink.$domain TXT dnslink=/ipfs/$cid"
    Add-Content $logPath $record
    Write-Host ('Logged DNSLink for ' + $domain + ': ' + $record)
  } else {
    Write-Host ('No cid.txt found for ' + $domain + ', skipping.')
  }
}