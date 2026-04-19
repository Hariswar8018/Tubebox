const { onDocumentWritten } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

// Jab bhi users/{userId} document ka earnings update hoga
exports.syncUserEarnings = onDocumentWritten("users/{userId}", async (event) => {
  const userId = event.params.userId;

  // Latest data nikal
  const newValue = event.data?.after.data();
  if (!newValue) return;

  const earnings = newValue.earnings || 0;

  // Ledger collection me same userId ka document update karo
  await admin.firestore().collection("ledger").doc(userId).set(
    {
      userId: userId,
      totalEarnings: earnings,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );
});
