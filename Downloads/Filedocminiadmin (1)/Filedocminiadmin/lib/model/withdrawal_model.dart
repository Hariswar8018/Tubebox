// // lib/models/withdrawal_model.dart

// import 'package:cloud_firestore/cloud_firestore.dart';

// // WithdrawalModel represents a single withdrawal request document from Firestore.
// class WithdrawalModel {
//   final String id;
//   final String userId;
//   final num amount;
//   final String upiId;
//   final String status;
//   final String? qrUrl;
//   final Timestamp requestedAt;
//   final Timestamp? approvedAt;

//   WithdrawalModel({
//     required this.id,
//     required this.userId,
//     required this.amount,
//     required this.upiId,
//     required this.status,
//     this.qrUrl,
//     required this.requestedAt,
//     this.approvedAt,
//   });

//   // Factory constructor to create a WithdrawalModel from a Firestore document.
//   factory WithdrawalModel.fromFirestore(
//     DocumentSnapshot<Map<String, dynamic>> doc,
//   ) {
//     final data = doc.data()!;
//     return WithdrawalModel(
//       id: doc.id,
//       userId: data['userId'] as String,
//       amount: data['amount'] as num,
//       upiId: data['upiId'] as String,
//       status: data['status'] as String,
//       qrUrl: data['qrUrl'] as String?,
//       requestedAt: data['requestedAt'] as Timestamp,
//       approvedAt: data['approvedAt'] as Timestamp?,
//     );
//   }

//   // Method to convert the model to a JSON map for Firestore.
//   Map<String, dynamic> toFirestore() {
//     return {
//       'userId': userId,
//       'amount': amount,
//       'upiId': upiId,
//       'status': status,
//       'qrUrl': qrUrl,
//       'requestedAt': requestedAt,
//       'approvedAt': approvedAt,
//     };
//   }
// }
// lib/models/withdrawal_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class WithdrawalModel {
  final String id;
  final String userId;
  final double amount;
  final String upiId;
  final String status;
  final String? qrUrl;
  final Timestamp requestedAt;
  final Timestamp? approvedAt;

  WithdrawalModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.upiId,
    required this.status,
    this.qrUrl,
    required this.requestedAt,
    this.approvedAt,
  });

  factory WithdrawalModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return WithdrawalModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      // amount: (data['amount'] ?? 0) as double,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,

      upiId: data['upiId'] as String? ?? '',
      status: data['status'] as String? ?? '',
      qrUrl: data['qrUrl'] as String?,
      requestedAt: data['requestedAt'] is Timestamp
          ? data['requestedAt'] as Timestamp
          : Timestamp.now(), // fallback if missing
      approvedAt: data['approvedAt'] is Timestamp
          ? data['approvedAt'] as Timestamp
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'upiId': upiId,
      'status': status,
      'qrUrl': qrUrl,
      'requestedAt': requestedAt,
      'approvedAt': approvedAt,
    };
  }
}
