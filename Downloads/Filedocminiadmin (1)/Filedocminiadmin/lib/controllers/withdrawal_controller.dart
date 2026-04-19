import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:file_dock/controllers/billing_controller.dart';
import 'package:file_dock/model/withdrawal_model.dart';
import 'package:file_dock/services/qr_storage_service.dart';
import 'package:file_dock/services/withdrawal_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// Manages the state and business logic for the WithdrawalScreen.
class WithdrawalProvider extends GetxController {
  final WithdrawalService _firestoreService = WithdrawalService();
  final StorageService _storageService = StorageService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final amountController = TextEditingController();
  final upiController = TextEditingController();
  final BillingController billingController = Get.put(BillingController());

  final approvedAmount = 0.0.obs;
  final withdrawals = <WithdrawalModel>[].obs; // fetch from super admin
  final qrFile = Rx<File?>(null);
  final isLoading = false.obs;

  double get availableBalance =>
      max(0, approvedAmount.value - billingController.paid.value);

  @override
  void onInit() {
    super.onInit();
    fetchApprovedAmount();
    _fetchWithdrawalHistory();
  }

  /// Sets the selected QR code file.
  void setQr(File file) {
    qrFile.value = file;
  }

  Future<double> convertDollarToInr(double usdAmount) async {
    final url = Uri.parse("https://open.er-api.com/v6/latest/USD");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rate = data["rates"]["INR"];
      return usdAmount * rate;
    } else {
      throw Exception("Failed to fetch exchange rate");
    }
  }

  Future<void> onRefresh() async {
    try {
      isLoading.value = true;

      fetchApprovedAmount();
      _fetchWithdrawalHistory();

      await Future.delayed(const Duration(milliseconds: 300));

      Get.snackbar(
        'Refreshed',
        'Withdrawal data updated.',
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh: $e',
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetches the user's approved amount from the ledger document.
  void fetchApprovedAmount() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _firestoreService
        .getDocumentStream(collectionPath: 'users', docId: uid)
        .listen((snapshot) async {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data['earnings'] != null) {
          final usdAmount = (data['earnings'] as num).toDouble();

          try {
            final inrAmount = await convertDollarToInr(usdAmount);
            approvedAmount.value = inrAmount; // ✅ Final INR value
          } catch (e) {
            debugPrint("Currency conversion failed: $e");
            approvedAmount.value = usdAmount; // fallback
          }
        }
      }
    });
  }

  /// Fetches the user's withdrawal history from the withdrawals collection.
  void _fetchWithdrawalHistory() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      print("FAILDDDDDD: No user logged in");
      return;
    }

    _firestoreService
        .getCollectionStream(
          collectionPath: 'withdrawals',
          field: 'userId',
          value: uid,
        )
        .listen((snapshot) {
      final history = snapshot.docs.map((doc) {
        return WithdrawalModel.fromFirestore(doc);
      }).toList();

      withdrawals.assignAll(history);
    });
  }

  /// Submits the withdrawal request to Firestore.
  Future<void> submitRequest() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      Get.snackbar(
        'Error',
        'User not authenticated.',
        colorText: Colors.white,
      );
      return;
    }

    if (amountController.text.isEmpty || upiController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter both amount and UPI ID.',
        colorText: Colors.white,
      );
      return;
    }

    final amount = num.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount.',
        colorText: Colors.white,
      );
      return;
    }

    if (billingController.pending.value > amount) {
      Get.snackbar(
        'Error',
        'You already have pending withdrawals exceeding your approved balance.',
        colorText: Colors.white,
      );
      return;
    }

    if (amount > availableBalance) {
      Get.snackbar(
        'Error',
        'Withdrawal amount exceeds available approved amount.',
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      String? qrUrl;
      if (qrFile.value != null) {
        qrUrl = await _storageService.uploadFile(
          path: 'qr_codes/${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          file: qrFile.value!,
        );
      }

      final withdrawalData = {
        'userId': uid,
        'amount': amount,
        'upiId': upiController.text.trim(),
        'status': 'pending',
        'qrUrl': qrUrl,
        'requestedAt': FieldValue.serverTimestamp(),
      };

      await _firestoreService.addDocument(
        collectionPath: 'withdrawals',
        data: withdrawalData,
      );

      amountController.clear();
      upiController.clear();
      qrFile.value = null;

      Get.snackbar(
        'Success',
        'Withdrawal request submitted successfully.',
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit request. Please try again.',
        colorText: Colors.white,
      );
      debugPrint("Error submitting withdrawal: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
