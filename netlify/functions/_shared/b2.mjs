import {
  GetObjectCommand,
  HeadObjectCommand,
  PutObjectCommand,
  S3Client,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

let client;

function normalizeEndpoint(rawEndpoint) {
  const trimmed = String(rawEndpoint || '').trim().replace(/\/+$/, '');
  if (!trimmed) {
    throw new Error('B2_S3_ENDPOINT est absent.');
  }

  const endpoint = /^https?:\/\//i.test(trimmed)
    ? trimmed
    : `https://${trimmed}`;

  let parsed;
  try {
    parsed = new URL(endpoint);
  } catch {
    throw new Error('B2_S3_ENDPOINT est invalide.');
  }

  return parsed.origin;
}

function b2Client() {
  if (client) return client;

  const endpoint = normalizeEndpoint(process.env.B2_S3_ENDPOINT);
  const region = String(process.env.B2_REGION || '').trim();
  const accessKeyId = String(process.env.B2_KEY_ID || '').trim();
  const secretAccessKey = String(process.env.B2_APPLICATION_KEY || '').trim();

  if (!region || !accessKeyId || !secretAccessKey) {
    throw new Error('Configuration Backblaze B2 incomplète.');
  }

  client = new S3Client({
    endpoint,
    region,
    forcePathStyle: true,
    credentials: {
      accessKeyId,
      secretAccessKey,
    },
  });

  return client;
}

function bucket() {
  const value = String(process.env.B2_BUCKET || '').trim();
  if (!value) {
    throw new Error('B2_BUCKET est absent.');
  }
  return value;
}

async function streamToBuffer(stream) {
  if (!stream) return Buffer.alloc(0);

  if (typeof stream.transformToByteArray === 'function') {
    return Buffer.from(await stream.transformToByteArray());
  }

  const chunks = [];
  for await (const chunk of stream) {
    chunks.push(Buffer.from(chunk));
  }
  return Buffer.concat(chunks);
}

function isMissingObjectError(error) {
  return (
    error?.$metadata?.httpStatusCode === 404 ||
    error?.name === 'NoSuchKey' ||
    error?.name === 'NotFound'
  );
}

export async function objectExists(key) {
  try {
    await b2Client().send(
      new HeadObjectCommand({
        Bucket: bucket(),
        Key: key,
      }),
    );
    return true;
  } catch (error) {
    if (isMissingObjectError(error)) return false;
    throw error;
  }
}

export async function getBytes(key) {
  const response = await b2Client().send(
    new GetObjectCommand({
      Bucket: bucket(),
      Key: key,
    }),
  );

  return streamToBuffer(response.Body);
}

export async function getJson(key, fallback = null) {
  try {
    const bytes = await getBytes(key);
    return JSON.parse(bytes.toString('utf8'));
  } catch (error) {
    if (isMissingObjectError(error)) return fallback;
    throw error;
  }
}

export async function putBytes(key, bytes, contentType, metadata = {}) {
  await b2Client().send(
    new PutObjectCommand({
      Bucket: bucket(),
      Key: key,
      Body: bytes,
      ContentType: contentType,
      CacheControl: 'private, no-store, max-age=0',
      Metadata: Object.fromEntries(
        Object.entries(metadata).map(([name, value]) => [name, String(value)]),
      ),
    }),
  );
}

export async function putJson(key, value) {
  await putBytes(
    key,
    Buffer.from(JSON.stringify(value, null, 2), 'utf8'),
    'application/json; charset=utf-8',
  );
}

export async function createDownloadUrl(key, expiresInSeconds = 604800) {
  return getSignedUrl(
    b2Client(),
    new GetObjectCommand({
      Bucket: bucket(),
      Key: key,
      ResponseContentDisposition: 'attachment',
    }),
    { expiresIn: expiresInSeconds },
  );
}
