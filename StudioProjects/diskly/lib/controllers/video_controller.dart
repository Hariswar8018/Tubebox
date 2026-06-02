import 'dart:developer';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../model/videomodel.dart';
import '../constant/api_constants.dart';

class VideoController extends GetxController {
  
  Future<void> countViewAndEarning(VideoModel video) async {
    log('API CALL: Recording view for video ${video.id}');
    if (ApiConstants.baseUrl.isEmpty) {
      log('Base URL is not set. Skipping real API call.');
      return;
    }
    
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.viewVideo(video.id)),
      );
      if (response.statusCode == 200) {
        log('View successfully recorded on backend.');
      } else {
        log('Failed to record view: ${response.statusCode}');
      }
    } catch (e) {
      log('Error recording view: $e');
    }
  }

  Future<void> likeVideo(String videoId) async {
    log('API CALL: Liking video $videoId');
    if (ApiConstants.baseUrl.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.likeVideo(videoId)),
      );
      log('Like response: ${response.statusCode}');
    } catch (e) {
      log('Error liking video: $e');
    }
  }

  Future<void> downloadVideo(String videoId) async {
    log('API CALL: Recording download/bookmark for video $videoId');
    if (ApiConstants.baseUrl.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.downloadVideo(videoId)),
      );
      log('Download response: ${response.statusCode}');
    } catch (e) {
      log('Error recording download: $e');
    }
  }

  Future<List<VideoModel>> fetchBatchVideos(List<String> ids) async {
    log('API CALL: Fetching batch videos for ${ids.length} ids');
    if (ids.isEmpty) return [];
    if (ApiConstants.baseUrl.isEmpty) return [];

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.getBatchVideos()),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'keys': ids}),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => VideoModel.fromJson(json)).toList();
      } else {
        log('Failed to fetch batch videos: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching batch videos: $e');
    }
    return [];
  }
}
