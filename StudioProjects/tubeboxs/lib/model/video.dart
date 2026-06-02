class Video {
  final String id;
  final String title;
  final String description;
  final String status;
  final String thumbnailUrl;
  final int views;
  final int likes;
  final int downloads;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String hlsUrl;
  final String videoUrl;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.thumbnailUrl,
    required this.views,
    required this.likes,
    required this.downloads,
    required this.createdAt,
    required this.updatedAt,
    required this.hlsUrl,
    required this.videoUrl,
  });

  /// 🔁 From JSON → Dart object
  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status'] ?? 'READY',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      views: (json['views'] as num?)?.toInt() ?? 0,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      downloads: (json['downloads'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
    ? DateTime.tryParse(json['updated_at']) ?? DateTime.now()
        : DateTime.now(),
      hlsUrl: json['hls_url'] ?? '',
      videoUrl: json['video_url'] ?? '',
    );
  }

  /// 🔁 Dart object → JSON (useful for caching / sending back)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'thumbnail_url': thumbnailUrl,
      'views': views,
      'likes': likes,
      'downloads': downloads,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'hls_url': hlsUrl,
      'video_url': videoUrl,
    };
  }
}