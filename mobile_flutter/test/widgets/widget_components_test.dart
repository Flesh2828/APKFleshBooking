import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/models/ml_prediction_model.dart';
import 'package:mobile_flutter/widgets/glass_surface.dart';
import 'package:mobile_flutter/widgets/status_badge.dart';
import 'package:mobile_flutter/widgets/ml_smart_approval_badge.dart';
import 'package:mobile_flutter/widgets/ml_no_show_banner.dart';
import 'package:mobile_flutter/widgets/ml_energy_occupancy_card.dart';

void main() {
  group('UI Widget Component Tests', () {
    testWidgets('StatusBadge renders ACTIVE, BOOKED, and PENDING properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StatusBadge(status: 'ACTIVE'),
                StatusBadge(status: 'BOOKED'),
                StatusBadge(status: 'PENDING', isCompact: true),
                StatusBadge(status: 'REJECTED'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('SIAP DIPESAN'), findsOneWidget);
      expect(find.text('BOOKED'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('DITOLAK'), findsOneWidget);
    });

    testWidgets('GlassSurface renders with child and custom tier', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassSurface(
              tier: GlassTier.pill,
              child: Text('Glass Content'),
            ),
          ),
        ),
      );

      expect(find.text('Glass Content'), findsOneWidget);
      expect(find.byType(GlassSurface), findsOneWidget);
    });

    testWidgets('MlSmartApprovalBadge displays auto-approve recommendation', (WidgetTester tester) async {
      const svm = SvmResult(
        recommendation: 'AUTO_APPROVE',
        marginConfidence: 0.95,
        decisionReasons: ['Kapasitas ruang sesuai', 'Tidak ada indikasi spam'],
      );
      const nb = NaiveBayesResult(
        predictedCategory: 'ACADEMIC',
        confidence: 0.88,
        isSpam: false,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MlSmartApprovalBadge(
              svmResult: svm,
              naiveBayesResult: nb,
            ),
          ),
        ),
      );

      expect(find.text('Layak Disetujui Otomatis (Instant Booking)'), findsOneWidget);
      expect(find.textContaining('ACADEMIC'), findsOneWidget);
    });

    testWidgets('MlNoShowBanner shows warning when high risk', (WidgetTester tester) async {
      const logit = LogisticRegressionResult(
        noShowProbability: 0.75,
        isHighRisk: true,
        riskLevel: 'HIGH',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MlNoShowBanner(logisticResult: logit),
          ),
        ),
      );

      expect(find.textContaining('Perhatian: Indikator Risiko No-Show Tinggi (75%)'), findsOneWidget);
    });

    testWidgets('MlEnergyOccupancyCard renders predicted numbers correctly', (WidgetTester tester) async {
      const linear = LinearRegressionResult(
        predictedWeeklyOccupancyHours: 15.5,
        estimatedEnergyKwh: 7.25,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MlEnergyOccupancyCard(linearResult: linear),
          ),
        ),
      );

      expect(find.text('15.5 Jam'), findsOneWidget);
      expect(find.text('7.25 kWh'), findsOneWidget);
    });
  });
}
