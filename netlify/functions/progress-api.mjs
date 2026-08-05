import crypto from 'node:crypto';

import { getJson, putJson } from './_shared/b2.mjs';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
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

function cleanText(value, maxLength) {
  return String(value || '').trim().slice(0, maxLength);
}

function validEmail(value) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
}

function stringList(value, maxItems = 1000) {
  if (!Array.isArray(value)) return [];
  return [...new Set(value.map((item) => cleanText(item, 120)).filter(Boolean))]
    .slice(0, maxItems)
    .sort();
}

function scoreMap(value) {
  if (!value || typeof value !== 'object' || Array.isArray(value)) return {};
  const result = {};
  for (const [key, rawScore] of Object.entries(value).slice(0, 500)) {
    const cleanKey = cleanText(key, 120);
    const score = Math.max(0, Math.min(100000, Number(rawScore) || 0));
    if (cleanKey) result[cleanKey] = Math.round(score);
  }
  return result;
}

function mergeProgress(previous = {}, incoming = {}) {
  const previousLessons = stringList(previous.completedLessons);
  const incomingLessons = stringList(incoming.completedLessons);
  const previousMissions = stringList(previous.completedMissions);
  const incomingMissions = stringList(incoming.completedMissions);
  const previousScores = scoreMap(previous.missionScores);
  const incomingScores = scoreMap(incoming.missionScores);
  const missionScores = { ...previousScores };
  for (const [id, score] of Object.entries(incomingScores)) {
    missionScores[id] = Math.max(missionScores[id] || 0, score);
  }
  const previousQuizScores = scoreMap(previous.quizScores);
  const incomingQuizScores = scoreMap(incoming.quizScores);
  const quizScores = { ...previousQuizScores };
  for (const [id, score] of Object.entries(incomingQuizScores)) {
    quizScores[id] = Math.max(quizScores[id] || 0, score);
  }

  return {
    completedLessons: [...new Set([...previousLessons, ...incomingLessons])].sort(),
    completedMissions: [...new Set([...previousMissions, ...incomingMissions])].sort(),
    missionScores,
    quizScores,
    xp: Math.max(120, Number(previous.xp) || 0, Number(incoming.xp) || 0),
    clientUpdatedAt: cleanText(incoming.updatedAt, 80),
    serverUpdatedAt: new Date().toISOString(),
  };
}

export async function handler(event) {
  if (event.httpMethod === 'OPTIONS') return response(204, {});
  if (event.httpMethod !== 'POST') {
    return response(405, { message: 'Méthode non autorisée.' });
  }

  try {
    const body = JSON.parse(event.body || '{}');
    const profile = body.profile || {};
    const email = cleanText(profile.email, 180).toLowerCase();
    const name = cleanText(profile.name, 120);
    const profession = cleanText(profile.profession, 160);
    if (!validEmail(email) || name.length < 2) {
      return response(400, { message: 'Profil de synchronisation invalide.' });
    }

    const learnerId = crypto.createHash('sha256').update(email).digest('hex');
    const key = `academy-progress/${learnerId}.json`;
    const previous = await getJson(key, null);
    const progress = mergeProgress(previous?.progress, body.progress);
    const record = {
      schemaVersion: 1,
      appName: 'Drone Atlas Academy',
      appVersion: cleanText(body.appVersion, 30),
      learnerId,
      profile: { name, profession, email },
      progress,
      createdAt: previous?.createdAt || new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    await putJson(key, record);

    return response(200, {
      ok: true,
      syncedAt: record.updatedAt,
      progress,
    });
  } catch (error) {
    console.error('progress-api', error);
    return response(500, {
      message: 'Impossible de sauvegarder la progression pour le moment.',
    });
  }
}
