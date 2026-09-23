import 'package:flutter_test/flutter_test.dart';
import 'package:uk_national_lost_item/core/models/lost_item_model.dart';
import 'package:uk_national_lost_item/core/models/fraud_report_model.dart';
import 'package:uk_national_lost_item/core/services/items_service.dart';
import 'package:uk_national_lost_item/main.dart';

void main() {
  group('LostItem Model - Biometric & Security Specifications', () {
    test('creates and serializes LostItem with biometric verification tokens', () {
      final item = LostItem(
        id: 'test_item_1',
        title: 'MacBook Pro 16',
        category: 'Electronics',
        brand: 'Apple',
        colour: 'Space Grey',
        uniqueMarks: 'Sticker residue on right of trackpad',
        estimatedValue: 1800.0,
        dateLost: DateTime(2026, 8, 1),
        timeLost: '15:30',
        lastKnownLocation: 'St Pancras International',
        status: 'searching',
        photos: [],
        proofDocuments: [],
        biometricVerified: true,
        biometricConfidence: 0.984,
        biometricHash: 'sha256_mock_hash_test_token_8899',
        idDocumentType: 'UK Passport',
        idDocumentMasked: 'GBR-PAS-***-1948',
      );

      expect(item.id, 'test_item_1');
      expect(item.biometricVerified, isTrue);
      expect(item.biometricConfidence, 0.984);
      expect(item.biometricHash, 'sha256_mock_hash_test_token_8899');
      expect(item.idDocumentType, 'UK Passport');
      expect(item.idDocumentMasked, 'GBR-PAS-***-1948');

      // Test toMap serialization
      final map = item.toMap();
      expect(map['biometricVerified'], isTrue);
      expect(map['biometricConfidence'], 0.984);
      expect(map['biometricHash'], 'sha256_mock_hash_test_token_8899');
      expect(map['idDocumentType'], 'UK Passport');
      expect(map['idDocumentMasked'], 'GBR-PAS-***-1948');

      // Test fromMap deserialization
      final restored = LostItem.fromMap(map, item.id);
      expect(restored.id, item.id);
      expect(restored.biometricVerified, isTrue);
      expect(restored.biometricConfidence, 0.984);
      expect(restored.biometricHash, item.biometricHash);
      expect(restored.idDocumentType, 'UK Passport');
      expect(restored.idDocumentMasked, 'GBR-PAS-***-1948');
    });

    test('copyWith properly updates biometric properties', () {
      final original = LostItem(
        id: 'item_copy_test',
        title: 'Keys',
        category: 'Personal Accessories',
        estimatedValue: 20.0,
        dateLost: DateTime(2026, 8, 1),
        timeLost: '09:00',
        lastKnownLocation: 'Euston Square',
        status: 'searching',
        photos: [],
        proofDocuments: [],
      );

      expect(original.biometricVerified, isFalse);
      expect(original.biometricConfidence, isNull);

      final updated = original.copyWith(
        biometricVerified: true,
        biometricConfidence: 0.965,
        biometricHash: 'hash_token_abc',
        idDocumentType: 'UK Driving Licence',
        idDocumentMasked: 'GBR-DRV-***-3321',
      );

      expect(updated.id, original.id);
      expect(updated.title, original.title);
      expect(updated.biometricVerified, isTrue);
      expect(updated.biometricConfidence, 0.965);
      expect(updated.idDocumentType, 'UK Driving Licence');
      expect(updated.idDocumentMasked, 'GBR-DRV-***-3321');
    });
  });

  group('ItemsService - Verification & Custody Business Logic', () {
    late ItemsService service;

    setUp(() {
      service = ItemsService();
    });

    test('seeds initial prototype items correctly', () {
      expect(service.items, isNotEmpty);
      expect(service.foundItems, isNotEmpty);
      expect(service.getItemById('iphone_13_pro'), isNotNull);
    });

    test('submitVerification binds biometric tokens and appends audit event', () async {
      final success = await service.submitVerification(
        itemId: 'iphone_13_pro',
        answers: {'q1': 'Golden retriever wallpaper', 'q2': 'Small scratch top corner'},
        serialNumber: '357283109482716',
        proofDocs: ['receipt_sample.pdf'],
        biometricVerified: true,
        biometricConfidence: 0.984,
        biometricHash: 'sha256_mock_hash_test_123',
        idDocumentType: 'UK Passport',
        idDocumentMasked: 'GBR-PAS-***-1948',
      );

      expect(success, isTrue);

      final updatedItem = service.getItemById('iphone_13_pro')!;
      expect(updatedItem.status, 'underReview');
      expect(updatedItem.biometricVerified, isTrue);
      expect(updatedItem.biometricConfidence, 0.984);
      expect(updatedItem.biometricHash, 'sha256_mock_hash_test_123');
      expect(updatedItem.idDocumentType, 'UK Passport');
      expect(updatedItem.idDocumentMasked, 'GBR-PAS-***-1948');

      // Verify audit trail messages were appended
      expect(updatedItem.messages.any((m) => m.text.contains('Ownership verification proof submitted')), isTrue);
      final bioMsg = updatedItem.messages.firstWhere((m) => m.text.contains('Biometric Identity Liveness Verified'));
      expect(bioMsg.senderRole, 'system');
      expect(bioMsg.text, contains('98.4%'));
      expect(bioMsg.text, contains('UK Passport'));

      // Verify item status in collection
      expect(service.items.any((i) => i.id == 'iphone_13_pro' && i.status == 'underReview'), isTrue);
    });

    test('intermediary desk check-in validates custody handover and assigns locker', () async {
      final foundItem = service.foundItems.firstWhere((i) => i.id == 'blue_backpack');
      expect(foundItem.id, 'blue_backpack');
      expect(foundItem.status, 'heldByFinder');

      // Simulate desk scan and deposit
      final ok = await service.checkInItem(foundItemId: foundItem.id, storageLocation: 'Locker #42');
      expect(ok, isTrue);

      final depositedItem = service.foundItems.firstWhere((i) => i.id == foundItem.id);
      expect(depositedItem.status, 'deposited');
      expect(depositedItem.storageLocation, 'Locker #42');

      // Check transaction created
      expect(service.claims.any((c) => c.itemId == foundItem.id && c.status == 'pending'), isTrue);
    });
  });

  group('Application Smoke & UI Entry Point', () {
    testWidgets('App boots and renders Sign In page with direct role options', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify Title & Tagline
      expect(find.text('UK National Lost-Item'), findsOneWidget);
      expect(find.text('Safe, Secure, and Fair Recovery'), findsOneWidget);

      // Verify Sign In Card Elements
      expect(find.text('Sign In'), findsNWidgets(2)); // Card header and Submit Button
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      // Verify Role Switcher for Developer Testing
      expect(find.text('DEVELOPER DIRECT ROLE LOGIN'), findsOneWidget);
      expect(find.text('Owner'), findsOneWidget);
      expect(find.text('Finder'), findsOneWidget);
      expect(find.text('Intermediary'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
    });
  });

  group('Fraud & Suspicious Activity Incident Reporting (Rule 11)', () {
    late ItemsService service;

    setUp(() {
      service = ItemsService();
    });

    test('creates and serializes FraudReport correctly', () {
      final report = FraudReport(
        id: 'rep_test_101',
        reportedItemId: 'iphone_13_pro',
        reportedItemTitle: 'iPhone 13 Pro',
        reportedUserId: 'usr_bad_actor',
        reportedUserName: 'Suspicious User',
        reporterId: 'sarah_jenkins_uid',
        reporterRole: 'owner',
        category: 'extortionBidding',
        description: 'Demanded cash payout outside of app before returning.',
        evidenceNotes: 'Off-platform contact note left in message',
        status: 'pendingReview',
        severity: 'high',
        timestamp: DateTime(2026, 9, 23, 12, 0),
      );

      expect(report.id, 'rep_test_101');
      expect(report.categoryLabel, 'Reward Extortion / Off-Platform Demand');
      expect(report.severity, 'high');

      final map = report.toMap();
      expect(map['category'], 'extortionBidding');
      expect(map['reportedItemId'], 'iphone_13_pro');
      expect(map['status'], 'pendingReview');

      final restored = FraudReport.fromMap(map, report.id);
      expect(restored.id, report.id);
      expect(restored.reportedItemTitle, report.reportedItemTitle);
      expect(restored.category, report.category);
    });

    test('submitFraudReport registers incident and inserts audit security message', () async {
      final initialCount = service.fraudReports.length;

      final success = await service.submitFraudReport(
        reportedItemId: 'iphone_13_pro',
        reportedItemTitle: 'iPhone 13 Pro',
        reportedUserId: 'suspicious_claimant_1',
        reportedUserName: 'Mark Davies',
        reporterId: 'sarah_jenkins_uid',
        reporterRole: 'owner',
        category: 'extortionBidding',
        description: 'Unsolicited request for private wire transfer before dropping off device.',
        severity: 'high',
      );

      expect(success, isTrue);
      expect(service.fraudReports.length, initialCount + 1);

      final latestReport = service.fraudReports.first;
      expect(latestReport.reportedItemId, 'iphone_13_pro');
      expect(latestReport.category, 'extortionBidding');
      expect(latestReport.status, 'pendingReview');

      // Verify security alert appended to lost item messages
      final item = service.getItemById('iphone_13_pro')!;
      final alertMsg = item.messages.last;
      expect(alertMsg.senderRole, 'system');
      expect(alertMsg.text, contains('Security Alert: Incident report'));
      expect(alertMsg.text, contains('Reward Extortion'));
    });

    test('adminResolveFraudReport executes freezeCase locking item and escrow', () async {
      final report = service.fraudReports.first;

      final resolved = await service.adminResolveFraudReport(
        reportId: report.id,
        action: 'freezeCase',
        adminNotes: 'Case frozen and collection pin invalidated pending police verification',
      );

      expect(resolved, isTrue);

      final updatedReport = service.fraudReports.firstWhere((r) => r.id == report.id);
      expect(updatedReport.status, 'frozen');
      expect(updatedReport.actionTaken, contains('Case frozen'));

      // Check item status is underReview
      final item = service.getItemById(report.reportedItemId);
      if (item != null) {
        expect(item.status, 'underReview');
        expect(item.messages.any((m) => m.text.contains('Case and escrow locked')), isTrue);
      }
    });

    test('adminResolveFraudReport dismisses false alarm properly', () async {
      final report = service.fraudReports.first;

      final dismissed = await service.adminResolveFraudReport(
        reportId: report.id,
        action: 'dismiss',
        adminNotes: 'Dismissed - verified legitimate after admin investigation',
      );

      expect(dismissed, isTrue);

      final updatedReport = service.fraudReports.firstWhere((r) => r.id == report.id);
      expect(updatedReport.status, 'dismissed');
    });
  });
}

