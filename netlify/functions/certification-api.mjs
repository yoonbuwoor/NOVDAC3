import { generateCertificatePdf } from './_shared/certificate_pdf.mjs';
import { requireFirebaseUser } from './_shared/auth.mjs';
import {
  createDownloadUrl,
  getBytes,
  getJson,
  objectExists,
  putBytes,
  putJson,
} from './_shared/b2.mjs';
import { certificationPaths, questionBank } from './_shared/exam_bank.mjs';
import { notifyNovateur } from './_shared/notify.mjs';
import { randomId, signExamToken, verifyExamToken } from './_shared/token.mjs';

const JSON_HEADERS = {
  'Content-Type': 'application/json; charset=utf-8',
  'Cache-Control': 'no-store, max-age=0',
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Authorization, Content-Type',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'X-Content-Type-Options': 'nosniff',
};

function json(statusCode, payload) {
  return {
    statusCode,
    headers: JSON_HEADERS,
    body: JSON.stringify(payload),
  };
}

function parseBody(event) {
  if (!event.body) return {};
  try {
    return JSON.parse(event.body);
  } catch {
    const error = new Error('Corps JSON invalide.');
    error.statusCode = 400;
    throw error;
  }
}

function findPath(pathId) {
  const path = certificationPaths.find((item) => item.id === pathId);
  if (!path) {
    const error = new Error('Filière de certification inconnue.');
    error.statusCode = 404;
    throw error;
  }
  return path;
}

function findExam(path, examId) {
  const index = path.exams.findIndex((item) => item.id === examId);
  if (index < 0) {
    const error = new Error('Épreuve inconnue.');
    error.statusCode = 404;
    throw error;
  }
  return { exam: path.exams[index], index };
}

function resultKey(uid, pathId, examId) {
  return `certification/results/${uid}/${pathId}/${examId}.json`;
}

function cooldownKey(uid, pathId, examId) {
  return `certification/cooldowns/${uid}/${pathId}/${examId}.json`;
}

function sessionKey(uid, nonce) {
  return `certification/sessions/${uid}/${nonce}.json`;
}

function currentCertificateKey(uid, pathId) {
  return `certification/certificates/${uid}/${pathId}/current.json`;
}

function certificateRoot(uid, pathId, certificateId) {
  return `certification/certificates/${uid}/${pathId}/${certificateId}`;
}

function shuffle(items) {
  const copy = [...items];
  for (let index = copy.length - 1; index > 0; index -= 1) {
    const target = Math.floor(Math.random() * (index + 1));
    [copy[index], copy[target]] = [copy[target], copy[index]];
  }
  return copy;
}

async function prerequisitesPassed(uid, path, examIndex) {
  if (examIndex === 0) return true;
  const previous = path.exams[examIndex - 1];
  return objectExists(resultKey(uid, path.id, previous.id));
}

async function handlePaths(user) {
  const paths = [];
  for (const path of certificationPaths) {
    const exams = [];
    let previousPassed = true;
    for (const exam of path.exams) {
      const result = await getJson(resultKey(user.uid, path.id, exam.id), null);
      const passed = Boolean(result?.passed);
      const locked = !previousPassed;
      exams.push({
        id: exam.id,
        title: exam.title,
        description: exam.description,
        isFinal: Boolean(exam.isFinal),
        passed,
        locked,
        lockReason: locked ? 'Valide d’abord l’épreuve précédente.' : null,
        passScore: exam.passScore,
        questionCount: exam.questionCount,
        bestScore: result?.score ?? null,
      });
      previousPassed = passed;
    }
    const current = await getJson(currentCertificateKey(user.uid, path.id), null);
    paths.push({
      id: path.id,
      code: path.code,
      title: path.title,
      subtitle: path.subtitle,
      exams,
      completed: exams.every((exam) => exam.passed),
      certificateId: current?.certificateId ?? null,
    });
  }
  return json(200, { paths });
}

async function handleStartExam(user, body) {
  const path = findPath(String(body.pathId || ''));
  const { exam, index } = findExam(path, String(body.examId || ''));

  if (await objectExists(resultKey(user.uid, path.id, exam.id))) {
    const error = new Error('Cette épreuve est déjà validée.');
    error.statusCode = 409;
    throw error;
  }
  if (!(await prerequisitesPassed(user.uid, path, index))) {
    const error = new Error('L’épreuve précédente doit être validée.');
    error.statusCode = 403;
    throw error;
  }

  const cooldown = await getJson(cooldownKey(user.uid, path.id, exam.id), null);
  if (cooldown?.nextAllowedAt && Date.now() < cooldown.nextAllowedAt) {
    const date = new Date(cooldown.nextAllowedAt).toLocaleString('fr-FR');
    const error = new Error(`Nouvelle tentative disponible le ${date}.`);
    error.statusCode = 429;
    throw error;
  }

  const selectedIds = shuffle(exam.questionIds).slice(0, exam.questionCount);
  const questions = selectedIds.map((questionId) => {
    const question = questionBank[questionId];
    return {
      id: question.id,
      prompt: question.prompt,
      options: shuffle(question.options.map(({ id, text }) => ({ id, text }))),
    };
  });
  const nonce = randomId(16);
  const token = signExamToken({
    uid: user.uid,
    pathId: path.id,
    examId: exam.id,
    questionIds: selectedIds,
    nonce,
    startedAt: Date.now(),
    exp: Date.now() + exam.durationSeconds * 1000 + 120000,
  });

  return json(200, {
    token,
    title: exam.title,
    durationSeconds: exam.durationSeconds,
    questions,
  });
}

async function registerFailure(uid, pathId, examId) {
  const key = cooldownKey(uid, pathId, examId);
  const now = Date.now();
  const previous = await getJson(key, null);
  const windowStartedAt =
    previous?.windowStartedAt && now - previous.windowStartedAt < 86400000
      ? previous.windowStartedAt
      : now;
  const attemptsInWindow =
    previous?.windowStartedAt === windowStartedAt
      ? Number(previous.attemptsInWindow || 0) + 1
      : 1;
  const nextAllowedAt =
    attemptsInWindow >= 2 ? windowStartedAt + 86400000 : now + 15 * 60 * 1000;
  await putJson(key, {
    windowStartedAt,
    attemptsInWindow,
    nextAllowedAt,
    updatedAt: new Date(now).toISOString(),
  });
}

async function handleSubmitExam(user, body) {
  const payload = verifyExamToken(body.token);
  if (payload.uid !== user.uid) {
    const error = new Error('Cette session ne correspond pas au compte connecté.');
    error.statusCode = 403;
    throw error;
  }
  const path = findPath(payload.pathId);
  const { exam, index } = findExam(path, payload.examId);
  if (!(await prerequisitesPassed(user.uid, path, index))) {
    const error = new Error('Les prérequis de cette épreuve ne sont plus valides.');
    error.statusCode = 403;
    throw error;
  }
  const usedKey = sessionKey(user.uid, payload.nonce);
  if (await objectExists(usedKey)) {
    const error = new Error('Cette tentative a déjà été rendue.');
    error.statusCode = 409;
    throw error;
  }

  const answers = body.answers && typeof body.answers === 'object' ? body.answers : {};
  const interruptions = Math.max(0, Number(body.interruptions || 0));
  let correct = 0;
  for (const questionId of payload.questionIds) {
    if (answers[questionId] === questionBank[questionId].correct) correct += 1;
  }
  const score = interruptions >= 3
    ? 0
    : Math.round((correct / payload.questionIds.length) * 100);
  const passed = score >= exam.passScore && interruptions < 3;
  const submittedAt = new Date().toISOString();

  await putJson(usedKey, {
    uid: user.uid,
    pathId: path.id,
    examId: exam.id,
    submittedAt,
    score,
    passed,
    interruptions,
  });

  if (passed) {
    await putJson(resultKey(user.uid, path.id, exam.id), {
      uid: user.uid,
      email: user.email,
      pathId: path.id,
      examId: exam.id,
      score,
      passed: true,
      submittedAt,
    });
  } else {
    await registerFailure(user.uid, path.id, exam.id);
  }

  return json(200, {
    passed,
    score,
    passScore: exam.passScore,
    isFinal: Boolean(exam.isFinal),
    certificateEligible: Boolean(exam.isFinal && passed),
    message: interruptions >= 3
      ? 'La tentative a été invalidée après plusieurs sorties de l’application.'
      : passed
        ? 'Résultat enregistré dans Backblaze B2.'
        : 'Révise les notions faibles avant la prochaine tentative.',
  });
}

function validateFullName(value) {
  const name = String(value || '').trim().replace(/\s+/g, ' ');
  if (name.length < 5 || name.length > 90 || !name.includes(' ')) {
    throw Object.assign(new Error('Saisis un prénom et un nom valides.'), { statusCode: 400 });
  }
  if (!/^[A-Za-zÀ-ÖØ-öø-ÿ' -]+$/.test(name)) {
    throw Object.assign(new Error('Le nom contient des caractères non autorisés.'), { statusCode: 400 });
  }
  return name;
}

async function handleIssueCertificate(user, body) {
  const path = findPath(String(body.pathId || ''));
  const finalExam = path.exams.find((exam) => exam.isFinal);
  const finalResult = await getJson(resultKey(user.uid, path.id, finalExam.id), null);
  if (!finalResult?.passed) {
    const error = new Error('L’examen final doit être validé avant l’émission du certificat.');
    error.statusCode = 403;
    throw error;
  }

  const existing = await getJson(currentCertificateKey(user.uid, path.id), null);
  if (existing?.certificateId) {
    const existingRoot = certificateRoot(user.uid, path.id, existing.certificateId);
    const notificationState = await getJson(`${existingRoot}/notification.json`, null);
    if (!notificationState?.sent) {
      const existingMetadata = await getJson(`${existingRoot}/metadata.json`, null);
      const officialDownloadUrl = await createDownloadUrl(existing.officialKey, 604800);
      const notification = await notifyNovateur({
        certificateId: existing.certificateId,
        fullName: existing.fullName,
        email: user.email,
        pathTitle: path.title,
        score: existingMetadata?.score ?? finalResult.score,
        officialDownloadUrl,
      });
      await putJson(`${existingRoot}/notification.json`, {
        ...notification,
        notifiedAt: new Date().toISOString(),
      });
      if (!notification.sent) {
        const error = new Error(
          'Le certificat officiel est généré, mais son envoi à Novateur221 a échoué. Vérifie la configuration EmailJS puis réessaie.',
        );
        error.statusCode = 502;
        throw error;
      }
    }
    return json(200, {
      certificateId: existing.certificateId,
      pathTitle: path.title,
      fullName: existing.fullName,
      alreadyIssued: true,
      adminNotified: true,
    });
  }

  const fullName = validateFullName(body.fullName);
  const year = new Date().getUTCFullYear();
  const certificateId = `DA-${path.code}-${year}-${randomId(4).toUpperCase()}`;
  const issuedAt = new Date().toISOString();
  const root = certificateRoot(user.uid, path.id, certificateId);
  const officialKey = `${root}/official.pdf`;
  const previewKey = `${root}/preview.pdf`;
  const metadataKey = `${root}/metadata.json`;

  const common = {
    certificateId,
    fullName,
    pathTitle: path.title,
    score: finalResult.score,
    issuedAt,
  };
  const [officialPdf, previewPdf] = await Promise.all([
    generateCertificatePdf({ ...common, preview: false }),
    generateCertificatePdf({ ...common, preview: true }),
  ]);

  const metadata = {
    ...common,
    uid: user.uid,
    email: user.email,
    pathId: path.id,
    officialKey,
    previewKey,
    status: 'issued-automatically',
  };

  await Promise.all([
    putBytes(officialKey, officialPdf, 'application/pdf', { certificateId, version: 'official' }),
    putBytes(previewKey, previewPdf, 'application/pdf', { certificateId, version: 'preview' }),
    putJson(metadataKey, metadata),
    putJson(`certification/verification/${certificateId}.json`, metadata),
    putJson(currentCertificateKey(user.uid, path.id), {
      certificateId,
      fullName,
      issuedAt,
      previewKey,
      officialKey,
    }),
  ]);

  const officialDownloadUrl = await createDownloadUrl(officialKey, 604800);
  const notification = await notifyNovateur({
    certificateId,
    fullName,
    email: user.email,
    pathTitle: path.title,
    score: finalResult.score,
    officialDownloadUrl,
  });
  await putJson(`${root}/notification.json`, {
    ...notification,
    notifiedAt: new Date().toISOString(),
  });
  if (!notification.sent) {
    const error = new Error(
      'Le certificat officiel est généré, mais son envoi à Novateur221 a échoué. Vérifie la configuration EmailJS puis réessaie.',
    );
    error.statusCode = 502;
    throw error;
  }

  return json(201, {
    certificateId,
    pathTitle: path.title,
    fullName,
    officialGenerated: true,
    adminNotified: true,
  });
}

async function handlePreview(user, certificateId) {
  const metadata = await getJson(
    `certification/verification/${certificateId}.json`,
    null,
  );
  if (!metadata || metadata.uid !== user.uid) {
    const error = new Error('Certificat introuvable pour ce compte.');
    error.statusCode = 404;
    throw error;
  }
  const bytes = await getBytes(metadata.previewKey);
  return {
    statusCode: 200,
    isBase64Encoded: true,
    headers: {
      ...JSON_HEADERS,
      'Content-Type': 'application/pdf',
      'Content-Disposition': 'inline',
    },
    body: bytes.toString('base64'),
  };
}

async function handleVerify(certificateId) {
  const metadata = await getJson(
    `certification/verification/${certificateId}.json`,
    null,
  );
  if (!metadata) {
    return json(404, { valid: false, message: 'Certificat inconnu.' });
  }
  return json(200, {
    valid: true,
    certificateId: metadata.certificateId,
    fullName: metadata.fullName,
    pathTitle: metadata.pathTitle,
    score: metadata.score,
    issuedAt: metadata.issuedAt,
    issuer: 'DroneAtlas Academy — Novateur221',
    status: 'Émis automatiquement',
  });
}

export const handler = async (event) => {
  if (event.httpMethod === 'OPTIONS') return { statusCode: 204, headers: JSON_HEADERS, body: '' };
  const action = event.queryStringParameters?.action || '';

  try {
    if (action === 'verify') {
      return handleVerify(String(event.queryStringParameters?.id || ''));
    }

    const user = await requireFirebaseUser(event);
    if (action === 'paths' && event.httpMethod === 'GET') return handlePaths(user);
    if (action === 'startExam' && event.httpMethod === 'POST') return handleStartExam(user, parseBody(event));
    if (action === 'submitExam' && event.httpMethod === 'POST') return handleSubmitExam(user, parseBody(event));
    if (action === 'issueCertificate' && event.httpMethod === 'POST') return handleIssueCertificate(user, parseBody(event));
    if (action === 'preview' && event.httpMethod === 'GET') {
      return handlePreview(user, String(event.queryStringParameters?.certificateId || ''));
    }
    return json(404, { message: 'Action de certification inconnue.' });
  } catch (error) {
    console.error(error);
    return json(error.statusCode || 500, {
      message: error.message || 'Erreur interne du service de certification.',
    });
  }
};
