import 'package:cloud_firestore/cloud_firestore.dart';

class VideoModel {
  final String id;
  final String userId;
  final String title;
  final String storageUrl;
  final String netlifyUrl;
  final int size;
  final int views;
  final DateTime createdAt;

  VideoModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.storageUrl,
    required this.netlifyUrl,
    required this.size,
    required this.views,
    required this.createdAt,
  });

  factory VideoModel.fromMap(Map<String, dynamic> map, String docId) {
    return VideoModel(
      id: docId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      storageUrl: map['storageUrl'] ?? '',
      netlifyUrl: map['netlifyUrl'] ?? '',
      size: (map['size'] ?? 0) as int,
      views: (map['views'] ?? 0) as int,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'storageUrl': storageUrl,
      'netlifyUrl': netlifyUrl,
      'size': size,
      'views': views,
      'createdAt': createdAt,
    };
  }
}