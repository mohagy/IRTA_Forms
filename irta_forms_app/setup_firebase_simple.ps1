# Simple Firebase Setup - Run commands one by one
# This script helps you run the commands, but login must be done interactively

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Firebase Setup for IRTA Forms App" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Add paths
$env:Path += ";$env:APPDATA\npm;C:\Users\Administrator\AppData\Local\Pub\Cache\bin"

Write-Host "Checking installations..." -ForegroundColor Yellow
firebase --version
flutterfire --version
Write-Host ""

Write-Host "STEP 1: Login to Firebase" -ForegroundColor Green
Write-Host "Run this command (it will open your browser):" -ForegroundColor Yellow
Write-Host "  firebase login" -ForegroundColor White
Write-Host ""
Write-Host "Press any key AFTER you've logged in to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host ""
Write-Host "STEP 2: Configure FlutterFire" -ForegroundColor Green
Write-Host "Running flutterfire configure..." -ForegroundColor Yellow

Set-Location $PSScriptRoot
flutterfire configure

Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "Next: Update lib/main.dart to uncomment Firebase initialization" -ForegroundColor Yellow



