// lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String userName;
  final String email;
  final int videoCount;
  final int clicks;
  final double earnings;
  final String userType; // NEW FIELD
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.userName,
    required this.email,
    this.videoCount = 0,
    this.clicks = 0,
    this.earnings = 0.0,
    this.userType = "user", // default role
    this.photoUrl,
  });

  // Convert Firestore DocumentSnapshot to UserModel
  factory UserModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;
    return UserModel(
      uid: document.id,
      userName: data['userName'] ?? '',
      email: data['email'] ?? '',
      videoCount: data['videoCount'] ?? 0,
      clicks: data['clicks'] ?? 0,
      photoUrl: data['photoUrl'], // <--- map Firestore field
      earnings: (data['earnings'] ?? 0.0).toDouble(),
      userType: data['userType'] ?? "user", // read from Firestore
    );
  }
  // photoUrl is already a field in UserModel, so no need for a getter here.

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'email': email,
      'videoCount': videoCount,
      'clicks': clicks,
      'earnings': earnings,
      'userType': userType, // add to Firestore
    };
  }
}
