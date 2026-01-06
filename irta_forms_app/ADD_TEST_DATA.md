# How to Add Test Data to Your Application

There are several ways to add test data to see how the application works:

## Option 1: Use the Application Form (Recommended)

The easiest way is to use the application form in the UI:

1. **Login as an applicant** (or create a test applicant account)
2. **Navigate to "New Individual IRTA"** or use the application form
3. **Fill out the form** with sample data:
   - Representative information
   - Organization details
   - Transportation information
   - **Add vehicles** (this is important for testing the Vehicle Approval page)
4. **Submit the application**

This will create real application data that you can see in:
- Individual IRTA Applications page
- Vehicle Approval page
- Dashboard

## Option 2: Add Data via Firebase Console

You can manually add application data through the Firebase Console:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Firestore Database**
4. Go to the `applications` collection
5. Click **Add Document**
6. Use this structure:

```json
{
  "irtaRef": "IRTA-2026-123456",
  "userId": "test-user-1",
  "formType": "Business IRTA",
  "applicantName": "John Smith",
  "nationality": "Guyanese",
  "purpose": "Commercial Transport",
  "submissionDate": [Firestore Timestamp],
  "status": "Submitted",
  "applicationData": {
    "formType": "Business IRTA",
    "applicantName": "John Smith",
    "representatives": [
      {
        "name": "John Smith",
        "position": "Director",
        "nationality": "Guyanese",
        "passportNumber": "P123456",
        "address": "123 Main Street, Georgetown"
      }
    ],
    "organization": {
      "firmName": "Smith Transport Services",
      "firmAddress": "123 Main Street, Georgetown",
      "legalRepresentative": "John Smith",
      "tin": "TIN123456",
      "companyRegistrationNumber": "CR12345678",
      "telephone": "+592-600-1234",
      "fax": "+592-600-1234"
    },
    "transportation": {
      "natureOfTransport": "Passenger Transport",
      "modalityOfTraffic": "Regular Route",
      "origin": "Georgetown, Guyana",
      "destination": "Federative Republic of Brazil",
      "vehicles": [
        {
          "vehiclePlate": "GAB-1234",
          "vehicleType": "Bus",
          "vehicleYear": "2020",
          "vehicleMake": "Mercedes",
          "vehicleBodyType": "Passenger Bus",
          "vehicleChassis": "WDB12345678901234",
          "vehicleAxles": "2",
          "vehicleMtc": "5000",
          "vehicleNwc": "4500",
          "vehicleTare": "8000",
          "vehicleApprovalStatus": "Pending"
        }
      ]
    }
  },
  "createdAt": [Firestore Timestamp],
  "updatedAt": [Firestore Timestamp]
}
```

## Option 3: Quick Test Data Examples

Here are some quick examples you can copy into Firebase Console:

### Example 1: Application with 2 Pending Vehicles
- Status: `Submitted`
- Vehicles: 2 vehicles with `vehicleApprovalStatus: "Pending"`

### Example 2: Application with Approved Vehicle
- Status: `Submitted`
- Vehicle: 1 vehicle with `vehicleApprovalStatus: "Approved"`

### Example 3: Application with Rejected Vehicle
- Status: `Submitted`
- Vehicle: 1 vehicle with `vehicleApprovalStatus: "Rejected"` and `vehicleApprovalComment: "Registration expired"`

### Example 4: Draft Application
- Status: `Draft`
- Vehicle: 1 vehicle with `vehicleApprovalStatus: "Pending"`

## What to Test

After adding data, you can test:

1. **Individual IRTA Applications Page** - Should show all applications
2. **Vehicle Approval Page** - Should show all vehicles from applications
3. **Application Detail Page** - Click "View" to see full application details
4. **Vehicle Approval Actions** - Approve/Reject vehicles from the Vehicle Approval page
5. **Dashboard** - Should show application statistics

## Notes

- Make sure `userId` matches an existing user in your `users` collection (or use a test user ID)
- Vehicle approval status can be: `"Pending"`, `"Approved"`, or `"Rejected"`
- Applications with status `"Draft"` won't appear in the Vehicle Approval queue (only submitted applications)
- The `irtaRef` should follow the pattern: `IRTA-YYYY-NNNNNN`

