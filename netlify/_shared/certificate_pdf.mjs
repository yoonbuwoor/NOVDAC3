import { readFile } from 'node:fs/promises';
import { PDFDocument, StandardFonts, degrees, rgb } from 'pdf-lib';
import QRCode from 'qrcode';

const WIDTH = 841.89;
const HEIGHT = 595.28;

function fitText(font, text, maxWidth, initialSize, minSize = 14) {
  let size = initialSize;
  while (size > minSize && font.widthOfTextAtSize(text, size) > maxWidth) {
    size -= 1;
  }
  return size;
}

function centerX(font, text, size) {
  return (WIDTH - font.widthOfTextAtSize(text, size)) / 2;
}

function drawCentered(page, font, text, y, size, color) {
  page.drawText(text, {
    x: centerX(font, text, size),
    y,
    size,
    font,
    color,
  });
}

export async function generateCertificatePdf({
  certificateId,
  fullName,
  pathTitle,
  score,
  issuedAt,
  preview,
}) {
  const pdf = await PDFDocument.create();
  const page = pdf.addPage([WIDTH, HEIGHT]);
  const regular = await pdf.embedFont(StandardFonts.Helvetica);
  const bold = await pdf.embedFont(StandardFonts.HelveticaBold);
  const italic = await pdf.embedFont(StandardFonts.HelveticaOblique);
  const logoBytes = await readFile(new URL('../assets/logo.png', import.meta.url));
  const logo = await pdf.embedPng(logoBytes);

  const burgundy = rgb(0.49, 0.05, 0.20);
  const orange = rgb(1, 0.39, 0.16);
  const navy = rgb(0.02, 0.08, 0.13);
  const pale = rgb(0.98, 0.97, 0.95);
  const gray = rgb(0.31, 0.34, 0.38);

  page.drawRectangle({ x: 0, y: 0, width: WIDTH, height: HEIGHT, color: pale });
  page.drawRectangle({ x: 18, y: 18, width: WIDTH - 36, height: HEIGHT - 36, borderColor: burgundy, borderWidth: 3 });
  page.drawRectangle({ x: 27, y: 27, width: WIDTH - 54, height: HEIGHT - 54, borderColor: orange, borderWidth: 1 });
  page.drawRectangle({ x: 0, y: HEIGHT - 92, width: WIDTH, height: 92, color: navy });

  const logoHeight = 74;
  const logoWidth = (logo.width / logo.height) * logoHeight;
  page.drawImage(logo, {
    x: 36,
    y: HEIGHT - 83,
    width: logoWidth,
    height: logoHeight,
  });

  page.drawText('DRONEATLAS ACADEMY', {
    x: WIDTH - 300,
    y: HEIGHT - 48,
    size: 20,
    font: bold,
    color: rgb(1, 1, 1),
  });
  page.drawText('Une initiative Novateur221', {
    x: WIDTH - 300,
    y: HEIGHT - 68,
    size: 10,
    font: regular,
    color: rgb(0.83, 0.91, 0.94),
  });

  drawCentered(page, bold, 'CERTIFICAT DE RÉUSSITE', 442, 27, burgundy);
  drawCentered(page, regular, 'Ce certificat est décerné à', 404, 13, gray);

  const nameSize = fitText(bold, fullName.toUpperCase(), 680, 34, 22);
  drawCentered(page, bold, fullName.toUpperCase(), 354, nameSize, navy);
  page.drawLine({ start: { x: 160, y: 342 }, end: { x: WIDTH - 160, y: 342 }, thickness: 1.2, color: orange });

  drawCentered(page, regular, 'pour avoir validé avec succès la filière', 310, 13, gray);
  const pathSize = fitText(bold, pathTitle, 700, 23, 16);
  drawCentered(page, bold, pathTitle, 270, pathSize, burgundy);

  const description = 'Le candidat a réussi les évaluations à prérequis et l’examen final sécurisé du parcours DroneAtlas Academy.';
  const line1 = 'Le candidat a réussi les évaluations à prérequis et l’examen final';
  const line2 = 'sécurisé du parcours DroneAtlas Academy.';
  drawCentered(page, regular, line1, 226, 12, gray);
  drawCentered(page, regular, line2, 208, 12, gray);

  const date = new Date(issuedAt).toLocaleDateString('fr-FR', {
    day: '2-digit',
    month: 'long',
    year: 'numeric',
    timeZone: 'UTC',
  });
  page.drawText(`Résultat final : ${score} %`, { x: 90, y: 151, size: 12, font: bold, color: navy });
  page.drawText(`Date d’émission : ${date}`, { x: 90, y: 130, size: 11, font: regular, color: gray });
  page.drawText(`Identifiant : ${certificateId}`, { x: 90, y: 109, size: 10, font: regular, color: gray });

  const verificationBase = process.env.CERTIFICATE_VERIFY_BASE_URL || '';
  const verificationUrl = `${verificationBase}${verificationBase.includes('?') ? '&' : '?'}id=${encodeURIComponent(certificateId)}`;
  const qrDataUrl = await QRCode.toDataURL(verificationUrl, { margin: 1, width: 260 });
  const qr = await pdf.embedPng(Buffer.from(qrDataUrl.split(',')[1], 'base64'));
  page.drawImage(qr, { x: WIDTH - 177, y: 82, width: 92, height: 92 });
  page.drawText('Vérification automatique', { x: WIDTH - 190, y: 64, size: 9, font: bold, color: navy });

  page.drawText('Émis automatiquement par DroneAtlas Academy — Novateur221', {
    x: 90,
    y: 65,
    size: 10,
    font: italic,
    color: burgundy,
  });
  page.drawText('Ce certificat pédagogique ne remplace pas une licence ou une autorisation de l’ANACIM.', {
    x: 90,
    y: 45,
    size: 8.5,
    font: regular,
    color: gray,
  });

  if (preview) {
    page.drawRectangle({ x: 0, y: 0, width: WIDTH, height: HEIGHT, color: rgb(1, 1, 1), opacity: 0.05 });
    for (let row = -1; row < 5; row += 1) {
      for (let col = -1; col < 5; col += 1) {
        page.drawText('APERÇU — NON VALABLE', {
          x: col * 205 - 30,
          y: row * 145 + 55,
          size: 18,
          font: bold,
          color: burgundy,
          opacity: 0.15,
          rotate: degrees(28),
        });
      }
    }
    page.drawText('DRONEATLAS ACADEMY — NOVATEUR221', {
      x: 115,
      y: 295,
      size: 32,
      font: bold,
      color: orange,
      opacity: 0.20,
      rotate: degrees(28),
    });
  }

  pdf.setTitle(`${preview ? 'Aperçu' : 'Certificat'} ${certificateId}`);
  pdf.setAuthor('DroneAtlas Academy — Novateur221');
  pdf.setSubject(pathTitle);
  pdf.setCreator('DroneAtlas Certification Service');

  return Buffer.from(await pdf.save());
}
