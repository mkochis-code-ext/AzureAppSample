# Generate Self-Signed Certificate for Application Gateway
# This script creates a self-signed certificate for demo/testing purposes
# For production, use a proper certificate from a trusted CA

param(
    [string]$CertName = "AppGatewayCert",
    [string]$DnsName = "appgw.local",
    [string]$OutputPath,
    [string]$Password = "P@ssw0rd123!"
)

if (-not $PSBoundParameters.ContainsKey("OutputPath")) {
    $OutputPath = Join-Path -Path $PSScriptRoot -ChildPath "appgw-cert.pfx"
}
elseif (-not [System.IO.Path]::IsPathRooted($OutputPath)) {
    $OutputPath = Join-Path -Path (Get-Location) -ChildPath $OutputPath
}

$outputDirectory = Split-Path -Path $OutputPath -Parent
if (-not [string]::IsNullOrWhiteSpace($outputDirectory) -and -not (Test-Path -LiteralPath $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}

Write-Host "Generating self-signed certificate..." -ForegroundColor Cyan

# Create self-signed certificate
$cert = New-SelfSignedCertificate `
    -Subject "CN=$DnsName" `
    -DnsName $DnsName `
    -KeyAlgorithm RSA `
    -KeyLength 2048 `
    -NotBefore (Get-Date) `
    -NotAfter (Get-Date).AddYears(2) `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -FriendlyName $CertName `
    -HashAlgorithm SHA256 `
    -KeyUsage DigitalSignature, KeyEncipherment, DataEncipherment `
    -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.1")

Write-Host "Certificate created with thumbprint: $($cert.Thumbprint)" -ForegroundColor Green

# Export certificate to PFX file
$securePassword = ConvertTo-SecureString -String $Password -Force -AsPlainText
Export-PfxCertificate -Cert "Cert:\CurrentUser\My\$($cert.Thumbprint)" -FilePath $OutputPath -Password $securePassword | Out-Null

Write-Host "Certificate exported to: $OutputPath" -ForegroundColor Green

# Get base64 encoded certificate data
$certExists = Test-Path -LiteralPath $OutputPath
if (-not $certExists) {
    throw "Failed to export certificate to $OutputPath."
}
$absoluteOutputPath = (Resolve-Path -Path $OutputPath).Path
$certBytes = [System.IO.File]::ReadAllBytes($absoluteOutputPath)
$certBase64 = [System.Convert]::ToBase64String($certBytes)

Write-Host "`nTo use this certificate with Terraform, add these to your terraform.tfvars:" -ForegroundColor Yellow
Write-Host "ssl_certificate_data     = `"$certBase64`""
Write-Host "ssl_certificate_password = `"$Password`""

# Clean up certificate from store
Remove-Item -Path "Cert:\CurrentUser\My\$($cert.Thumbprint)" -Force

Write-Host "`nCertificate removed from certificate store." -ForegroundColor Green
Write-Host "IMPORTANT: This is a self-signed certificate for demo purposes only!" -ForegroundColor Red
