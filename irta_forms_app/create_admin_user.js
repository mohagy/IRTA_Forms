// Script to create admin user in Firebase Authentication
// Requires Firebase Admin SDK

const admin = require('firebase-admin');
const readline = require('readline');

// Initialize Firebase Admin (you'll need to download service account key)
// For now, let's use application default credentials if available
// Or you can download service account key from Firebase Console

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

console.log('To create a user via terminal, you need Firebase Admin SDK.');
console.log('');
console.log('Option 1: Use Firebase Console (Easier)');
console.log('Go to: https://console.firebase.google.com/');
console.log('Project: irta-forms-app');
console.log('Authentication > Users > Add user');
console.log('');
console.log('Option 2: Use Firebase CLI with Admin SDK setup');
console.log('');
console.log('This script requires Firebase Admin SDK setup with service account.');
console.log('Would you like instructions for Firebase Console method instead? (y/n)');

rl.question('', (answer) => {
  if (answer.toLowerCase() === 'y') {
    console.log('');
    console.log('=== FIREBASE CONSOLE METHOD (RECOMMENDED) ===');
    console.log('');
    console.log('1. Go to: https://console.firebase.google.com/');
    console.log('2. Select project: irta-forms-app');
    console.log('3. Click: Authentication > Users');
    console.log('4. Click: Add user');
    console.log('5. Email: admin@irta.local');
    console.log('6. Password: Admin123!');
    console.log('7. Copy the User UID');
    console.log('8. Go to: Firestore Database');
    console.log('9. Create collection: users');
    console.log('10. Document ID: [paste UID]');
    console.log('11. Add field: role = "admin"');
    console.log('');
    console.log('Then login with: admin@irta.local / Admin123!');
  } else {
    console.log('');
    console.log('To use Admin SDK, you need:');
    console.log('1. Download service account key from Firebase Console');
    console.log('2. Install: npm install firebase-admin');
    console.log('3. Use the service account key to initialize admin');
    console.log('');
    console.log('The Firebase Console method is much simpler for creating one user.');
  }
  rl.close();
});


