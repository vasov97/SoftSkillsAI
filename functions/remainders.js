
// functions/remainders.js
const admin = require('./admin');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { onRequest } = require('firebase-functions/v2/https');
const { CloudTasksClient } = require('@google-cloud/tasks');
const { onCall } = require('firebase-functions/v2/https');

const db = admin.firestore();
const messaging = admin.messaging();

// ---------- Shared config ----------
const REGION = 'us-central1';
const PROJECT_ID = process.env.GCLOUD_PROJECT;
const QUEUE_ID = process.env.SUBTASK_QUEUE_ID || 'subtask-notify-queue';
const DEFAULT_SEND_URL = `https://${REGION}-${PROJECT_ID}.cloudfunctions.net/sendSubtaskNotification`;
const SEND_URL = process.env.SEND_SUBTASK_URL || DEFAULT_SEND_URL;
const TASK_SA_EMAIL = process.env.TASK_SA_EMAIL || `${PROJECT_ID}@appspot.gserviceaccount.com`;

const tasksClient = new CloudTasksClient();

// ---------- Token helpers ----------
async function getUserTokens(uid) {
  // Preferred: users/{uid}/deviceTokens/*
  const snap = await db.collection('users').doc(uid).collection('deviceTokens').get();
  let tokens = snap.docs.map(d => (d.data().token || d.data().fcmToken)).filter(Boolean);

  // Fallback: fields on the user document
  if (!tokens.length) {
    const userDoc = await db.collection('users').doc(uid).get();
    if (userDoc.exists) {
      const u = userDoc.data() || {};
      if (Array.isArray(u.fcmTokens)) tokens = u.fcmTokens.filter(Boolean);
      else if (u.fcmToken) tokens = [u.fcmToken];
    }
  }
  
  console.log(`Found ${tokens.length} tokens for user ${uid}`);
  return tokens;
}

async function pruneTokens(uid, badTokens) {
  if (!badTokens?.length) return;
  console.log(`Pruning ${badTokens.length} invalid tokens for user ${uid}`);
  
  const tokSnap = await db.collection('users').doc(uid).collection('deviceTokens').get();
  const batch = db.batch();
  tokSnap.docs.forEach(doc => {
    const t = doc.data().token || doc.data().fcmToken;
    if (badTokens.includes(t)) batch.delete(doc.ref);
  });
  await batch.commit();
}

// ---------- Cloud Tasks helpers ----------
async function ensureQueue() {
  const parent = tasksClient.locationPath(PROJECT_ID, REGION);
  const name = tasksClient.queuePath(PROJECT_ID, REGION, QUEUE_ID);
  try {
    await tasksClient.getQueue({ name });
    console.log('Queue exists:', name);
  } catch (e) {
    if (e.code === 5 /* NOT_FOUND */) {
      await tasksClient.createQueue({
        parent,
        queue: { 
          name, 
          rateLimits: { 
            maxDispatchesPerSecond: 10,
            maxConcurrentDispatches: 10
          } 
        },
      });
      console.log('Created Cloud Tasks queue:', name);
    } else {
      console.error('Queue check error:', e);
      throw e;
    }
  }
}

async function enqueueDelayedSubtaskNotify({ uid, goalId, subtaskIndex, dedupeKey }) {
  try {
    await ensureQueue();
    const parent = tasksClient.queuePath(PROJECT_ID, REGION, QUEUE_ID);

    const payload = {
      uid,
      goalId,
      subtaskIndex,
      enqueuedAt: Date.now(),
    };

    // Dedupe task name
    const timestamp = Date.now();
    const taskName = `${goalId}-${subtaskIndex}-${dedupeKey}-${timestamp}`.toLowerCase().replace(/[^a-z0-9-]/g, '');
    const scheduleTime = { seconds: Math.floor(Date.now() / 1000) + 120 }; // +2 minutes

    const request = {
      parent,
      task: {
        name: `${parent}/tasks/${taskName}`.slice(0, 500),
        scheduleTime,
        httpRequest: {
          httpMethod: 'POST',
          url: SEND_URL,
          headers: { 'Content-Type': 'application/json' },
          body: Buffer.from(JSON.stringify(payload)).toString('base64'),
          oidcToken: {
            serviceAccountEmail: TASK_SA_EMAIL,
            audience: SEND_URL,
          },
        },
      },
    };

    const [task] = await tasksClient.createTask(request);
    console.log('Task created successfully:', task.name, 'Schedule:', new Date((scheduleTime.seconds * 1000)));
    return task;
  } catch (e) {
    if (e.code === 6 /* ALREADY_EXISTS */) {
      console.log('Task already exists (dedup):', taskName);
      return null;
    }
    console.error('Error creating task:', e);
    throw e;
  }
}

// ---------- Firestore trigger: schedule notification when subtask checked ----------
exports.onGoalUpdated = onDocumentUpdated(
  { 
    region: REGION, 
    document: 'users/{uid}/goals/{goalId}', 
    concurrency: 50 
  },
  async (event) => {
    const { uid, goalId } = event.params;
    const before = event.data.before.data() || {};
    const after = event.data.after.data() || {};

    console.log(`Goal updated: ${goalId} for user: ${uid}`);

    const beforeArr = Array.isArray(before.subtasksDone) ? before.subtasksDone : [];
    const afterArr = Array.isArray(after.subtasksDone) ? after.subtasksDone : [];
    
    if (!afterArr.length) {
      console.log('No subtasks in afterArr, skipping');
      return;
    }

    // CRITICAL: Check if subtasksDone actually changed
    if (JSON.stringify(beforeArr) === JSON.stringify(afterArr)) {
      console.log('subtasksDone array unchanged, skipping');
      return;
    }

    // Server-only guard array - prevents duplicate notifications
    const beforeNotified = Array.isArray(before.subtaskNotified) ? before.subtaskNotified : [];
    const afterNotified = Array.isArray(after.subtaskNotified) ? after.subtaskNotified : [];

    const flippedTrue = [];
    const maxLen = Math.max(beforeArr.length, afterArr.length);
    
    for (let i = 0; i < maxLen; i++) {
      const wasDone = Boolean(beforeArr[i]);
      const nowDone = Boolean(afterArr[i]);
      const wasNotified = Boolean(beforeNotified[i]);
      const nowNotified = Boolean(afterNotified[i]);
      
      // Only trigger if subtask flipped from false to true AND not already notified
      if (!wasDone && nowDone && !wasNotified && !nowNotified) {
        flippedTrue.push(i);
      }
      
      // Log for debugging
      if (!wasDone && nowDone) {
        if (wasNotified || nowNotified) {
          console.log(`Subtask ${i} checked but already notified (was: ${wasNotified}, now: ${nowNotified}), skipping`);
        }
      }
    }

    if (!flippedTrue.length) {
      console.log('No newly checked subtasks found that need notification');
      return;
    }

    console.log(`Found ${flippedTrue.length} newly checked subtasks to notify:`, flippedTrue);

    // DON'T mark as notified yet - let sendSubtaskNotification do it after sending
    // This way if the task fails, it can retry
    
    // Just update timestamp
    await db
      .doc(`users/${uid}/goals/${goalId}`)
      .set({ 
        lastSubtaskToggledAt: admin.firestore.FieldValue.serverTimestamp() 
      }, { merge: true });

    const dedupeKey = `${event.id || Date.now()}`;
    
    // Enqueue tasks
    const results = await Promise.allSettled(
      flippedTrue.map((i) =>
        enqueueDelayedSubtaskNotify({ uid, goalId, subtaskIndex: i, dedupeKey })
      )
    );

    // Log results
    results.forEach((result, idx) => {
      if (result.status === 'rejected') {
        console.error(`Failed to enqueue task for subtask ${flippedTrue[idx]}:`, result.reason);
      }
    });

    console.log('Successfully enqueued +2min tasks', { uid, goalId, indices: flippedTrue });
  }
);

// ---------- HTTPS endpoint: sends notification after 2 minutes ----------
exports.sendSubtaskNotification = onRequest(
  { 
    region: REGION, 
    cors: false, 
    concurrency: 100,
    invoker: 'private' // Only Cloud Tasks can invoke
  },
  async (req, res) => {
    try {
      console.log('sendSubtaskNotification triggered', req.body);

      const { uid, goalId, subtaskIndex } = req.body || {};
      
      if (!uid || !goalId || typeof subtaskIndex !== 'number') {
        console.error('Invalid request body:', req.body);
        return res.status(400).send('bad-request');
      }

      const goalRef = db.doc(`users/${uid}/goals/${goalId}`);
      const snap = await goalRef.get();
      
      if (!snap.exists) {
        console.log('Goal not found:', goalId);
        return res.status(404).send('not-found');
      }

      const data = snap.data() || {};
      const doneArr = Array.isArray(data.subtasksDone) ? data.subtasksDone : [];
      const notified = Array.isArray(data.subtaskNotified) ? data.subtaskNotified : [];

      // Check if still checked
      if (!doneArr[subtaskIndex]) {
        console.log('Subtask unchecked before notification sent', { uid, goalId, subtaskIndex });
        return res.status(200).send('skipped-unchecked');
      }
      
      // Check if already notified
      if (notified[subtaskIndex]) {
        console.log('Already notified for this subtask', { uid, goalId, subtaskIndex });
        return res.status(200).send('skipped-duplicate');
      }

      // Get user tokens
      const tokens = await getUserTokens(uid);
      
      if (!tokens.length) {
        console.log('No FCM tokens found for user', { uid });
        await markNotified(goalRef, subtaskIndex);
        return res.status(200).send('no-tokens');
      }

      // Build notification
      const title = 'Nice progress! ✅';
      const subtaskText = (Array.isArray(data.subtasks) && data.subtasks[subtaskIndex])
        ? String(data.subtasks[subtaskIndex])
        : 'a subtask';
      const body = `You checked: ${subtaskText}`;

      console.log(`Sending notification to ${tokens.length} devices`, { title, body });

      // Send notification
      // Send FCM notification with proper channel configuration
      const message = {
        tokens,
        notification: { title, body },
        data: {
          type: 'SUBTASK_CHECKED',
          goalId: String(goalId),
          subtaskIndex: String(subtaskIndex),
          click_action: 'FLUTTER_NOTIFICATION_CLICK'
        },
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            clickAction: 'FLUTTER_NOTIFICATION_CLICK',
            channelId: 'default_channel', // CRITICAL: Must match Flutter app
            priority: 'high',
            defaultSound: true,
            defaultVibrateTimings: true,
          },
          ttl: 3600000, // 1 hour in milliseconds
        },
        apns: {
          payload: { 
            aps: { 
              sound: 'default', 
              'thread-id': 'subtask-checked',
              'content-available': 1,
              alert: {
                title,
                body
              }
            } 
          },
          headers: { 
            'apns-push-type': 'alert',
            'apns-priority': '10'
          },
        },
      };

      console.log('Sending FCM message:', JSON.stringify(message, null, 2));
      const resp = await messaging.sendEachForMulticast(message);

      console.log(`Notification sent. Success: ${resp.successCount}, Failed: ${resp.failureCount}`);

      // Prune invalid tokens
      const bad = [];
      resp.responses.forEach((r, i) => {
        if (!r.success) {
          console.error(`Failed to send to token ${i}:`, r.error);
          const code = r.error?.code;
          if (code === 'messaging/registration-token-not-registered' ||
              code === 'messaging/invalid-registration-token') {
            bad.push(tokens[i]);
          }
        }
      });
      
      if (bad.length > 0) {
        await pruneTokens(uid, bad);
      }

      // Mark as notified
      await markNotified(goalRef, subtaskIndex);

      return res.status(200).json({ 
        success: true,
        successCount: resp.successCount,
        failureCount: resp.failureCount
      });
      
    } catch (e) {
      console.error('sendSubtaskNotification error:', e);
      return res.status(500).json({ error: e.message });
    }
  }
);

async function markNotified(goalRef, index) {
  const doc = await goalRef.get();
  const data = doc.data() || {};
  const arr = Array.isArray(data.subtaskNotified) ? data.subtaskNotified.slice() : [];
  arr[index] = true;
  await goalRef.set(
    { 
      subtaskNotified: arr, 
      lastNotifiedAt: admin.firestore.FieldValue.serverTimestamp() 
    },
    { merge: true }
  );
  console.log(`Marked subtask ${index} as notified in goal ${goalRef.id}`);
}

// ======================================================================
// CRON job for stale goals
// ======================================================================
exports.remindStaleGoals = onSchedule(
  { 
    schedule: '*/2 * * * *', 
    timeZone: 'Europe/Belgrade', 
    region: REGION 
  },
  async () => {
    console.log('remindStaleGoals started');
    
    const now = admin.firestore.Timestamp.now();
    const cutoff = admin.firestore.Timestamp.fromMillis(now.toMillis() - 2 * 60 * 1000);
    const lower = admin.firestore.Timestamp.fromMillis(now.toMillis() - 30 * 60 * 1000);

    const inferUidFromPath = (path) => /^users\/([^/]+)\//.exec(path)?.[1] ?? null;
    const alreadyNotified = (data) =>
      data.lastNotifiedAt && data.lastProgressAt &&
      data.lastNotifiedAt.toMillis() >= data.lastProgressAt.toMillis();

    const goalsSnap = await db.collectionGroup('goals')
      .where('isActive', '==', true)
      .where('lastProgressAt', '>=', lower)
      .where('lastProgressAt', '<=', cutoff)
      .get();

    const perUser = new Map();
    const add = (uid, msg, ref) => {
      if (!perUser.has(uid)) perUser.set(uid, { msgs: [], refs: [] });
      const bucket = perUser.get(uid);
      bucket.msgs.push(msg);
      bucket.refs.push(ref);
    };

    for (const d of goalsSnap.docs) {
      const data = d.data();
      if (alreadyNotified(data)) continue;
      const uid = data.userId || inferUidFromPath(d.ref.path);
      if (!uid) continue;
      add(uid, `Goal "${data.title || d.id}" hasn't been updated in a while.`, d.ref);
    }

    let notifiedRefsCount = 0;

    for (const [uid, bucket] of perUser.entries()) {
      const tokens = await getUserTokens(uid);
      if (!tokens.length) {
        console.log(`No tokens for ${uid}; skipping ${bucket.refs.length} docs`);
        continue;
      }

      const body = bucket.msgs.length === 1
        ? bucket.msgs[0]
        : `${bucket.msgs.length} items need your attention. Tap to check in.`;

      const resp = await messaging.sendEachForMulticast({
        tokens,
        notification: { title: 'Time to check your goal!', body },
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            clickAction: 'FLUTTER_NOTIFICATION_CLICK',
            channelId: 'default_channel',
          },
          ttl: 3600000,
        },
        apns: {
          payload: { 
            aps: { 
              sound: 'default', 
              'thread-id': 'goal-reminder', 
              'content-available': 1 
            } 
          },
          headers: { 'apns-push-type': 'alert' },
        },
        data: { type: 'GOAL_REMINDER' },
      });

      const bad = [];
      resp.responses.forEach((r, i) => {
        const code = r.error?.code;
        if (!r.success && (
          code === 'messaging/registration-token-not-registered' ||
          code === 'messaging/invalid-registration-token'
        )) bad.push(tokens[i]);
      });
      await pruneTokens(uid, bad);

      const batch = db.batch();
      const nowTs = admin.firestore.Timestamp.now();
      bucket.refs.forEach(ref => batch.set(ref, { lastNotifiedAt: nowTs }, { merge: true }));
      await batch.commit();
      notifiedRefsCount += bucket.refs.length;
    }

    console.log('remindStaleGoals completed', {
      goalsQueried: goalsSnap.size,
      usersNotified: perUser.size,
      notifiedRefsCount,
    });
  }
);


// ---------- HTTPS Callable: Send progress notification based on goal completion ----------
exports.sendProgressNotification = onCall(
  { region: REGION },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new https.HttpsError('unauthenticated', 'User not authenticated');

    try {
      console.log('Calculating progress for user:', uid);

      // Get all active goals for the user
      const goalsSnap = await db
        .collection('users')
        .doc(uid)
        .collection('goals')
        .where('isActive', '==', true)
        .get();

      if (goalsSnap.empty) {
        console.log('No active goals found for user');
        return { success: false, message: 'No active goals' };
      }

      // Calculate average progress across all goals
      let totalProgress = 0;
      let goalCount = 0;

      goalsSnap.docs.forEach((doc) => {
        const data = doc.data();
        const subtasksDone = Array.isArray(data.subtasksDone) ? data.subtasksDone : [];
        const subtasksTotal = Array.isArray(data.subtasks) ? data.subtasks.length : 0;

        if (subtasksTotal > 0) {
          const doneCount = subtasksDone.filter((d) => d === true).length;
          const progress = (doneCount / subtasksTotal) * 100;
          totalProgress += progress;
          goalCount++;
        }
      });

      const averageProgress = goalCount > 0 ? totalProgress / goalCount : 0;
      console.log(`Average progress: ${averageProgress.toFixed(1)}% across ${goalCount} goals`);

      // Determine message based on progress
      let title = '';
      let body = '';

      if (averageProgress < 20) {
        title = '😔 Did you give up?';
        body = "You're at " + averageProgress.toFixed(0) + "% progress. Let's get back on track!";
      } else if (averageProgress < 40) {
        title = '💪 Keep pushing!';
        body = "You're at " + averageProgress.toFixed(0) + "%. You've started, now keep going!";
      } else if (averageProgress < 60) {
        title = '🔥 Great momentum!';
        body = "You're at " + averageProgress.toFixed(0) + "%. Halfway there, don't stop now!";
      } else if (averageProgress < 80) {
        title = '⭐ Almost there!';
        body = "You're at " + averageProgress.toFixed(0) + "%. You're so close to the finish line!";
      } else {
        title = '🎉 Outstanding work!';
        body = "You're at " + averageProgress.toFixed(0) + "%. You're crushing your goals!";
      }

      // Get user tokens
      const tokens = await getUserTokens(uid);

      if (!tokens.length) {
        console.log('No FCM tokens found for user');
        return { success: false, message: 'No FCM tokens' };
      }

      // Send notification
      const resp = await messaging.sendEachForMulticast({
        tokens,
        notification: { title, body },
        data: {
          type: 'PROGRESS_UPDATE',
          progress: String(averageProgress.toFixed(1)),
        },
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            clickAction: 'FLUTTER_NOTIFICATION_CLICK',
            channelId: 'default_channel',
            priority: 'high',
          },
          ttl: 3600000,
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              alert: { title, body },
            },
          },
          headers: { 'apns-push-type': 'alert' },
        },
      });

      console.log(`Progress notification sent. Success: ${resp.successCount}, Failed: ${resp.failureCount}`);

      // Prune invalid tokens
      const bad = [];
      resp.responses.forEach((r, i) => {
        const code = r.error?.code;
        if (!r.success && (
          code === 'messaging/registration-token-not-registered' ||
          code === 'messaging/invalid-registration-token'
        )) bad.push(tokens[i]);
      });
      await pruneTokens(uid, bad);

      return {
        success: true,
        progress: averageProgress.toFixed(1),
        message: body,
        successCount: resp.successCount,
      };
    } catch (e) {
      console.error('sendProgressNotification error:', e);
      throw new https.HttpsError('internal', e.message);
    }
  }
);