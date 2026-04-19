// import 'package:get/get.dart';
// import '../model/ledger_model.dart';
// import '../services/ledger_service.dart';

// class LedgerController extends GetxController {
//   final LedgerService _service = LedgerService();

//   var ledger = Rxn<LedgerModel>();

//   void bindLedger(String userId) {
//     ledger.bindStream(_service.getLedgerStream(userId));
//   }
// }
// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_dock/model/ledger_model.dart';
// import 'package:file_dock/services/ledger_service.dart';
// import 'package:get/get_rx/src/rx_types/rx_types.dart';
// import 'package:get/get_state_manager/src/simple/get_controllers.dart';

// class LedgerController extends GetxController {
//   final LedgerService _service = LedgerService();
//   var ledger = Rxn<LedgerModel>();
//   StreamSubscription? _userSub;

//   void bindLedger(String userId) {
//     // ledger model ko bind karo
//     ledger.bindStream(_service.getLedgerStream(userId));

//     // pehle se koi subscription hai to cancel karo
//     _userSub?.cancel();

//     // 👇 user earnings listener
//     _userSub = FirebaseFirestore.instance
//         .collection("users")
//         .doc(userId)
//         .snapshots()
//         .listen((snapshot) async {
//           if (snapshot.exists) {
//             final data = snapshot.data() as Map<String, dynamic>;
//             final userEarnings = data["earnings"] ?? 0;

//             await FirebaseFirestore.instance
//                 .collection("ledger")
//                 .doc(userId)
//                 .set({
//                   "totalEarnings": userEarnings,
//                   "userId": userId,
//                 }, SetOptions(merge: true));
//           }
//         });
//   }

//   @override
//   void onClose() {
//     _userSub?.cancel();
//     super.onClose();
//   }
// }
import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/ledger_model.dart';
import '../services/ledger_service.dart';

class LedgerController extends GetxController {
  final LedgerService _service = LedgerService();

  // Rx object to store Ledger data
  var ledger = Rxn<LedgerModel>();

  // Subscription to listen user earnings
  StreamSubscription? _userSub;

  /// Bind ledger to a userId
  void bindLedger(String userId) {
    // 1️⃣ Bind ledger Rx object to Firestore ledger stream
    ledger.bindStream(_service.getLedgerStream(userId));

    // 2️⃣ Cancel previous subscription if exists
    _userSub?.cancel();

    // 3️⃣ Listen to user's earnings and update ledger automatically
    _userSub = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .snapshots()
        .listen((snapshot) async {
          if (snapshot.exists) {
            try {
              final data = snapshot.data() as Map<String, dynamic>;
              final userEarnings = data["earnings"] ?? 0;

              // Update ledger document
              await FirebaseFirestore.instance
                  .collection("ledger")
                  .doc(userId)
                  .set({
                    "totalEarnings": userEarnings,
                    "userId": userId,
                  }, SetOptions(merge: true));
            } catch (e) {
              print("Ledger update failed: $e");
            }
          }
        });
  }

  /// Cancel subscription when controller is disposed
  @override
  void onClose() {
    _userSub?.cancel();
    super.onClose();
  }
}
