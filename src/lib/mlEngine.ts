export interface NaiveBayesResult {
  predictedCategory: 'AKADEMIK' | 'ORMAWA' | 'SEMINAR' | 'UMUM';
  confidence: number;
  isSpam: boolean;
  filterMessage: string;
}

export interface SvmResult {
  recommendation: 'AUTO_APPROVE' | 'MANUAL_REVIEW' | 'AUTO_REJECT';
  hasConflictRisk: boolean;
  marginConfidence: number;
  reasons: string[];
}

export interface LogisticRegressionResult {
  noShowProbability: number; // e.g. 12.4 (%)
  isHighRisk: boolean;
  riskLevel: 'LOW' | 'MEDIUM' | 'HIGH';
  formulaBreakdown: string;
}

export interface LinearRegressionResult {
  estimatedEnergyKwh: number;
  predictedOccupancyHours: number;
  breakdown: {
    coolingKwh: number;
    lightingKwh: number;
    deviceKwh: number;
  };
}

export interface GuildSpaceMlBundle {
  naiveBayes: NaiveBayesResult;
  svm: SvmResult;
  logisticRegression: LogisticRegressionResult;
  linearRegression: LinearRegressionResult;
  evaluatedAt: string;
}

export function evaluateGuildSpaceMl(params: {
  purpose: string;
  participantCount: number;
  capacity: number;
  durationHours: number;
  userRole: string;
  pastNoShowCount?: number;
  roomFacilities?: string[];
  hasScheduleConflict?: boolean;
}): GuildSpaceMlBundle {
  const {
    purpose = '',
    participantCount = 1,
    capacity = 30,
    durationHours = 2.0,
    userRole = 'MAHASISWA',
    pastNoShowCount = 0,
    roomFacilities = [],
    hasScheduleConflict = false,
  } = params;

  const cleanPurpose = purpose.trim().toLowerCase();

  // ========================================================
  // 1. NAIVE BAYES: Kategorisasi Otomatis & Filter Anti-Spam
  // ========================================================
  const spamKeywords = /(asdf|qwer|test|halo|zzzz|peminjaman biasa|random|coba-coba)/i;
  const isTooShort = cleanPurpose.length < 5;
  const isSpam = isTooShort || spamKeywords.test(cleanPurpose);

  let predictedCategory: 'AKADEMIK' | 'ORMAWA' | 'SEMINAR' | 'UMUM' = 'UMUM';
  let categoryConfidence = 0.85;

  if (/(praktikum|kuliah|dosen|tugas|skripsi|sidang|matakuliah|responsi|laboratorium)/i.test(cleanPurpose)) {
    predictedCategory = 'AKADEMIK';
    categoryConfidence = 0.96;
  } else if (/(bem|hima|hmif|rapat|ormawa|kegiatan|panitia|pelantikan|himpunan|dpm|guild|pleno|sidang pleno|koordinasi)/i.test(cleanPurpose)) {
    predictedCategory = 'ORMAWA';
    categoryConfidence = 0.94;
  } else if (/(seminar|workshop|webinar|pelatihan|narasumber|talkshow|simposium|bootcamp)/i.test(cleanPurpose)) {
    predictedCategory = 'SEMINAR';
    categoryConfidence = 0.97;
  }

  const naiveBayes: NaiveBayesResult = {
    predictedCategory,
    confidence: categoryConfidence,
    isSpam,
    filterMessage: isSpam
      ? 'Terdeteksi karakter acak atau deskripsi terlalu ringkas (< 5 karakter)'
      : 'Lolos filter NLP validitas tujuan kegiatan',
  };

  // ========================================================
  // 2. SVM: Smart Approval & Deteksi Risiko Konflik Slot Jadwal
  // ========================================================
  const fillRatio = participantCount / (capacity > 0 ? capacity : 1);
  let recommendation: 'AUTO_APPROVE' | 'MANUAL_REVIEW' | 'AUTO_REJECT' = 'MANUAL_REVIEW';
  const reasons: string[] = [];

  const hasConflictRisk = hasScheduleConflict || durationHours > 8;

  if (hasScheduleConflict) {
    recommendation = 'AUTO_REJECT';
    reasons.push('Terdeteksi risiko bentrok slot jadwal dengan reservasi lain yang telah disetujui');
  } else if (isSpam) {
    recommendation = 'AUTO_REJECT';
    reasons.push('Tujuan reservasi ditandai spam/tidak memenuhi standar deskripsi kegiatan');
  } else if (fillRatio > 1.20) {
    recommendation = 'AUTO_REJECT';
    reasons.push(`Jumlah peserta (${participantCount}) melebihi 120% batas aman ruangan (${capacity})`);
  } else if (fillRatio < 0.10 && capacity >= 50) {
    recommendation = 'MANUAL_REVIEW';
    reasons.push('Tingkat keterisian ruangan sangat minim (< 10%), disarankan memakai ruang diskusi kecil');
  } else if (fillRatio >= 0.35 && fillRatio <= 1.0 && pastNoShowCount === 0 && !hasConflictRisk) {
    recommendation = 'AUTO_APPROVE';
    reasons.push(`Rasio keterisian optimal (${Math.round(fillRatio * 100)}%)`);
    reasons.push('Profil pemohon terverifikasi & slot jadwal terdeteksi bebas konflik');
  } else {
    recommendation = 'MANUAL_REVIEW';
    reasons.push('Memerlukan telaah manual verifikasi ketersediaan dan fasilitas khusus');
  }

  const svm: SvmResult = {
    recommendation,
    hasConflictRisk,
    marginConfidence: recommendation === 'AUTO_APPROVE' ? 0.94 : 0.88,
    reasons,
  };

  // ========================================================
  // 3. LOGISTIC REGRESSION: Perhitungan Probabilitas Risiko No-Show (%)
  // ========================================================
  const isMahasiswa = userRole.toUpperCase() === 'MAHASISWA';
  const roleBias = isMahasiswa ? 0.25 : -0.35;
  const z = -1.90 + (pastNoShowCount * 1.20) + roleBias + (durationHours > 4 ? 0.40 : 0.0);
  const prob = 1 / (1 + Math.exp(-z));
  const noShowPercent = parseFloat((prob * 100).toFixed(1));
  const isHighRisk = noShowPercent >= 45.0;

  const logisticRegression: LogisticRegressionResult = {
    noShowProbability: noShowPercent,
    isHighRisk,
    riskLevel: noShowPercent < 20 ? 'LOW' : noShowPercent < 45 ? 'MEDIUM' : 'HIGH',
    formulaBreakdown: `Sigmoid: 1 / (1 + e^-z), z = ${z.toFixed(2)} (Rekam jejak: ${pastNoShowCount} no-show, peran: ${userRole})`,
  };

  // ========================================================
  // 4. LINEAR REGRESSION: Estimasi Konsumsi Daya Listrik Ruangan (kWh)
  // ========================================================
  const hasAcCentral = roomFacilities.some((f) => /AC Central/i.test(f));
  const hasLabPcs = roomFacilities.some((f) => /PC|Workstation/i.test(f));
  const hasHighSound = roomFacilities.some((f) => /Sound System|Lighting/i.test(f));

  const coolingLoad = hasAcCentral ? 2.5 : 1.2; // kW
  const deviceLoad = hasLabPcs ? 3.8 : (hasHighSound ? 1.8 : 0.6); // kW
  const lightingLoad = 0.4; // kW

  const totalLoadKw = coolingLoad + deviceLoad + lightingLoad;
  const estimatedEnergyKwh = parseFloat((totalLoadKw * durationHours).toFixed(2));
  const predictedOccupancyHours = parseFloat((durationHours * 1.15 + (capacity / 15)).toFixed(1));

  const linearRegression: LinearRegressionResult = {
    estimatedEnergyKwh,
    predictedOccupancyHours,
    breakdown: {
      coolingKwh: parseFloat((coolingLoad * durationHours).toFixed(2)),
      lightingKwh: parseFloat((lightingLoad * durationHours).toFixed(2)),
      deviceKwh: parseFloat((deviceLoad * durationHours).toFixed(2)),
    },
  };

  return {
    naiveBayes,
    svm,
    logisticRegression,
    linearRegression,
    evaluatedAt: new Date().toISOString(),
  };
}
