import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import '../theme/app_theme.dart';
import '../model/videomodel.dart';
import '../adwidgets/banner_ad_widget.dart';
import 'video_player_screen.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  bool _isLoading = true;
  List<VideoModel> _downloadedVideos = [];

  @override
  void initState() {
    super.initState();
    _fetchDownloads();
  }

  Future<void> _fetchDownloads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> downloadedStrings = prefs.getStringList('downloaded_videos_list') ?? [];
      
      List<VideoModel> videos = [];
      for (var str in downloadedStrings) {
        try {
          final jsonMap = jsonDecode(str);
          final video = VideoModel.fromJson(jsonMap);
          // Only show it if the file actually exists on the device
          if (video.localPath != null && await File(video.localPath!).exists()) {
            videos.add(video);
          }
        } catch (e) {
          // Skip malformed entries
        }
      }
      
      if (mounted) {
        setState(() {
          _downloadedVideos = videos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Downloads', style: TextStyle(color: AppTheme.textPrimary)),
        backgroundColor: AppTheme.surfaceColor,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _downloadedVideos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download, size: 64, color: AppTheme.textSecondary.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text("No downloaded videos.", style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 16),
                      const BannerAdWidget(),
                    ],
                  ),
                )
              : Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: BannerAdWidget(),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _downloadedVideos.length,
                        itemBuilder: (context, index) {
                          final video = _downloadedVideos[index];
                          return GestureDetector(
                      onTap: () => Get.to(() => VideoPlayerScreen(videoModel: video)),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 100,
                              height: 70,
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: video.thumbnail.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      video.thumbnail, 
                                      fit: BoxFit.cover, 
                                      errorBuilder: (_, __, ___) => const Icon(Icons.download_done, color: AppTheme.primaryColor)
                                    ),
                                  )
                                : const Icon(Icons.download_done, color: AppTheme.primaryColor),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      video.title,
                                      style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Offline available',
                                      style: const TextStyle(color: Colors.green, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
    );
  }
}
