import crypto from 'node:crypto';

function secret() {
  const value = process.env.EXAM_SIGNING_SECRET;
  if (!value || value.length < 32) {
    throw new Error('EXAM_SIGNING_SECRET doit contenir au moins 32 caractères.');
  }
  return value;
}

function encode(value) {
  return Buffer.from(value).toString('base64url');
}

export function signExamToken(payload) {
  const body = encode(JSON.stringify(payload));
  const signature = crypto
    .createHmac('sha256', secret())
    .update(body)
    .digest('base64url');
  return `${body}.${signature}`;
}

export function verifyExamToken(token) {
  const [body, signature] = String(token || '').split('.');
  if (!body || !signature) throw new Error('Jeton d’examen invalide.');
  const expected = crypto
    .createHmac('sha256', secret())
    .update(body)
    .digest('base64url');
  const valid = crypto.timingSafeEqual(
    Buffer.from(signature),
    Buffer.from(expected),
  );
  if (!valid) throw new Error('Signature de l’examen invalide.');
  const payload = JSON.parse(Buffer.from(body, 'base64url').toString('utf8'));
  if (!payload.exp || Date.now() > payload.exp) {
    throw new Error('La session d’examen a expiré.');
  }
  return payload;
}

export function randomId(bytes = 16) {
  return crypto.randomBytes(bytes).toString('hex');
}
