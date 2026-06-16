import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lost_item_model.dart';
import 'auth_service.dart';

class ItemsService extends ChangeNotifier {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // In-memory mock lost items database
  final List<LostItem> _mockItems = [];

  ItemsService() {
    _seedMockItems();
  }

  List<LostItem> get items => List.unmodifiable(_mockItems);

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

  // Get a single lost item by ID
  LostItem? getItemById(String id) {
    try {
      return _mockItems.firstWhere((item) => item.id == id);
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

  // Submit ownership verification details
  Future<bool> submitVerification({
    required String itemId,
    required Map<String, String> answers,
    required String? serialNumber,
    required List<String> proofDocs,
  }) async {
    final idx = _mockItems.indexWhere((item) => item.id == itemId);
    if (idx == -1) return false;

    if (AuthService.useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      final current = _mockItems[idx];
      
      // Update item with verification answers
      final updated = current.copyWith(
        status: 'underReview',
        verificationAnswers: answers,
        verificationSerialNumber: serialNumber,
        proofDocuments: [...current.proofDocuments, ...proofDocs],
        messages: [
          ...current.messages,
          ChatMessage(
            id: 'msg_sys_verif_${DateTime.now().millisecondsSinceEpoch}',
            senderId: 'system',
            senderName: 'System Alert',
            senderRole: 'system',
            text: 'Ownership verification proof submitted. Under Administration Board review.',
            timestamp: DateTime.now(),
          ),
        ],
      );
      _mockItems[idx] = updated;
      notifyListeners();
      
      // Auto-simulate Admin Review to make it ready for collection after 5 seconds
      _simulateAdminApproval(itemId);
      return true;
    } else {
      try {
        final current = _mockItems[idx];
        final updatedMap = {
          'status': 'underReview',
          'verificationAnswers': answers,
          'verificationSerialNumber': serialNumber,
          'proofDocuments': FieldValue.arrayUnion(proofDocs),
        };
        await _db.collection('lost_items').doc(itemId).update(updatedMap);
        _mockItems[idx] = current.copyWith(
          status: 'underReview',
          verificationAnswers: answers,
          verificationSerialNumber: serialNumber,
          proofDocuments: [...current.proofDocuments, ...proofDocs],
        );
        notifyListeners();
        return true;
      } catch (e) {
        debugPrint('Error updating verification in Firebase: $e');
        return false;
      }
    }
  }

  // Support simulator to trigger the next stages for demonstration/testing
  void _simulateAdminApproval(String itemId) {
    Timer(const Duration(seconds: 5), () {
      final idx = _mockItems.indexWhere((item) => item.id == itemId);
      if (idx == -1) return;
      final current = _mockItems[idx];
      if (current.status == 'underReview') {
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
        notifyListeners();
      }
    });
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
}
