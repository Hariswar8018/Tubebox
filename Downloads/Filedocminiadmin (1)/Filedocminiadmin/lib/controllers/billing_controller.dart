import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BillingController extends GetxController {
  RxDouble earnings = 0.0.obs;
  RxDouble paid = 0.0.obs;
  RxDouble pending = 0.0.obs;

  // 1. Add subscriptions for all streams, including auth
  StreamSubscription? _authSub;
  StreamSubscription? _earningsSub;
  StreamSubscription? _withdrawalsSub;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();

    // 2. Listen to auth changes instead of calling bind methods directly
    _authSub = _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        // User is logged in, now we can safely bind to their data
        bindUserEarnings(user.uid);
        bindUserWithdrawals(user.uid);
      } else {
        // 4. Handle user logout: clear data and cancel listeners
        earnings.value = 0.0;
        paid.value = 0.0;
        pending.value = 0.0;
        _earningsSub?.cancel();
        _withdrawalsSub?.cancel();
      }
    });
  }

  // 3. Modify methods to accept the UID as a parameter
  void bindUserEarnings(String uid) {
    _earningsSub?.cancel();
    _earningsSub = _db.collection('users').doc(uid).snapshots().listen((
      snapshot,
    ) {
      if (snapshot.exists) {
        final data = snapshot.data();
        earnings.value = (data?['earnings'] as num?)?.toDouble() ?? 0.0;
      } else {
        earnings.value = 0.0;
      }
    });
  }

  void bindUserWithdrawals(String uid) {
    _withdrawalsSub?.cancel();
    _withdrawalsSub = _db
        .collection('withdrawals')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
          double totalPaid = 0.0;
          double totalPending = 0.0;
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
            final status = data['status'] as String?;
            if (status == 'approved') {
              totalPaid += amount;
            } else if (status == 'pending') {
              totalPending += amount;
            }
          }
          paid.value = totalPaid;
          pending.value = totalPending;
        });
  }

  Future<void> onRefresh() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      // Re-bind the streams on pull-to-refresh
      bindUserEarnings(uid);
      bindUserWithdrawals(uid);
      Get.snackbar(
        "Refreshed",
        "Billing data updated",
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _earningsSub?.cancel();
    _withdrawalsSub?.cancel();
    super.onClose();
  }
}
