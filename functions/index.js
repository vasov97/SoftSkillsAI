const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();
const auth = admin.auth();

// Signup User
exports.signup = functions.https.onCall(async (data, context) => {
  const { fullName, email, password } = data;

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

  await db.collection("users").doc(uid).set(user);
  return { success: true, user };
});

// Get User
exports.getUserData = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  if (!uid) {
    throw new functions.https.HttpsError("unauthenticated", "Not logged in");
  }

  const doc = await db.collection("users").doc(uid).get();
  if (!doc.exists) {
    throw new functions.https.HttpsError("not-found", "User not found");
  }

  return doc.data();
});

// Reset Password
exports.sendPasswordReset = functions.https.onCall(async (data, context) => {
  const { email } = data;
  // Normally handled in Flutter with FirebaseAuth
  // If using custom email logic, generate the link here:
  const link = await auth.generatePasswordResetLink(email);
  return { success: true, link };
});
