import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lost_item_model.dart';
import '../models/found_item_model.dart';
import '../models/claim_model.dart';
import '../models/fraud_report_model.dart';
import '../models/notification_model.dart';
import 'auth_service.dart';

class ItemsService extends ChangeNotifier {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // In-memory mock lost items database
  final List<LostItem> _mockItems = [];
  
  // In-memory mock found items database
  final List<FoundItem> _mockFoundItems = [];

  // In-memory mock claim transactions
  final List<ClaimTransaction> _mockClaims = [];

  // In-memory mock fraud and incident reports
  final List<FraudReport> _mockFraudReports = [];

  // In-memory mock notifications & audit feed
  final List<AppNotification> _mockNotifications = [];

  ItemsService() {
    _seedMockItems();
    _seedMockFoundItemsAndClaims();
    _seedMockFraudReports();
    _seedMockNotifications();
  }

  List<LostItem> get items => List.unmodifiable(_mockItems);
  List<FoundItem> get foundItems => List.unmodifiable(_mockFoundItems);
  List<ClaimTransaction> get claims => List.unmodifiable(_mockClaims);
  List<FraudReport> get fraudReports => List.unmodifiable(_mockFraudReports);
  List<AppNotification> get notifications => List.unmodifiable(_mockNotifications);
  int get unreadNotificationsCount => _mockNotifications.where((n) => !n.isRead).length;

  // Seed the initial mock items for local prototyping
  void _seedMockItems() {
    _mockItems.addAll([
      LostItem(
        id: 'iphone_13_pro',
        title: 'iPhone 13 Pro',
        category: 'Electronics',
        brand: 'Apple',
        colour: 'Graphite',
        uniqueMarks: 'Small scratch on the top-left corner, blue case.',
        estimatedValue: 800.0,
        dateLost: DateTime.now().subtract(const Duration(hours: 2)),
        timeLost: '14:30',
        lastKnownLocation: 'Kings Cross Station, London',
        status: 'matchFound',
        photos: [],
        proofDocuments: [],
        serialNumber: '357283109482716',
        verificationQuestions: [
          VerificationQuestion(id: 'q1', questionText: 'Describe the Lock Screen Wallpaper'),
          VerificationQuestion(id: 'q2', questionText: 'Describe any Unique External Marks or Accessories'),
        ],
        messages: [
          ChatMessage(
            id: 'msg_sys_1',
            senderId: 'system',
            senderName: 'System Alert',
            senderRole: 'system',
            text: 'Your item report was created. Admin search is active.',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          ChatMessage(
            id: 'msg_sys_2',
            senderId: 'system',
            senderName: 'System Alert',
            senderRole: 'system',
            text: 'Potential Match Found by partner Intermediary Centre at Kings Cross Station.',
            timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
          ),
          ChatMessage(
            id: 'msg_admin_1',
            senderId: 'admin_uid',
            senderName: 'James (Admin)',
            senderRole: 'admin',
            text: 'Hi Sarah, a matching device has been handed in at the Euston Road desk. Please submit ownership verification.',
            timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
          ),
        ],
      ),
      LostItem(
        id: 'leather_wallet',
        title: 'Leather Bi-fold Wallet',
        category: 'Personal Accessories',
        brand: 'Ted Baker',
        colour: 'Dark Brown',
        uniqueMarks: 'Initials S.J. embossed inside right flap',
        estimatedValue: 75.0,
        dateLost: DateTime.now().subtract(const Duration(days: 1)),
        timeLost: '11:15',
        lastKnownLocation: 'Pret A Manger, Euston Road',
        status: 'searching',
        photos: [],
        proofDocuments: [],
        messages: [
          ChatMessage(
            id: 'msg_sys_3',
            senderId: 'system',
            senderName: 'System Alert',
            senderRole: 'system',
            text: 'Your item report was created. Admin search is active.',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      ),
    ]);
  }

  // Seed initial mock found items and claim histories
  void _seedMockFoundItemsAndClaims() {
    _mockFoundItems.addAll([
      FoundItem(
        id: 'iphone_13_pro_found',
        title: 'iPhone 13 Pro',
        category: 'Electronics',
        brand: 'Apple',
        colour: 'Graphite',
        publicDescription: 'Found graphite iPhone 13 Pro with blue cover at Kings Cross.',
        privateDetails: 'Locked with a photo wallpaper of a golden retriever puppy.',
        dateFound: DateTime.now().subtract(const Duration(days: 1)),
        timeFound: '14:40',
        locationFound: 'Kings Cross Station, London',
        status: 'deposited',
        dropOffCentreName: 'Kings Cross Intermediary Centre',
        dropOffTimestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        rewardAmount: 20.0,
        messages: [
          ChatMessage(
            id: 'f_msg_sys_1',
            senderId: 'system',
            senderName: 'System Alert',
            senderRole: 'system',
            text: 'Found item reported successfully.',
            timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
          ),
          ChatMessage(
            id: 'f_msg_sys_2',
            senderId: 'system',
            senderName: 'System Alert',
            senderRole: 'system',
            text: 'Voucher generated and item deposited at partner centre.',
            timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
          ),
        ],
      ),
      FoundItem(
        id: 'blue_backpack',
        title: 'Blue Canvas Backpack',
        category: 'Bags',
        brand: 'Eastpak',
        colour: 'Blue',
        publicDescription: 'Blue backpack found near the boating lake.',
        privateDetails: 'Contains a red notebook and black keys.',
        dateFound: DateTime.now().subtract(const Duration(hours: 3)),
        timeFound: '15:20',
        locationFound: 'Hyde Park, London',
        status: 'heldByFinder',
        messages: [
          ChatMessage(
            id: 'f_msg_sys_3',
            senderId: 'system',
            senderName: 'System Alert',
            senderRole: 'system',
            text: 'Found item reported. Please select a drop-off centre to proceed.',
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          ),
        ],
      ),
    ]);

    _mockClaims.addAll([
      ClaimTransaction(
        id: 'tx_1',
        title: 'Simulated Claim #1012: Black Leather Wallet',
        amount: 45.00,
        type: 'rewardRelease',
        status: 'available',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        itemId: 'mock_wallet_returned',
      ),
      ClaimTransaction(
        id: 'tx_2',
        title: 'Pending Match: iPhone 13 Pro',
        amount: 20.00,
        type: 'escrowCredit',
        status: 'pending',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        itemId: 'iphone_13_pro_found',
      ),
    ]);
  }

  // Get a single lost item by ID
  LostItem? getItemById(String id) {
    try {
      return _mockItems.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  // Get a single found item by ID
  FoundItem? getFoundItemById(String id) {
    try {
      return _mockFoundItems.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  // Report a new lost item
  Future<bool> reportLostItem({
    required String title,
    required String category,
    required String? brand,
    required String? colour,
    required String? uniqueMarks,
    required double estimatedValue,
    required DateTime dateLost,
    required String timeLost,
    required String lastKnownLocation,
    double? latitude,
    double? longitude,
    required List<String> photos,
    required List<String> proofDocuments,
    required String? serialNumber,
  }) async {
    if (AuthService.useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      final newId = 'item_mock_${DateTime.now().millisecondsSinceEpoch}';
      final newItem = LostItem(
        id: newId,
        title: title,
        category: category,
        brand: brand,
        colour: colour,
        uniqueMarks: uniqueMarks,
        estimatedValue: estimatedValue,
        dateLost: dateLost,
        timeLost: timeLost,
        lastKnownLocation: lastKnownLocation,
        latitude: latitude,
        longitude: longitude,
        photos: photos,
        proofDocuments: proofDocuments,
        serialNumber: serialNumber,
        status: 'searching',
        messages: [
          ChatMessage(
            id: 'msg_sys_init',
            senderId: 'system',
            senderName: 'System Alert',
            senderRole: 'system',
            text: 'Lost item report submitted successfully. Search is in progress.',
            timestamp: DateTime.now(),
          ),
        ],
      );
      _mockItems.add(newItem);
      notifyListeners();
      return true;
    } else {
      try {
        final docRef = _db.collection('lost_items').doc();
        final newItem = LostItem(
          id: docRef.id,
          title: title,
          category: category,
          brand: brand,
          colour: colour,
          uniqueMarks: uniqueMarks,
          estimatedValue: estimatedValue,
          dateLost: dateLost,
          timeLost: timeLost,
          lastKnownLocation: lastKnownLocation,
          latitude: latitude,
          longitude: longitude,
          photos: photos,
          proofDocuments: proofDocuments,
          serialNumber: serialNumber,
          status: 'searching',
        );
        await docRef.set(newItem.toMap());
        _mockItems.add(newItem);
        notifyListeners();
        return true;
      } catch (e) {
        debugPrint('Error reporting lost item to Firebase: $e');
        return false;
      }
    }
  }

  // Report a new found item
  Future<bool> reportFoundItem({
    required String title,
    required String category,
    required String? brand,
    required String? colour,
    required String publicDescription,
    required String? privateDetails,
    required DateTime dateFound,
    required String timeFound,
    required String locationFound,
    double? latitude,
    double? longitude,
    required List<String> photos,
  }) async {
    if (AuthService.useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      final newId = 'found_mock_${DateTime.now().millisecondsSinceEpoch}';
      final newItem = FoundItem(
        id: newId,
        title: title,
        category: category,
        brand: brand,
        colour: colour,
        publicDescription: publicDescription,
        privateDetails: privateDetails,
        dateFound: dateFound,
        timeFound: timeFound,
        locationFound: locationFound,
        latitude: latitude,
        longitude: longitude,
        photos: photos,
        status: 'heldByFinder',
        rewardAmount: 15.00, // Simulated admin designated base reward
        messages: [
          ChatMessage(
            id: 'f_msg_sys_init',
            senderId: 'system',
            senderName: 'System Alert',
            senderRole: 'system',
            text: 'Found item report submitted successfully. Please proceed to drop off the item.',
            timestamp: DateTime.now(),
          ),
        ],
      );
      _mockFoundItems.add(newItem);
      notifyListeners();
      return true;
    } else {
      try {
        final docRef = _db.collection('found_items').doc();
        final newItem = FoundItem(
          id: docRef.id,
          title: title,
          category: category,
          brand: brand,
          colour: colour,
          publicDescription: publicDescription,
          privateDetails: privateDetails,
          dateFound: dateFound,
          timeFound: timeFound,
          locationFound: locationFound,
          latitude: latitude,
          longitude: longitude,
          photos: photos,
          status: 'heldByFinder',
          rewardAmount: 15.00,
        );
        await docRef.set(newItem.toMap());
        _mockFoundItems.add(newItem);
        notifyListeners();
        return true;
      } catch (e) {
        debugPrint('Error reporting found item to Firebase: $e');
        return false;
      }
    }
  }

  // Select a drop-off centre and transition found item to 'awaitingDeposit'
  Future<bool> selectDropOffCentre({
    required String foundItemId,
    required String centreName,
  }) async {
    final idx = _mockFoundItems.indexWhere((item) => item.id == foundItemId);
    if (idx == -1) return false;

    if (AuthService.useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      final current = _mockFoundItems[idx];
      
      // Update item state to awaitingDeposit
      final updated = current.copyWith(
        status: 'awaitingDeposit',
        dropOffCentreName: centreName,
        dropOffTimestamp: DateTime.now(),
        secureDepositPin: 'DEP-${100 + idx * 73}',
        messages: [
          ...current.messages,
          ChatMessage(
            id: 'f_msg_sys_dep_${DateTime.now().millisecondsSinceEpoch}',
            senderId: 'system',
            senderName: 'System Alert',
            senderRole: 'system',
            text: 'Drop-off selection confirmed: $centreName. Secure deposit voucher generated.',
            timestamp: DateTime.now(),
          ),
        ],
      );
      _mockFoundItems[idx] = updated;
      
      notifyListeners();
      return true;
    } else {
      try {
        final current = _mockFoundItems[idx];
        final pin = 'DEP-${100 + idx * 73}';
        await _db.collection('found_items').doc(foundItemId).update({
          'status': 'awaitingDeposit',
          'dropOffCentreName': centreName,
          'dropOffTimestamp': FieldValue.serverTimestamp(),
          'secureDepositPin': pin,
        });
        
        final updated = current.copyWith(
          status: 'awaitingDeposit',
          dropOffCentreName: centreName,
          dropOffTimestamp: DateTime.now(),
          secureDepositPin: pin,
        );
        _mockFoundItems[idx] = updated;
        notifyListeners();
        return true;
      } catch (e) {
        debugPrint('Error selecting drop-off centre in Firebase: $e');
        return false;
      }
    }
  }

  // Withdraw available wallet funds
  Future<bool> withdrawFunds() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final double availableAmount = claims
        .where((tx) => tx.status == 'available')
        .fold(0.0, (acc, tx) => acc + tx.amount);

    if (availableAmount <= 0.0) return false;

    // Add a cashOut transaction that nullifies available amounts
    _mockClaims.add(ClaimTransaction(
      id: 'tx_out_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Withdrawal to Bank Account',
      amount: availableAmount,
      type: 'cashOut',
      status: 'completed',
      timestamp: DateTime.now(),
      itemId: 'withdrawal',
    ));

    // Convert older available transactions to completed
    for (int i = 0; i < _mockClaims.length; i++) {
      if (_mockClaims[i].status == 'available') {
        _mockClaims[i] = ClaimTransaction(
          id: _mockClaims[i].id,
          title: _mockClaims[i].title,
          amount: _mockClaims[i].amount,
          type: _mockClaims[i].type,
          status: 'completed',
          timestamp: _mockClaims[i].timestamp,
          itemId: _mockClaims[i].itemId,
        );
      }
    }

    notifyListeners();
    return true;
  }

  // Submit ownership verification details
  Future<bool> submitVerification({
    required String itemId,
    required Map<String, String> answers,
    required String? serialNumber,
    required List<String> proofDocs,
    bool biometricVerified = false,
    double? biometricConfidence,
    String? biometricHash,
    String? idDocumentType,
    String? idDocumentMasked,
  }) async {
    final idx = _mockItems.indexWhere((item) => item.id == itemId);
    if (idx == -1) return false;

    if (AuthService.useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      final current = _mockItems[idx];
      
      final verificationMessages = <ChatMessage>[
        ...current.messages,
        ChatMessage(
          id: 'msg_sys_verif_${DateTime.now().millisecondsSinceEpoch}',
          senderId: 'system',
          senderName: 'System Alert',
          senderRole: 'system',
          text: 'Ownership verification proof submitted. Under Administration Board review.',
          timestamp: DateTime.now(),
        ),
      ];

      if (biometricVerified) {
        verificationMessages.add(
          ChatMessage(
            id: 'msg_sys_bio_${DateTime.now().millisecondsSinceEpoch + 1}',
            senderId: 'system',
            senderName: 'Security Protocol',
            senderRole: 'system',
            text: 'Biometric Identity Liveness Verified (${idDocumentType ?? 'Government ID'}: ${idDocumentMasked ?? 'CONFIDENTIAL'}, ${((biometricConfidence ?? 0.984) * 100).toStringAsFixed(1)}% confidence score). Cryptographic hash registered.',
            timestamp: DateTime.now(),
          ),
        );
      }

      // Update item with verification answers and biometric data
      final updated = current.copyWith(
        status: 'underReview',
        verificationAnswers: answers,
        verificationSerialNumber: serialNumber,
        proofDocuments: [...current.proofDocuments, ...proofDocs],
        biometricVerified: biometricVerified,
        biometricConfidence: biometricConfidence,
        biometricHash: biometricHash,
        idDocumentType: idDocumentType,
        idDocumentMasked: idDocumentMasked,
        messages: verificationMessages,
      );
      _mockItems[idx] = updated;

      if (biometricVerified) {
        addNotification(
          title: 'Biometric Identity Verified (${idDocumentType ?? 'Government ID'})',
          message: 'Biometric liveness confirmed with ${((biometricConfidence ?? 0.984) * 100).toStringAsFixed(1)}% match. Cryptographic token registered.',
          type: 'biometricVerified',
          category: 'claims',
          relatedItemId: itemId,
          relatedItemTitle: current.title,
          recipientRole: 'owner',
          actionRoute: '/owner/details/$itemId',
        );
      }

      notifyListeners();
      
      return true;
    } else {
      try {
        final current = _mockItems[idx];
        final updatedMap = <String, dynamic>{
          'status': 'underReview',
          'verificationAnswers': answers,
          'verificationSerialNumber': serialNumber,
          'proofDocuments': FieldValue.arrayUnion(proofDocs),
          'biometricVerified': biometricVerified,
        };
        if (biometricConfidence != null) updatedMap['biometricConfidence'] = biometricConfidence;
        if (biometricHash != null) updatedMap['biometricHash'] = biometricHash;
        if (idDocumentType != null) updatedMap['idDocumentType'] = idDocumentType;
        if (idDocumentMasked != null) updatedMap['idDocumentMasked'] = idDocumentMasked;

        await _db.collection('lost_items').doc(itemId).update(updatedMap);
        _mockItems[idx] = current.copyWith(
          status: 'underReview',
          verificationAnswers: answers,
          verificationSerialNumber: serialNumber,
          proofDocuments: [...current.proofDocuments, ...proofDocs],
          biometricVerified: biometricVerified,
          biometricConfidence: biometricConfidence,
          biometricHash: biometricHash,
          idDocumentType: idDocumentType,
          idDocumentMasked: idDocumentMasked,
        );
        notifyListeners();
        return true;
      } catch (e) {
        debugPrint('Error updating verification in Firebase: $e');
        return false;
      }
    }
  }

  // Simulate drop-off scanned / handed over by desk representative
  Future<void> simulateHandover(String itemId) async {
    final idx = _mockItems.indexWhere((item) => item.id == itemId);
    if (idx == -1) return;
    final current = _mockItems[idx];
    _mockItems[idx] = current.copyWith(
      status: 'returned',
      messages: [
        ...current.messages,
        ChatMessage(
          id: 'msg_sys_ret_${DateTime.now().millisecondsSinceEpoch}',
          senderId: 'system',
          senderName: 'System Alert',
          senderRole: 'system',
          text: 'Item successfully collected. Handover transaction complete.',
          timestamp: DateTime.now(),
        ),
      ],
    );

    // Release the reward escrow for the finder!
    final fIdx = _mockFoundItems.indexWhere((item) => item.title == current.title && item.status == 'matched');
    if (fIdx != -1) {
      final fCurrent = _mockFoundItems[fIdx];
      _mockFoundItems[fIdx] = fCurrent.copyWith(
        status: 'returned',
        messages: [
          ...fCurrent.messages,
          ChatMessage(
            id: 'f_msg_returned_${DateTime.now().millisecondsSinceEpoch}',
            senderId: 'system',
            senderName: 'System Alert',
            senderRole: 'system',
            text: 'Item returned to owner. Reward released to your available balance!',
            timestamp: DateTime.now(),
          )
        ]
      );

      // Find the pending transaction and release it
      for (int i = 0; i < _mockClaims.length; i++) {
        if (_mockClaims[i].itemId == fCurrent.id && _mockClaims[i].status == 'pending') {
          _mockClaims[i] = ClaimTransaction(
            id: _mockClaims[i].id,
            title: 'Reward Released: ${fCurrent.title}',
            amount: _mockClaims[i].amount,
            type: 'rewardRelease',
            status: 'available',
            timestamp: DateTime.now(),
            itemId: _mockClaims[i].itemId,
          );
        }
      }
    }

    notifyListeners();
  }

  // Send a chat message in the admin support chat
  Future<bool> sendSupportMessage({
    required String itemId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String text,
  }) async {
    final idx = _mockItems.indexWhere((item) => item.id == itemId);
    if (idx == -1) return false;

    // Scrub PII: search for emails, phone numbers, payment details
    final scrubbed = _scrubPII(text);
    final isPIIDetected = (scrubbed != text);

    final current = _mockItems[idx];
    final List<ChatMessage> newMessages = List.from(current.messages);

    newMessages.add(ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      text: scrubbed,
      timestamp: DateTime.now(),
    ));

    // If PII detected, insert a system warning immediately
    if (isPIIDetected) {
      newMessages.add(ChatMessage(
        id: 'msg_sys_scrub_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'system',
        senderName: 'System Protection',
        senderRole: 'system',
        text: 'Warning: Contact numbers, email addresses, or payment card details are redacted to protect user safety and privacy.',
        timestamp: DateTime.now().add(const Duration(milliseconds: 100)),
      ));
    }

    if (AuthService.useMock) {
      _mockItems[idx] = current.copyWith(messages: newMessages);
      notifyListeners();
      return true;
    } else {
      try {
        await _db.collection('lost_items').doc(itemId).update({
          'messages': newMessages.map((m) => m.toMap()).toList(),
        });
        _mockItems[idx] = current.copyWith(messages: newMessages);
        notifyListeners();
        return true;
      } catch (e) {
        debugPrint('Error updating messages in Firebase: $e');
        return false;
      }
    }
  }

  // Send support message in found item chat
  Future<bool> sendFoundItemSupportMessage({
    required String foundItemId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String text,
  }) async {
    final idx = _mockFoundItems.indexWhere((item) => item.id == foundItemId);
    if (idx == -1) return false;

    // Scrub PII
    final scrubbed = _scrubPII(text);
    final isPIIDetected = (scrubbed != text);

    final current = _mockFoundItems[idx];
    final List<ChatMessage> newMessages = List.from(current.messages);

    newMessages.add(ChatMessage(
      id: 'f_msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      text: scrubbed,
      timestamp: DateTime.now(),
    ));

    if (isPIIDetected) {
      newMessages.add(ChatMessage(
        id: 'f_msg_sys_scrub_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'system',
        senderName: 'System Protection',
        senderRole: 'system',
        text: 'Warning: Contact numbers, email addresses, or payment card details are redacted to protect user safety and privacy.',
        timestamp: DateTime.now().add(const Duration(milliseconds: 100)),
      ));
    }

    if (AuthService.useMock) {
      _mockFoundItems[idx] = current.copyWith(messages: newMessages);
      notifyListeners();
      return true;
    } else {
      try {
        await _db.collection('found_items').doc(foundItemId).update({
          'messages': newMessages.map((m) => m.toMap()).toList(),
        });
        _mockFoundItems[idx] = current.copyWith(messages: newMessages);
        notifyListeners();
        return true;
      } catch (e) {
        debugPrint('Error updating found item messages in Firebase: $e');
        return false;
      }
    }
  }

  // PII Scrubbing regex implementation
  String _scrubPII(String text) {
    String output = text;
    // Email regex filter
    final emailRegex = RegExp(
      r'[a-zA-Z0-9\.\_\%\+\-]+@[a-zA-Z0-9\.\-]+\.[a-zA-Z]{2,}',
      caseSensitive: false,
    );
    // Phone numbers (UK landlines, mobiles, generic formats: 10-13 digits)
    final phoneRegex = RegExp(
      r'(\+44\s?7\d{3}|\b07\d{3})\s?\d{3}\s?\d{3}\b|\b(?:\d{3,4}[\s.-]?){2,3}\d{4}\b',
    );
    // Payment Card details (standard 12-19 digit pans)
    final cardRegex = RegExp(
      r'\b(?:\d[ -]*?){13,19}\b',
    );

    output = output.replaceAll(emailRegex, '[REDACTED EMAIL]');
    output = output.replaceAll(phoneRegex, '[REDACTED PHONE]');
    output = output.replaceAll(cardRegex, '[REDACTED PAYMENT]');
    return output;
  }

  // Find item by PIN (Deposit PIN or Collection PIN)
  Object? getItemByPin(String pin) {
    // 1. Check if found item deposit PIN
    for (var item in _mockFoundItems) {
      if (item.secureDepositPin == pin) {
        return item;
      }
    }
    // 2. Check if lost item collection PIN
    for (var item in _mockItems) {
      if (item.secureCollectionPin == pin) {
        return item;
      }
    }
    return null;
  }

  // Check-in item at Intermediary Centre (assigning storage locker)
  Future<bool> checkInItem({
    required String foundItemId,
    required String storageLocation,
  }) async {
    final idx = _mockFoundItems.indexWhere((item) => item.id == foundItemId);
    if (idx == -1) return false;

    if (AuthService.useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      final current = _mockFoundItems[idx];
      _mockFoundItems[idx] = current.copyWith(
        status: 'deposited',
        storageLocation: storageLocation,
        messages: [
          ...current.messages,
          ChatMessage(
            id: 'f_msg_sys_checkin_${DateTime.now().millisecondsSinceEpoch}',
            senderId: 'system',
            senderName: 'System Alert',
            senderRole: 'system',
            text: 'Physical check-in completed. Assigned to $storageLocation.',
            timestamp: DateTime.now(),
          ),
        ],
      );

      // Add a simulated pending escrow transaction to the ledger now that physical deposit is verified
      _mockClaims.add(ClaimTransaction(
        id: 'tx_mock_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Pending Match: ${current.title}',
        amount: current.rewardAmount,
        type: 'escrowCredit',
        status: 'pending',
        timestamp: DateTime.now(),
        itemId: current.id,
      ));

      addNotification(
        title: 'Partner Desk Deposit Confirmed',
        message: '${current.title} was physically inspected and securely stored in $storageLocation.',
        type: 'custodyDeposited',
        category: 'custody',
        relatedItemId: foundItemId,
        relatedItemTitle: current.title,
        recipientRole: 'finder',
        actionRoute: '/finder/claims',
      );

      notifyListeners();
      return true;
    } else {
      try {
        final current = _mockFoundItems[idx];
        await _db.collection('found_items').doc(foundItemId).update({
          'status': 'deposited',
          'storageLocation': storageLocation,
        });
        
        final updated = current.copyWith(
          status: 'deposited',
          storageLocation: storageLocation,
        );
        _mockFoundItems[idx] = updated;
        notifyListeners();
        return true;
      } catch (e) {
        debugPrint('Error checking in item in Firebase: $e');
        return false;
      }
    }
  }

  // Handover verification and return confirmation
  Future<bool> verifyAndHandover({
    required String lostItemId,
    required String pin,
  }) async {
    final idx = _mockItems.indexWhere((item) => item.id == lostItemId);
    if (idx == -1) return false;
    final current = _mockItems[idx];

    if (current.secureCollectionPin != pin) return false;

    if (AuthService.useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      _mockItems[idx] = current.copyWith(
        status: 'returned',
        messages: [
          ...current.messages,
          ChatMessage(
            id: 'msg_sys_handover_${DateTime.now().millisecondsSinceEpoch}',
            senderId: 'system',
            senderName: 'System Alert',
            senderRole: 'system',
            text: 'Physical handover verification complete. Item released to owner.',
            timestamp: DateTime.now(),
          ),
        ],
      );

      // Release reward to finder
      final fIdx = _mockFoundItems.indexWhere((item) => item.title == current.title && (item.status == 'matched' || item.status == 'deposited'));
      if (fIdx != -1) {
        final fCurrent = _mockFoundItems[fIdx];
        _mockFoundItems[fIdx] = fCurrent.copyWith(
          status: 'returned',
          messages: [
            ...fCurrent.messages,
            ChatMessage(
              id: 'f_msg_returned_${DateTime.now().millisecondsSinceEpoch}',
              senderId: 'system',
              senderName: 'System Alert',
              senderRole: 'system',
              text: 'Item returned to owner. Reward released to available balance!',
              timestamp: DateTime.now(),
            )
          ]
        );

        // Update transaction status
        for (int i = 0; i < _mockClaims.length; i++) {
          if (_mockClaims[i].itemId == fCurrent.id && _mockClaims[i].status == 'pending') {
            _mockClaims[i] = ClaimTransaction(
              id: _mockClaims[i].id,
              title: 'Reward Released: ${fCurrent.title}',
              amount: _mockClaims[i].amount,
              type: 'rewardRelease',
              status: 'available',
              timestamp: DateTime.now(),
              itemId: _mockClaims[i].itemId,
            );
          }
        }
      }

      addNotification(
        title: 'Handover Complete - Reward Released!',
        message: 'Owner physically collected ${current.title}. Reward released to your available balance (Rule 14).',
        type: 'escrowReleased',
        category: 'rewards',
        relatedItemId: lostItemId,
        relatedItemTitle: current.title,
        recipientRole: 'finder',
        actionRoute: '/finder/claims',
      );

      notifyListeners();
      return true;
    } else {
      try {
        await _db.collection('lost_items').doc(lostItemId).update({
          'status': 'returned',
        });
        _mockItems[idx] = current.copyWith(status: 'returned');
        notifyListeners();
        return true;
      } catch (e) {
        debugPrint('Error hand-over in Firebase: $e');
        return false;
      }
    }
  }

  // --- ADMIN CONTROL CENTRE METHODS ---
  
  final Set<String> _pausedChats = {};
  Set<String> get pausedChats => _pausedChats;

  bool isChatPaused(String itemId) => _pausedChats.contains(itemId);

  Future<bool> adminToggleChatStatus({required String itemId, required bool isPaused}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (isPaused) {
      _pausedChats.add(itemId);
    } else {
      _pausedChats.remove(itemId);
    }
    notifyListeners();
    return true;
  }

  Future<bool> adminApproveClaim({required String lostItemId, required double rewardAmount}) async {
    final idx = _mockItems.indexWhere((item) => item.id == lostItemId);
    if (idx == -1) return false;
    
    await Future.delayed(const Duration(milliseconds: 500));
    final current = _mockItems[idx];
    
    // 1. Update lost item status to readyForCollection
    _mockItems[idx] = current.copyWith(
      status: 'readyForCollection',
      secureCollectionPin: '491-032',
      messages: [
        ...current.messages,
        ChatMessage(
          id: 'msg_sys_approved_${DateTime.now().millisecondsSinceEpoch}',
          senderId: 'system',
          senderName: 'System Alert',
          senderRole: 'system',
          text: 'Ownership verified! Secure collection voucher generated. Please collect your item from Kings Cross customer support desk.',
          timestamp: DateTime.now(),
        ),
        ChatMessage(
          id: 'msg_admin_approved_${DateTime.now().millisecondsSinceEpoch}',
          senderId: 'admin_uid',
          senderName: 'James (Admin)',
          senderRole: 'admin',
          text: 'Hello Sarah, your claim has been approved. The item is securely stored in Lockbox #4. Present the QR code on your screen to retrieve it.',
          timestamp: DateTime.now(),
        ),
      ],
    );

    // 2. Update corresponding found item to matched state, setting the reward amount
    final fIdx = _mockFoundItems.indexWhere((item) => item.title == current.title && (item.status == 'deposited' || item.status == 'matchFound' || item.status == 'heldByFinder'));
    if (fIdx != -1) {
      final fCurrent = _mockFoundItems[fIdx];
      _mockFoundItems[fIdx] = fCurrent.copyWith(
        status: 'matched',
        rewardAmount: rewardAmount,
        messages: [
          ...fCurrent.messages,
          ChatMessage(
            id: 'f_msg_matched_${DateTime.now().millisecondsSinceEpoch}',
            senderId: 'system',
            senderName: 'System Alert',
            senderRole: 'system',
            text: 'Item matched with owner claim! Reward of £${rewardAmount.toStringAsFixed(2)} is held in escrow pending collection.',
            timestamp: DateTime.now(),
          )
        ]
      );

      // 3. Update the matching claim transaction amount and status
      final tIdx = _mockClaims.indexWhere((tx) => tx.itemId == fCurrent.id || tx.title.contains(current.title));
      if (tIdx != -1) {
        _mockClaims[tIdx] = ClaimTransaction(
          id: _mockClaims[tIdx].id,
          title: 'Reward Escrow: ${current.title}',
          amount: rewardAmount,
          type: 'escrowCredit',
          status: 'pending',
          timestamp: DateTime.now(),
          itemId: fCurrent.id,
        );
      } else {
        _mockClaims.add(ClaimTransaction(
          id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Reward Escrow: ${current.title}',
          amount: rewardAmount,
          type: 'escrowCredit',
          status: 'pending',
          timestamp: DateTime.now(),
          itemId: fCurrent.id,
        ));
      }
    }

    addNotification(
      title: 'Reward Officially Determined: £${rewardAmount.toStringAsFixed(2)}',
      message: 'Admin Board has reviewed verification and locked £${rewardAmount.toStringAsFixed(2)} in escrow pending collection (Rule 14).',
      type: 'rewardAssessed',
      category: 'rewards',
      relatedItemId: lostItemId,
      relatedItemTitle: current.title,
      recipientRole: 'owner',
      actionRoute: '/owner/collection/$lostItemId',
    );
    addNotification(
      title: 'Collection Voucher Ready',
      message: 'Secure collection voucher & QR PIN code issued for ${current.title}. Please collect from customer support desk.',
      type: 'voucherReady',
      category: 'custody',
      relatedItemId: lostItemId,
      relatedItemTitle: current.title,
      recipientRole: 'owner',
      actionRoute: '/owner/collection/$lostItemId',
    );

    notifyListeners();
    return true;
  }

  Future<bool> adminRejectClaim({required String lostItemId}) async {
    final idx = _mockItems.indexWhere((item) => item.id == lostItemId);
    if (idx == -1) return false;
    
    await Future.delayed(const Duration(milliseconds: 500));
    final current = _mockItems[idx];
    
    // Reset status to searching, add rejection message
    _mockItems[idx] = current.copyWith(
      status: 'searching',
      messages: [
        ...current.messages,
        ChatMessage(
          id: 'msg_sys_rejected_${DateTime.now().millisecondsSinceEpoch}',
          senderId: 'system',
          senderName: 'System Alert',
          senderRole: 'system',
          text: 'Ownership claim rejected by Admin. Please review your submitted answers/documents or contact support.',
          timestamp: DateTime.now(),
        ),
      ],
    );
    
    notifyListeners();
    return true;
  }

  Future<bool> adminSuspendUser({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    AuthService.suspendUser(email);
    notifyListeners();
    return true;
  }

  Future<bool> adminActivateUser({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    AuthService.activateUser(email);
    notifyListeners();
    return true;
  }

  // --- FRAUD & SECURITY INCIDENT REPORTING (RULE 11) ---

  void _seedMockFraudReports() {
    _mockFraudReports.addAll([
      FraudReport(
        id: 'rep_1042',
        reportedItemId: 'iphone_13_pro',
        reportedItemTitle: 'iPhone 13 Pro',
        reportedUserId: 'suspicious_claimant_1',
        reportedUserName: 'Mark Davies',
        reporterId: 'sarah_jenkins_uid',
        reporterRole: 'owner',
        category: 'extortionBidding',
        description: 'Received unsolicited message requesting £150 private bank transfer outside the app before allowing intermediary drop-off.',
        evidenceNotes: 'Sort code 04-00-04, Account 82910394 offered in external note.',
        status: 'pendingReview',
        severity: 'high',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      FraudReport(
        id: 'rep_1043',
        reportedItemId: 'leather_wallet',
        reportedItemTitle: 'Leather Bi-fold Wallet',
        reportedUserId: 'finder_unknown_99',
        reportedUserName: 'Dave G.',
        reporterId: 'desk_agent_euston',
        reporterRole: 'intermediary',
        category: 'stolenGoods',
        description: 'Custody check-in discrepancy: Wallet matches police report of pickpocket incident in Euston Station yesterday. Contents partially removed.',
        evidenceNotes: 'PNC Crime Ref: CAD-4829-0826.',
        status: 'investigating',
        severity: 'high',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      FraudReport(
        id: 'rep_1044',
        reportedItemId: 'blue_backpack',
        reportedItemTitle: 'Blue Canvas Backpack',
        reportedUserId: 'claimant_fake_2',
        reportedUserName: 'Alex Smith',
        reporterId: 'desk_agent_kings_cross',
        reporterRole: 'intermediary',
        category: 'fakeProof',
        description: 'Claimant submitted photo receipt with visibly edited serial number font and mismatched purchase timestamp.',
        evidenceNotes: 'Receipt shows 2024 font artifact over 2026 header.',
        status: 'pendingReview',
        severity: 'medium',
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ]);
  }

  Future<bool> submitFraudReport({
    required String reportedItemId,
    required String reportedItemTitle,
    String? reportedUserId,
    String? reportedUserName,
    required String reporterId,
    required String reporterRole,
    required String category,
    required String description,
    String? evidenceNotes,
    String severity = 'medium',
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newReport = FraudReport(
      id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
      reportedItemId: reportedItemId,
      reportedItemTitle: reportedItemTitle,
      reportedUserId: reportedUserId,
      reportedUserName: reportedUserName,
      reporterId: reporterId,
      reporterRole: reporterRole,
      category: category,
      description: description,
      evidenceNotes: evidenceNotes,
      status: 'pendingReview',
      severity: severity,
      timestamp: DateTime.now(),
    );

    _mockFraudReports.insert(0, newReport);

    // If matching lost item exists, append security alert system chat message
    final idx = _mockItems.indexWhere((i) => i.id == reportedItemId);
    if (idx != -1) {
      final current = _mockItems[idx];
      _mockItems[idx] = current.copyWith(
        messages: [
          ...current.messages,
          ChatMessage(
            id: 'msg_sys_fraud_${DateTime.now().millisecondsSinceEpoch}',
            senderId: 'system',
            senderName: 'Security Protocol',
            senderRole: 'system',
            text: 'Security Alert: Incident report #${newReport.id} (${newReport.categoryLabel}) submitted to the Admin Board. Claim is under prioritized review.',
            timestamp: DateTime.now(),
          ),
        ],
      );
    }

    addNotification(
      title: 'Security Alert: ${newReport.categoryLabel}',
      message: 'Incident #${newReport.id} logged for ${newReport.reportedItemTitle}. Under prioritized review (Rule 11).',
      type: 'securityAlert',
      category: 'security',
      relatedItemId: reportedItemId,
      relatedItemTitle: reportedItemTitle,
      recipientRole: 'admin',
      actionRoute: '/admin',
    );

    notifyListeners();
    return true;
  }

  Future<bool> adminResolveFraudReport({
    required String reportId,
    required String action, // 'freezeCase', 'suspendUser', 'dismiss', 'resolve'
    String? adminNotes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final rIdx = _mockFraudReports.indexWhere((r) => r.id == reportId);
    if (rIdx == -1) return false;

    final report = _mockFraudReports[rIdx];

    if (action == 'freezeCase') {
      // 1. Lock the associated lost item to underReview
      final iIdx = _mockItems.indexWhere((i) => i.id == report.reportedItemId);
      if (iIdx != -1) {
        final current = _mockItems[iIdx];
        _mockItems[iIdx] = current.copyWith(
          status: 'underReview',
          messages: [
            ...current.messages,
            ChatMessage(
              id: 'msg_sys_frozen_${DateTime.now().millisecondsSinceEpoch}',
              senderId: 'system',
              senderName: 'Security Protocol',
              senderRole: 'system',
              text: 'Admin Notice: Case and escrow locked pending fraud investigation (${report.categoryLabel}). Physical collection voucher held.',
              timestamp: DateTime.now(),
            ),
          ],
        );
      }

      // 2. Put corresponding found item escrow into held status
      final fIdx = _mockFoundItems.indexWhere((i) => i.id == report.reportedItemId || i.title == report.reportedItemTitle);
      if (fIdx != -1) {
        for (int i = 0; i < _mockClaims.length; i++) {
          if (_mockClaims[i].itemId == _mockFoundItems[fIdx].id) {
            _mockClaims[i] = ClaimTransaction(
              id: _mockClaims[i].id,
              title: 'LOCKED ESCROW: ${_mockClaims[i].title}',
              amount: _mockClaims[i].amount,
              type: _mockClaims[i].type,
              status: 'pending',
              timestamp: DateTime.now(),
              itemId: _mockClaims[i].itemId,
            );
          }
        }
      }

      _mockFraudReports[rIdx] = report.copyWith(
        status: 'frozen',
        actionTaken: adminNotes ?? 'Case frozen & reward escrow locked by Admin Board',
      );
    } else if (action == 'suspendUser') {
      if (report.reportedUserId != null) {
        AuthService.suspendUser(report.reportedUserId!);
      }
      _mockFraudReports[rIdx] = report.copyWith(
        status: 'resolved',
        actionTaken: adminNotes ?? 'Reported user suspended and credentials revoked.',
      );
    } else if (action == 'dismiss') {
      _mockFraudReports[rIdx] = report.copyWith(
        status: 'dismissed',
        actionTaken: adminNotes ?? 'Dismissed after administrative verification. False alarm.',
      );
    } else {
      _mockFraudReports[rIdx] = report.copyWith(
        status: 'resolved',
        actionTaken: adminNotes ?? 'Resolved by Admin Board.',
      );
    }

    notifyListeners();
    return true;
  }

  // --- IN-APP NOTIFICATION & AUDIT FEED (RULES 1, 4 & 7) ---

  void _seedMockNotifications() {
    _mockNotifications.addAll([
      AppNotification(
        id: 'notif_1',
        title: 'Official Reward Determined: £20.00',
        message: 'The Admin Board assessed and locked an official £20.00 escrow reward for the recovery of iPhone 13 Pro (Rule 14).',
        type: 'rewardAssessed',
        category: 'rewards',
        relatedItemId: 'iphone_13_pro',
        relatedItemTitle: 'iPhone 13 Pro',
        recipientRole: 'owner',
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        isRead: false,
        actionRoute: '/owner/details/iphone_13_pro',
      ),
      AppNotification(
        id: 'notif_2',
        title: 'Secure Collection Voucher Issued',
        message: 'Your ownership verification was verified. Collection PIN and QR voucher generated for Kings Cross customer desk.',
        type: 'voucherReady',
        category: 'custody',
        relatedItemId: 'iphone_13_pro',
        relatedItemTitle: 'iPhone 13 Pro',
        recipientRole: 'owner',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
        actionRoute: '/owner/collection/iphone_13_pro',
      ),
      AppNotification(
        id: 'notif_3',
        title: 'Custody Check-in Verified',
        message: 'Blue Canvas Backpack was inspected and safely deposited into King\'s Cross Partner Locker #42.',
        type: 'custodyDeposited',
        category: 'custody',
        relatedItemId: 'blue_backpack',
        relatedItemTitle: 'Blue Canvas Backpack',
        recipientRole: 'finder',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: false,
        actionRoute: '/finder/claims',
      ),
      AppNotification(
        id: 'notif_4',
        title: 'Biometric Liveness Confirmed (98.4%)',
        message: 'Facial contour alignment and liveness blink check passed. Cryptographic identity token generated for your claim.',
        type: 'biometricVerified',
        category: 'claims',
        relatedItemId: 'iphone_13_pro',
        relatedItemTitle: 'iPhone 13 Pro',
        recipientRole: 'owner',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        isRead: true,
        actionRoute: '/owner/details/iphone_13_pro',
      ),
      AppNotification(
        id: 'notif_5',
        title: 'Reward Payout Released: £45.00',
        message: 'Owner completed collection of Black Leather Wallet. Escrow reward transferred to your available balance.',
        type: 'escrowReleased',
        category: 'rewards',
        relatedItemId: 'mock_wallet_returned',
        relatedItemTitle: 'Black Leather Wallet',
        recipientRole: 'finder',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        actionRoute: '/finder/claims',
      ),
      AppNotification(
        id: 'notif_6',
        title: 'Priority Security Alert Logged',
        message: 'Admin Board initiated investigation on Case #1042 following an off-platform payment report (Rule 11).',
        type: 'securityAlert',
        category: 'security',
        relatedItemId: 'iphone_13_pro',
        relatedItemTitle: 'iPhone 13 Pro',
        recipientRole: 'admin',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        actionRoute: '/admin',
      ),
    ]);
  }

  void markNotificationAsRead(String id) {
    final idx = _mockNotifications.indexWhere((n) => n.id == id);
    if (idx != -1 && !_mockNotifications[idx].isRead) {
      _mockNotifications[idx] = _mockNotifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead() {
    bool changed = false;
    for (int i = 0; i < _mockNotifications.length; i++) {
      if (!_mockNotifications[i].isRead) {
        _mockNotifications[i] = _mockNotifications[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  void removeNotification(String id) {
    _mockNotifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void addNotification({
    required String title,
    required String message,
    required String type,
    required String category,
    String? relatedItemId,
    String? relatedItemTitle,
    String recipientRole = 'all',
    String? actionRoute,
  }) {
    final newNotif = AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      type: type,
      category: category,
      relatedItemId: relatedItemId,
      relatedItemTitle: relatedItemTitle,
      recipientRole: recipientRole,
      timestamp: DateTime.now(),
      isRead: false,
      actionRoute: actionRoute,
    );
    _mockNotifications.insert(0, newNotif);
    notifyListeners();
  }
}
