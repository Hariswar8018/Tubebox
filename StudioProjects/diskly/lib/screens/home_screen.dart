import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_manager.dart';
import '../theme/app_theme.dart';
import '../model/videomodel.dart';
import '../adwidgets/rewardedad.dart';
import '../constant/api_constants.dart';
import '../adwidgets/native_ad.dart';
import 'video_player_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  final AdManager _adManager = AdManager();
  final TextEditingController _linkController = TextEditingController();

  bool _isLoadingVideo = false;
  VideoModel? _fetchedVideo;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _adManager.loadRewardedAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _handleLinkSubmission() {
    final link = _linkController.text.trim();
    if (link.isEmpty) return;

    // Simulate link parsing
    String videoId = link;
    if (link.contains('diskly.in/')) {
      final parts = link.split('diskly.in/');
      if (parts.length > 1) {
        final pathPart = parts[1];
        final pathSegments = pathPart
            .split('/')
            .where((s) => s.isNotEmpty)
            .toList();
        if (pathSegments.isNotEmpty) {
          videoId = pathSegments.first; // get the ID part
        }
      }
    }

    log('Parsed Video ID: $videoId');

    setState(() {
      _isLoadingVideo = true;
      _fetchedVideo = null;
    });
    print("ssssssss---------------------->");
    print(videoId);

    _fetchVideoFromBackend(videoId);
  }

  Future<void> _fetchVideoFromBackend(String videoId) async {
    try {
      if (ApiConstants.baseUrl.isEmpty) {
        throw Exception("Base URL is not set");
      }
      final url = ApiConstants.getVideoDetails(videoId);
      print("Fetching video from: $url");

      final response = await http.get(Uri.parse(url));

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final fetchedVideo = VideoModel.fromJson(data);
        setState(() {
          _isLoadingVideo = false;
          _fetchedVideo = fetchedVideo;
        });

        // Save to history immediately
        final prefs = await SharedPreferences.getInstance();
        List<String> historyVideos =
            prefs.getStringList('history_videos') ?? [];
        if (!historyVideos.contains(fetchedVideo.id)) {
          historyVideos.insert(0, fetchedVideo.id);
          await prefs.setStringList('history_videos', historyVideos);
        } else {
          historyVideos.remove(fetchedVideo.id);
          historyVideos.insert(0, fetchedVideo.id);
          await prefs.setStringList('history_videos', historyVideos);
        }
      } else {
        // Logging the actual error body from the API
        log('API Error: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception(
          "Failed to load video: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      log('Error fetching video: $e');
      print('Exception during video fetch: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingVideo = false;
      });
      Get.snackbar(
        "Error",
        "Could not fetch video details. Please check the link.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void _playVideo(VideoModel video) {
    // Show rewarded ad before playing 50% of the time
    final adId = AdManager.rewardedInterstitialAdUnitIds['unlockFullVideo'];
    final bool shouldShowAd = (DateTime.now().millisecondsSinceEpoch % 2 == 0);

    if (adId == null || adId.isEmpty || !shouldShowAd) {
      Get.to(() => VideoPlayerScreen(videoModel: video));
      return;
    }

    // Using the mock RewardedInterstitialAdManager we created
    RewardedInterstitialAdManager().showAd(
      adUnitId: adId,
      onComplete: (bool earned) {
        if (earned) {
          Get.to(() => VideoPlayerScreen(videoModel: video));
        } else {
          Get.snackbar(
            "Watch Full Ad",
            "You must watch the entire ad to unlock video.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Welcome to Diskly',
                      style: Theme.of(
                        context,
                      ).textTheme.displayMedium?.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Access File via Link',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppTheme.primaryColor,
                                fontSize: 16,
                              ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.link,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Link Input Field
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _linkController,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Paste your Diskly link here...',
                                hintStyle: TextStyle(
                                  color: AppTheme.textSecondary,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                              ),
                              onSubmitted: (_) => _handleLinkSubmission(),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                color: AppTheme.backgroundColor,
                                size: 18,
                              ),
                              onPressed: _isLoadingVideo
                                  ? null
                                  : _handleLinkSubmission,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Conditionally show Recent Activity or Video Card
                    if (_isLoadingVideo)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      )
                    else if (_fetchedVideo != null) ...[
                      _buildVideoCard(_fetchedVideo!),
                      const SizedBox(height: 24),
                      const NativeVideoAdCard(),
                    ] else
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildFeatureCard(
                                  icon: Icons.video_settings,
                                  title: 'Adaptive\nVideo Quality',
                                  subtitle:
                                      'Seamlessly adjusts video resolution between 480p, 720p, and 1080p',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildFeatureCard(
                                  icon: Icons.flag_outlined,
                                  title: 'Issue\nReporting',
                                  subtitle:
                                      'Easily report any video or playback issues directly from the app',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Recent Activity Placeholder
                          Center(child: const NativeVideoAdCard()),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            // Banner Ad at the bottom of the body
            if (_isLoaded && _bannerAd != null)
              Container(
                color: AppTheme.backgroundColor,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCard(VideoModel video) {
    return GestureDetector(
      onTap: () => _playVideo(video),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail (Landscape)
                  Container(
                    height: 80,
                    width: 120,
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
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.image_outlined,
                                size: 32,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.image_outlined,
                            size: 32,
                            color: AppTheme.primaryColor,
                          ),
                  ),
                  const SizedBox(width: 12),
                  // Details (Name, Description)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.title,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          video.description,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          video.size,
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Full-width Play Button at bottom
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                border: Border(
                  top: BorderSide(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                  ),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_circle_fill,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Play Video',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 28),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
