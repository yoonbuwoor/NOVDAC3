import crypto from 'node:crypto';

import {
  deleteFirebaseUser,
  requireFirebaseUser,
} from './_shared/auth.mjs';
import {
  deleteKeys,
  getJson,
  listKeys,
} from './_shared/b2.mjs';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Authorization, Content-Type',
  'Access-Control-Allow-Methods': 'DELETE, OPTIONS',
  'Cache-Control': 'no-store',
  'Content-Type': 'application/json; charset=utf-8',
  'X-Content-Type-Options': 'nosniff',
};

function response(statusCode, body) {
  return {
    statusCode,
    headers: corsHeaders,
    body: JSON.stringify(body),
  };
}

function progressKey(email) {
  if (!email) return null;
  const learnerId = crypto
    .createHash('sha256')
    .update(email.trim().toLowerCase())
    .digest('hex');
  return `academy-progress/${learnerId}.json`;
}

async function certificateVerificationKeys(certificateKeys) {
  const verificationKeys = [];
  const metadataKeys = certificateKeys.filter(
    (key) => key.endsWith('/metadata.json') || key.endsWith('/current.json'),
  );

  for (const key of metadataKeys) {
    try {
      const metadata = await getJson(key, null);
      const certificateId = String(metadata?.certificateId || '').trim();
      if (certificateId) {
        verificationKeys.push(`certification/verification/${certificateId}.json`);
      }
    } catch (error) {
      console.warn('account-delete-api metadata', key, error?.message || error);
    }
  }

  return verificationKeys;
}

export async function handler(event) {
  if (event.httpMethod === 'OPTIONS') return response(204, {});
  if (event.httpMethod !== 'DELETE') {
    return response(405, { message: 'Méthode non autorisée.' });
  }

  try {
    const user = await requireFirebaseUser(event);
    const prefixes = [
      `certification/results/${user.uid}/`,
      `certification/cooldowns/${user.uid}/`,
      `certification/sessions/${user.uid}/`,
      `certification/certificates/${user.uid}/`,
    ];

    const prefixLists = await Promise.all(prefixes.map((prefix) => listKeys(prefix)));
    const certificateKeys = prefixLists[3] || [];
    const verificationKeys = await certificateVerificationKeys(certificateKeys);
    const keys = [
      ...prefixLists.flat(),
      ...verificationKeys,
      progressKey(user.email),
    ].filter(Boolean);

    const deletedObjects = await deleteKeys(keys);

    // La suppression Firebase est volontairement effectuée en dernier. En cas
    // d’échec de stockage, le compte reste disponible pour permettre un nouvel
    // essai sans laisser de données orphelines impossibles à atteindre.
    await deleteFirebaseUser(user.uid);

    return response(200, {
      ok: true,
      message: 'Compte et données associés supprimés.',
      deletedObjects,
    });
  } catch (error) {
    console.error('account-delete-api', error);
    return response(error.statusCode || 500, {
      code: error.code || 'account-deletion-failed',
      message:
        error.message ||
        'Impossible de supprimer le compte et les données pour le moment.',
    });
  }
}
