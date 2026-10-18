class LinearRegressionResult {
  final double predictedWeeklyOccupancyHours;
  final double estimatedEnergyKwh;

  const LinearRegressionResult({
    required this.predictedWeeklyOccupancyHours,
    required this.estimatedEnergyKwh,
  });

  factory LinearRegressionResult.fromJson(Map<String, dynamic> json) {
    return LinearRegressionResult(
      predictedWeeklyOccupancyHours:
          (json['predicted_weekly_occupancy_hours'] as num?)?.toDouble() ?? 0.0,
      estimatedEnergyKwh:
          (json['estimated_energy_kwh'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'predicted_weekly_occupancy_hours': predictedWeeklyOccupancyHours,
        'estimated_energy_kwh': estimatedEnergyKwh,
      };
}

class LogisticRegressionResult {
  final double noShowProbability;
  final bool isHighRisk;
  final String riskLevel;

  const LogisticRegressionResult({
    required this.noShowProbability,
    required this.isHighRisk,
    required this.riskLevel,
  });

  factory LogisticRegressionResult.fromJson(Map<String, dynamic> json) {
    return LogisticRegressionResult(
      noShowProbability:
          (json['no_show_probability'] as num?)?.toDouble() ?? 0.0,
      isHighRisk: json['is_high_risk'] as bool? ?? false,
      riskLevel: json['risk_level'] as String? ?? 'LOW',
    );
  }

  Map<String, dynamic> toJson() => {
        'no_show_probability': noShowProbability,
        'is_high_risk': isHighRisk,
        'risk_level': riskLevel,
      };
}

class NaiveBayesResult {
  final String predictedCategory;
  final double confidence;
  final bool isSpam;

  const NaiveBayesResult({
    required this.predictedCategory,
    required this.confidence,
    required this.isSpam,
  });

  factory NaiveBayesResult.fromJson(Map<String, dynamic> json) {
    return NaiveBayesResult(
      predictedCategory: json['predicted_category'] as String? ?? 'UMUM',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      isSpam: json['is_spam'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'predicted_category': predictedCategory,
        'confidence': confidence,
        'is_spam': isSpam,
      };
}

class SvmResult {
  final String recommendation; // 'AUTO_APPROVE', 'MANUAL_REVIEW', 'AUTO_REJECT'
  final double marginConfidence;
  final List<String> decisionReasons;

  const SvmResult({
    required this.recommendation,
    required this.marginConfidence,
    required this.decisionReasons,
  });

  factory SvmResult.fromJson(Map<String, dynamic> json) {
    return SvmResult(
      recommendation: json['recommendation'] as String? ?? 'MANUAL_REVIEW',
      marginConfidence:
          (json['margin_confidence'] as num?)?.toDouble() ?? 0.0,
      decisionReasons: (json['decision_reasons'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'recommendation': recommendation,
        'margin_confidence': marginConfidence,
        'decision_reasons': decisionReasons,
      };
}

class MlPredictionBundle {
  final LinearRegressionResult linearRegression;
  final LogisticRegressionResult logisticRegression;
  final NaiveBayesResult naiveBayes;
  final SvmResult svm;
  final DateTime evaluatedAt;

  const MlPredictionBundle({
    required this.linearRegression,
    required this.logisticRegression,
    required this.naiveBayes,
    required this.svm,
    required this.evaluatedAt,
  });

  factory MlPredictionBundle.fromJson(Map<String, dynamic> json) {
    final preds = json['predictions'] as Map<String, dynamic>? ?? {};
    return MlPredictionBundle(
      linearRegression: LinearRegressionResult.fromJson(
        preds['linear_regression'] as Map<String, dynamic>? ?? {},
      ),
      logisticRegression: LogisticRegressionResult.fromJson(
        preds['logistic_regression'] as Map<String, dynamic>? ?? {},
      ),
      naiveBayes: NaiveBayesResult.fromJson(
        preds['naive_bayes'] as Map<String, dynamic>? ?? {},
      ),
      svm: SvmResult.fromJson(
        preds['svm'] as Map<String, dynamic>? ?? {},
      ),
      evaluatedAt: json['evaluated_at'] != null
          ? DateTime.tryParse(json['evaluated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'evaluated_at': evaluatedAt.toIso8601String(),
        'predictions': {
          'linear_regression': linearRegression.toJson(),
          'logistic_regression': logisticRegression.toJson(),
          'naive_bayes': naiveBayes.toJson(),
          'svm': svm.toJson(),
        },
      };
}
