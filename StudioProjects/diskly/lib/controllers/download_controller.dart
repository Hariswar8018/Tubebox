import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../model/videomodel.dart';
import '../controllers/video_controller.dart';
import '../screens/main_screen.dart';

class DownloadController extends GetxController {
  final RxMap<String, double> _downloadProgress = <String, double>{}.obs;
  final Dio _dio = Dio();

  bool isDownloading(String url) {
    return _downloadProgress.containsKey(url) && _downloadProgress[url]! < 1.0;
  }

  double getProgress(String url) {
    return _downloadProgress[url] ?? 0.0;
  }

  void startDownload(VideoModel video) async {
    if (isDownloading(video.url)) return;
    
    log('Starting download for ${video.url}');
    _downloadProgress[video.url] = 0.01;

    try {
      final dir = Platform.isAndroid 
          ? await getExternalStorageDirectory() 
          : await getApplicationDocumentsDirectory();
          
      if (dir == null) {
        throw Exception("Could not find directory to save video.");
      }

      String name = video.title.replaceAll(" ", "_");
      if (!name.endsWith(".mp4")) name = "$name.mp4";
      final savePath = "${dir.path}/$name";

      await _dio.download(
        video.url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            _downloadProgress[video.url] = received / total;
          }
        },
      );

      _downloadProgress[video.url] = 1.0;
      log('Download completed for ${video.url}');
      
      Get.find<VideoController>().downloadVideo(video.id);
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      List<String> downloadedVideos = prefs.getStringList('downloaded_videos_list') ?? [];
      
      video.localPath = savePath;
      final videoJson = jsonEncode(video.toJson());
      
      // Remove if exists to avoid duplicates
      downloadedVideos.removeWhere((v) => jsonDecode(v)['id'] == video.id);
      downloadedVideos.add(videoJson);
      
      await prefs.setStringList('downloaded_videos_list', downloadedVideos);
      
      Get.snackbar("Download Complete", "Video saved for offline viewing");
      Get.offAll(() => const MainScreen(initialIndex: 2));
      
    } catch (e) {
      log('Error downloading video: $e');
      _downloadProgress.remove(video.url);
      Get.snackbar("Download Failed", "There was an error downloading the video.");
    }
  }
}
