import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/ledger_model.dart';

class LedgerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<LedgerModel> getLedgerStream(String userId) {
    return _firestore.collection("ledger").doc(userId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists) {
        return LedgerModel.fromMap(snapshot.data()!);
      } else {
        return LedgerModel(
          approvedAmount: 0,
          availableAmount: 0,
          paidAmount: 0,
          pendingAmount: 0,
          totalEarnings: 0,
          userId: userId,
        );
      }
    });
  }
}
