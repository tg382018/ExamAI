import admin from 'firebase-admin';

let initialized = false;

export function initFirebase() {
    if (initialized) return;
    const serviceAccount = JSON.parse(
        process.env.FIREBASE_SERVICE_ACCOUNT_JSON || '{}'
    );
    if (!serviceAccount.project_id) {
        console.warn('[Firebase] FIREBASE_SERVICE_ACCOUNT_JSON is not set — push notifications disabled.');
        return;
    }
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
    });
    initialized = true;
    console.log('[Firebase] Admin SDK initialized.');
}

export async function sendPushNotification(tokens: string[], title: string, body: string, data?: Record<string, string>) {
    if (!initialized) return;
    if (tokens.length === 0) return;
    try {
        const response = await admin.messaging().sendEachForMulticast({
            tokens,
            notification: { title, body },
            data: data || {},
        });
        console.log(`[FCM] Sent: ${response.successCount} success, ${response.failureCount} failures`);
    } catch (err) {
        console.error('[FCM] Error sending push:', err);
    }
}
