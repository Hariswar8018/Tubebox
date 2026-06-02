class VideoModel {
  final String id;
  final String title;
  final String url;
  final String thumbnail;
  final String description;
  final String size;
  final DateTime date;
  int views;
  int likes;
  int bookmarks;
  String? localPath;
  final String? adminName;
  final String? adminEmail;
  final String? adminAvatar;

  VideoModel({
    required this.id,
    required this.title,
    required this.url,
    required this.thumbnail,
    required this.description,
    required this.size,
    required this.date,
    this.views = 0,
    this.likes = 0,
    this.bookmarks = 0,
    this.localPath,
    this.adminName,
    this.adminEmail,
    this.adminAvatar,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['downloadKey']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] ?? 'Unknown Title',
      url: json['streamUrl'] ?? json['url'] ?? '',
      thumbnail: json['thumbnailUrl'] ?? json['thumbnail'] ?? '',
      description: json['description'] ?? '',
      size: json['size'] ?? '0 MB',
      date: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : (json['date'] != null ? DateTime.parse(json['date']) : DateTime.now()),
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      bookmarks: json['bookmarks'] ?? 0,
      localPath: json['localPath'],
      adminName: json['admin'] != null ? json['admin']['name'] : json['adminName'],
      adminEmail: json['admin'] != null ? json['admin']['email'] : json['adminEmail'],
      adminAvatar: json['admin'] != null ? json['admin']['avatar'] : json['adminAvatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'downloadKey': id,
      'id': id,
      'title': title,
      'url': url,
      'thumbnail': thumbnail,
      'description': description,
      'size': size,
      'date': date.toIso8601String(),
      'views': views,
      'likes': likes,
      'bookmarks': bookmarks,
      'localPath': localPath,
      'adminName': adminName,
      'adminEmail': adminEmail,
      'adminAvatar': adminAvatar,
    };
  }
}
