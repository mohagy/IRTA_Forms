# Seed Applications Script

This script creates sample application data in Firestore for testing purposes.

## What it creates:

1. **John Smith** - Business IRTA with 2 vehicles (both Pending approval)
2. **Sarah Johnson** - Business IRTA with 1 vehicle (Approved)
3. **Michael Brown** - Business IRTA with 1 vehicle (Rejected)
4. **Emily Davis** - Individual IRTA with 1 vehicle (Pending)
5. **Robert Wilson** - Business IRTA with 1 vehicle (Draft status - not submitted)

## How to run:

```bash
cd irta_forms_app
dart run scripts/seed_applications.dart
```

## What you'll see:

After running the script, you can view the sample data in:
- **Individual IRTA Applications** page - Shows all applications
- **Vehicle Approval** page - Shows all vehicles from applications
- **Dashboard** - Shows application statistics

## Notes:

- The script creates applications with complete data including:
  - Representative information
  - Organization details
  - Transportation information
  - Vehicle details with documents (mock file URLs)
- Vehicle approval statuses vary to demonstrate different states
- All applications use test user IDs (test-user-1, test-user-2, etc.)

