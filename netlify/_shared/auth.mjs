import { cert, getApps, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';

function getFirebaseApp() {
  if (getApps().length > 0) return getApps()[0];
  const raw = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
  if (!raw) {
    throw new Error('FIREBASE_SERVICE_ACCOUNT_JSON est absent.');
  }
  const serviceAccount = JSON.parse(raw);
  return initializeApp({ credential: cert(serviceAccount) });
}

export async function requireFirebaseUser(event) {
  const header = event.headers.authorization || event.headers.Authorization || '';
  const match = header.match(/^Bearer\s+(.+)$/i);
  if (!match) {
    const error = new Error('Authentification Firebase requise.');
    error.statusCode = 401;
    throw error;
  }
  const decoded = await getAuth(getFirebaseApp()).verifyIdToken(match[1], true);
  return {
    uid: decoded.uid,
    email: decoded.email || '',
    emailVerified: Boolean(decoded.email_verified),
  };
}
