import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_dock/controllers/billing_controller.dart';
import 'package:file_dock/controllers/withdrawal_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HomeScreenController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Revenue Analytics
  final RxInt total = 0.obs;
  final RxInt paid = 0.obs;
  final RxInt pending = 0.obs;

  /// Daily Analytics
  final RxString todayDate = "".obs;
  final RxInt dailyFilesUploaded = 0.obs;
  final RxInt dailyClicks = 0.obs;
  final RxDouble dailyEarned = 0.0.obs;

  /// Monthly Analytics
  final RxString currentMonth = "".obs;
  final RxInt monthlyFilesUploaded = 0.obs;
  final RxInt monthlyClicks = 0.obs;
  final RxDouble monthlyEarned = 0.0.obs;

  String? get userId => _auth.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    if (userId != null) {
      _fetchRevenue();
      fetchDailyAnalytics();
      fetchMonthlyAnalytics();
    }
  }

  Future<void> refreshData() async {
    await _fetchRevenue();
    await fetchDailyAnalytics();
    await fetchMonthlyAnalytics();
  }


  /// Fetch revenue only for logged-in user
  Future<void> _fetchRevenue() async {
    if (userId == null) return;

    WithdrawalProvider withdrawalProvider = Get.put(WithdrawalProvider());
    withdrawalProvider.fetchApprovedAmount();
    BillingController billingController = Get.put(BillingController());
    // final uid = FirebaseAuth.instance.currentUser?.uid;
    billingController.bindUserEarnings(userId!);
    billingController.bindUserEarnings(userId!);
  }


  /// Fetch today's stats (only current user)
  Future<void> fetchDailyAnalytics() async {
    if (userId == null) return;

    DateTime now = DateTime.now();
    final todayId = DateFormat("yyyy-MM-dd").format(now);
    todayDate.value = DateFormat("d MMM yyyy").format(now);

    final docRef = _db.collection("analytics").doc(userId).collection("days").doc(todayId);
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      final data = snapshot.data()!;
      dailyFilesUploaded.value = data["filesUploaded"] ?? 0;
      dailyClicks.value = data["clicks"] ?? 0;
      final earningInr = await convertDollarToInr((data["earnings"] ?? 0.0).toDouble());
      dailyEarned.value = earningInr;
    } else {
      dailyFilesUploaded.value = 0;
      dailyClicks.value = 0;
      dailyEarned.value = 0.0;
    }
  }

  /// Fetch monthly stats (only current user)
  Future<void> fetchMonthlyAnalytics() async {
    if (userId == null) return;

    DateTime now = DateTime.now();
    currentMonth.value = DateFormat("MMMM yyyy").format(now);

    // Reset values
    monthlyFilesUploaded.value = 0;
    monthlyClicks.value = 0;
    monthlyEarned.value = 0.0;

    // Month prefix: "yyyy-MM"
    final monthPrefix = DateFormat("yyyy-MM").format(now);

    final snapshot = await _db
        .collection("analytics")
        .doc(userId)
        .collection("days")
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: "$monthPrefix-01")
        .where(FieldPath.documentId, isLessThanOrEqualTo: "$monthPrefix-31")
        .get();

    double totalEarningsUsd = 0.0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      monthlyFilesUploaded.value += (data["filesUploaded"] ?? 0) is num
          ? (data["filesUploaded"] as num).toInt()
          : 0;

      monthlyClicks.value += (data["clicks"] ?? 0) is num
          ? (data["clicks"] as num).toInt()
          : 0;

      totalEarningsUsd += (data["earnings"] ?? 0.0);
    }

    monthlyEarned.value = await convertDollarToInr(totalEarningsUsd);

    print("✅ Monthly: files=${monthlyFilesUploaded.value}, clicks=${monthlyClicks.value}, earnings=${monthlyEarned.value}");
  }

  /// Fetch analytics for a specific picked date
  Future<void> fetchAnalyticsForPickedDate(DateTime pickedDate) async {
    if (userId == null) return;

    todayDate.value = DateFormat("d MMM yyyy").format(pickedDate);

    // Document ID format: yyyy-MM-dd
    final todayId = DateFormat("yyyy-MM-dd").format(pickedDate);
    final docRef = _db.collection("analytics").doc(userId).collection("days").doc(todayId);
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      final data = snapshot.data()!;
      dailyFilesUploaded.value = (data["filesUploaded"] ?? 0) is num
          ? (data["filesUploaded"] as num).toInt()
          : 0;
      dailyClicks.value = (data["clicks"] ?? 0) is num
          ? (data["clicks"] as num).toInt()
          : 0;
      dailyEarned.value = await convertDollarToInr(
          (data["earnings"] ?? 0.0) is num ? (data["earnings"] as num).toDouble() : 0.0);
    } else {
      dailyFilesUploaded.value = 0;
      dailyClicks.value = 0;
      dailyEarned.value = 0.0;
    }
  }

  /// Fetch analytics for a specific picked month
  Future<void> fetchAnalyticsForPickedMonth(DateTime pickedMonth) async {
    if (userId == null) return;

    currentMonth.value = DateFormat("MMMM yyyy").format(pickedMonth);

    // Reset monthly counters
    monthlyFilesUploaded.value = 0;
    monthlyClicks.value = 0;
    monthlyEarned.value = 0.0;

    final monthPrefix = DateFormat("yyyy-MM").format(pickedMonth);

    final snapshot = await _db
        .collection("analytics")
        .doc(userId)
        .collection("days")
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: "$monthPrefix-01")
        .where(FieldPath.documentId, isLessThanOrEqualTo: "$monthPrefix-31")
        .get();

    double totalEarningsUsd = 0.0;

    for (var doc in snapshot.docs) {
      final data = doc.data();

      monthlyFilesUploaded.value += (data["filesUploaded"] ?? 0) is num
          ? (data["filesUploaded"] as num).toInt()
          : 0;

      monthlyClicks.value += (data["clicks"] ?? 0) is num
          ? (data["clicks"] as num).toInt()
          : 0;

      totalEarningsUsd += (data["earnings"] ?? 0.0) is num
          ? (data["earnings"] as num).toDouble()
          : 0.0;
    }

    monthlyEarned.value = await convertDollarToInr(totalEarningsUsd);

    print(
        "✅ Picked Month: files=${monthlyFilesUploaded.value}, clicks=${monthlyClicks.value}, earnings=${monthlyEarned.value}");
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

  /// Helper to parse int safely
  int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
