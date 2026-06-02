



class ApiConstants {
  // Put the base URL here. For now, it's empty so you can fill it later.
  static const String baseUrl = 'https://attractive-achievement-production-cffb.up.railway.app'; // Change to http://10.0.2.2:3000 if using Android Emulator

  // Video Endpoints
  static String viewVideo(String id) => '$baseUrl/api/videos/$id/view';
  static String likeVideo(String id) => '$baseUrl/api/videos/$id/like';
  static String downloadVideo(String id) => '$baseUrl/api/videos/$id/download';
  static String getVideoDetails(String id) => '$baseUrl/api/videos/$id';
  static String getBatchVideos() => '$baseUrl/api/videos/batch';
}
