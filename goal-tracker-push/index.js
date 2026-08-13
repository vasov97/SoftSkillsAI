require('dotenv').config({ path: '../.env' });
const admin = require('firebase-admin');
const fs = require('fs');

// Load service account key
const serviceAccount = require('./serviceAccountKey.json');

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const messaging = admin.messaging();

// Replace this with a real device token
const userFcmToken = 'e7sIHLmDTviUCwCXymzbBQ:APA91bG1diryQDwy2jaAEYDn9N32mgV-WA0fJza8vmRBlguJtuvmZ0yrxLKbCZv7DiFhuRdnTwMEfmffUwuESuvoZyIh4wPNFS8WpWiGbgG6_ylCdcId-4E';

// Notification content
const message = {
  token: userFcmToken,
  notification: {
    title: 'Time to check your goal!',
    body: 'You haven’t updated your progress in a while. How’s it going?',
  },
  android: {
    priority: 'high',
    notification: {
      sound: 'default',
      clickAction: 'FLUTTER_NOTIFICATION_CLICK',
    },
  },
  apns: {
    payload: {
      aps: {
        sound: 'default',
      },
    },
  },
};

// Send the notification
messaging
  .send(message)
  .then((response) => {
    console.log('✅ Successfully sent notification:', response);
  })
  .catch((error) => {
    console.error('❌ Error sending notification:', error);
  });
