export async function notifyNovateur({
  certificateId,
  fullName,
  email,
  pathTitle,
  score,
  officialDownloadUrl,
}) {
  const serviceId = process.env.EMAILJS_SERVICE_ID;
  const templateId = process.env.EMAILJS_TEMPLATE_ID_CERTIFICATE;
  const publicKey = process.env.EMAILJS_PUBLIC_KEY;
  if (!serviceId || !templateId || !publicKey) {
    return { sent: false, reason: 'EmailJS non configuré' };
  }

  const response = await fetch('https://api.emailjs.com/api/v1.0/email/send', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      service_id: serviceId,
      template_id: templateId,
      user_id: publicKey,
      template_params: {
        to_email: process.env.NOVATEUR_EMAIL || 'novateur221@gmail.com',
        certificate_id: certificateId,
        full_name: fullName,
        user_email: email,
        path_title: pathTitle,
        score: `${score} %`,
        official_download_url: officialDownloadUrl,
        message: 'Un certificat officiel sans filigrane a été généré automatiquement et stocké dans Backblaze B2.',
      },
    }),
  });

  if (!response.ok) {
    const body = await response.text();
    return { sent: false, reason: `EmailJS ${response.status}: ${body}` };
  }
  return { sent: true };
}
