import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../model/videomodel.dart';
import '../controllers/video_controller.dart';
import '../adwidgets/banner_ad_widget.dart';
import 'video_player_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final videoController = Get.find<VideoController>();
  bool _isLoading = true;
  List<VideoModel> _historyVideos = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> historyIds = prefs.getStringList('history_videos') ?? [];
      print("ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss");
      print(historyIds);
      if (historyIds.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final videos = await videoController.fetchBatchVideos(historyIds);
      
      if (mounted) {
        setState(() {
          _historyVideos = videos;
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
        title: const Text('Watch History', style: TextStyle(color: AppTheme.textPrimary)),
        backgroundColor: AppTheme.surfaceColor,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _historyVideos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: AppTheme.textSecondary.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text("No history found", style: Theme.of(context).textTheme.bodyLarge),
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
                        itemCount: _historyVideos.length,
                        itemBuilder: (context, index) {
                          final video = _historyVideos[index];
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
                                      errorBuilder: (_, __, ___) => const Icon(Icons.play_circle_outline, color: AppTheme.primaryColor)
                                    ),
                                  )
                                : const Icon(Icons.play_circle_outline, color: AppTheme.primaryColor),
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
                                      video.size,
                                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
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
