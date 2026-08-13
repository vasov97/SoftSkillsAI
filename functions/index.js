// functions/index.js
const admin = require('./admin');
const { onCall } = require('firebase-functions/v2/https');



const db = admin.firestore();
const auth = admin.auth();

// ⬅️ add this line so your scheduler export is visible
Object.assign(exports, require('./remainders'));

// v2 onCall: signup
exports.signup = onCall({ region: 'us-central1' }, async (request) => {
  const { fullName, email, password } = request.data || {};
  if (!fullName || !email || !password) throw new Error('fullName, email, password are required');

  const userRecord = await auth.createUser({ email, password });
  const uid = userRecord.uid;

  const user = {
    uid,
    fullName,
    email,
    isPremium: false,
    selectedSkills: {},
    dailyTipsSeen: 0,
    aiInteractionsUsed: 0,
    level: 1,
    badges: 0,
    lastActive: new Date(),
    createdAt: new Date(),
    activeGoals: 0,
    completedGoals: 0,
  };

  await db.collection('users').doc(uid).set(user);
  return { success: true, user };
});

// v2 onCall: getUserData
exports.getUserData = onCall({ region: 'us-central1' }, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new Error('unauthenticated');
  const doc = await db.collection('users').doc(uid).get();
  if (!doc.exists) throw new Error('not-found');
  return doc.data();
});

// v2 onCall: sendPasswordReset
exports.sendPasswordReset = onCall({ region: 'us-central1' }, async (request) => {
  const { email } = request.data || {};
  if (!email) throw new Error('email required');
  const link = await auth.generatePasswordResetLink(email);
  return { success: true, link };
});
