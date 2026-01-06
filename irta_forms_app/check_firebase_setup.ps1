# Check Firebase Setup Status
cd C:\xampp2\htdocs\IRTA_Forms\irta_forms_app

Write-Host "=== Firebase Setup Status ===" -ForegroundColor Cyan
Write-Host ""

if (Test-Path lib/firebase_options.dart) {
    Write-Host "✓ firebase_options.dart exists" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next: Update lib/main.dart and enable services in Firebase Console" -ForegroundColor Yellow
} else {
    Write-Host "✗ firebase_options.dart NOT found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Run: flutterfire configure" -ForegroundColor Yellow
}



