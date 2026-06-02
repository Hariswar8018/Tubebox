import 'package:dio/dio.dart';
import 'package:tubeboxs/model/video.dart';

class VideoService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://tubeboxservers-production.up.railway.app/api',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  static Future<Video> getVideoById(String id) async {
    try {
      final response = await _dio.get('/videos/$id');
      print(response);
      return Video.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['error'] ?? 'Server error');
      } else {
        throw Exception('Network error');
      }
    }
  }
}