import 'dart:async';
import 'dart:io';

import '../model/videomodel.dart';
import '../controllers/download_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../services/ad_manager.dart';
import '../adwidgets/native_ad.dart';
import '../adwidgets/rewardedad.dart';
import '../constant/colors.dart';
import '../controllers/video_controller.dart';
import '../theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

////////////////////////////////////////////////////////////
/// VIDEO PLAYER SCREEN
////////////////////////////////////////////////////////////

class VideoPlayerScreen extends StatefulWidget {
  final VideoModel videoModel;

  const VideoPlayerScreen({super.key, required this.videoModel});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final videoController = Get.find<VideoController>();
  final downloadController = Get.put(DownloadController(), permanent: true);

  bool _isAdLoading = false;
  bool _isDownloaded = false;
  bool _isLiked = false;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _checkIfDownloaded();
    _checkPreferencesAndHistory();
  }

  Future<void> _checkPreferencesAndHistory() async {
    final prefs = await SharedPreferences.getInstance();

    // Check Like
    List<String> likedVideos = prefs.getStringList('liked_videos') ?? [];
    if (likedVideos.contains(widget.videoModel.id)) {
      if (mounted) setState(() => _isLiked = true);
    }

    // Check Bookmark
    List<String> bookmarkedVideos =
        prefs.getStringList('bookmarked_videos') ?? [];
    if (bookmarkedVideos.contains(widget.videoModel.id)) {
      if (mounted) setState(() => _isBookmarked = true);
    }

    // Add to History
    List<String> historyVideos = prefs.getStringList('history_videos') ?? [];
    if (!historyVideos.contains(widget.videoModel.id)) {
      historyVideos.insert(0, widget.videoModel.id);
      await prefs.setStringList('history_videos', historyVideos);
    } else {
      // Move to top if already exists
      historyVideos.remove(widget.videoModel.id);
      historyVideos.insert(0, widget.videoModel.id);
      await prefs.setStringList('history_videos', historyVideos);
    }
  }

  Future<void> _checkIfDownloaded() async {
    try {
      final dir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();

      if (dir == null) return;
      String name = widget.videoModel.title.replaceAll(" ", "_");
      if (!name.endsWith(".mp4")) name = "$name.mp4";
      final videoPath = "${dir.path}/$name";
      if (await File(videoPath).exists()) {
        if (mounted) setState(() => _isDownloaded = true);
      }
    } catch (e) {
      debugPrint("Error checking download status: $e");
    }
  }

  void _showVideoAdBeforePlay() {
    final adId = AdManager.rewardedInterstitialAdUnitIds['unlockFullVideo'];

    if (adId == null || adId.isEmpty) {
      return;
    }

    RewardedInterstitialAdManager().showAd(
      adUnitId: adId,
      onComplete: (bool earned) {
        debugPrint("✅ Video unlock ad completed. Earned: $earned");
        if (earned) {
          // 🔥 ALLOW VIDEO
        } else {
          Get.snackbar(
            "Watch Full Ad",
            "You must watch the entire ad to unlock video.",
          );
        }
      },
    );
  }

  Future<void> _downloadWithAd(VideoModel video) async {
    if (_isAdLoading) return;

    final adId1 = AdManager.rewardedAdUnitIds["rewarded_download"] ?? "";
    final adId2 = AdManager.rewardedAdUnitIds["downlaod_button_ad"] ?? "";

    if (adId1.isEmpty) {
      downloadController.startDownload(video);
      if (mounted) setState(() => _isAdLoading = false);
      return;
    }

    debugPrint("🎬 1st Rewarded Ad Request ID: $adId1");
    RewardedAdManager().showAd(
      adUnitId: adId1,
      onComplete: (bool earned1) {
        if (!mounted) return;

        if (!earned1) {
          setState(() => _isAdLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Watch full ad to continue download")),
          );
          return;
        }

        if (adId2.isEmpty) {
          setState(() => _isAdLoading = false);
          downloadController.startDownload(video);
          return;
        }

        debugPrint("🎬 2nd Rewarded Ad Request ID: $adId2");
        RewardedAdManager().showAd(
          adUnitId: adId2,
          onComplete: (bool earned2) {
            if (!mounted) return;

            setState(() => _isAdLoading = false);

            if (earned2) {
              downloadController.startDownload(video);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Watch full second ad to download"),
                ),
              );
            }
          },
        );
      },
    );
  }

  String _dateText(DateTime dt) {
    final d = DateTime.now().difference(dt).inDays;
    if (d == 0) return "Today";
    if (d == 1) return "1 day ago";
    return "$d days ago";
  }

  bool _isFullScreen = false;

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isFullScreen,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isFullScreen) {
          _toggleFullScreen();
        }
      },
      child: _isFullScreen ? _buildFullScreenPlayer() : _buildNormalScreen(),
    );
  }

  Widget _buildFullScreenPlayer() {
    final video = widget.videoModel;
    final String playPath = resolveVideoPath(video);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CustomVideoPlayer(
          videoModel: video,
          videoPath: playPath,
          isFullScreen: true,
          onFullScreenToggle: _toggleFullScreen,
          onViewCounted: () {
            setState(() {
              video.views++;
            });
          },
        ),
      ),
    );
  }

  Widget _buildNormalScreen() {
    final video = widget.videoModel;
    final String playPath = resolveVideoPath(video);

    return Scaffold(
      backgroundColor: kblack,
      appBar: AppBar(
        backgroundColor: kbg1black500,
        centerTitle: true,
        title: const Text(
          "",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kwhite),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomVideoPlayer(
              videoModel: video,
              videoPath: playPath,
              isFullScreen: false,
              onFullScreenToggle: _toggleFullScreen,
              onViewCounted: () {
                setState(() {
                  video.views++;
                });
              },
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                video.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.remove_red_eye_outlined,
                    color: Colors.grey,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${video.views} views",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),

                  const SizedBox(width: 16),
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _dateText(video.date),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),

                  const SizedBox(width: 16),
                  const Icon(
                    Icons.sd_storage_outlined,
                    color: Colors.grey,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    video.size,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () async {
                      if (_isLiked) return;
                      videoController.likeVideo(video.id);
                      setState(() {
                        video.likes++;
                        _isLiked = true;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      List<String> likedVideos =
                          prefs.getStringList('liked_videos') ?? [];
                      likedVideos.add(video.id);
                      await prefs.setStringList('liked_videos', likedVideos);
                      if (mounted)
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('Liked!')));
                    },
                    child: _actionBtn(
                      _isLiked ? "Liked" : "Like (${video.likes})",
                      _isLiked
                          ? Icons.thumb_up_alt
                          : Icons.thumb_up_alt_outlined,
                      textColor: _isLiked ? AppTheme.primaryColor : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () => Share.share(
                      "Watch this video:\nhttps://diskly.in/${video.id}",
                    ),
                    child: _actionBtn("Share", Icons.ios_share_rounded),
                  ),
                  const SizedBox(width: 12),

                  Obx(() {
                    bool isDownloading = downloadController.isDownloading(
                      video.url,
                    );
                    double progress = downloadController.getProgress(video.url);

                    if (isDownloading) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1B2A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                value: progress,
                                color: kblueaccent,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${(progress * 100).toStringAsFixed(0)}%",
                              style: const TextStyle(
                                color: Color(0xFFB0B0C3),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (_isDownloaded) {
                      return InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Delete Video"),
                              content: const Text(
                                "Do you want to delete this downloaded video from your device?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    if (video.localPath != null) {
                                      try {
                                        final file = File(video.localPath!);
                                        if (await file.exists()) {
                                          await file.delete();
                                        }

                                        final prefs =
                                            await SharedPreferences.getInstance();
                                        List<String> downloadedVideos =
                                            prefs.getStringList(
                                              'downloaded_videos_list',
                                            ) ??
                                            [];
                                        downloadedVideos.removeWhere(
                                          (v) =>
                                              jsonDecode(v)['id'] == video.id,
                                        );
                                        await prefs.setStringList(
                                          'downloaded_videos_list',
                                          downloadedVideos,
                                        );

                                        if (mounted) {
                                          setState(() {
                                            _isDownloaded = false;
                                            video.localPath = null;
                                          });
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Video deleted from downloads',
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted)
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Failed to delete video',
                                              ),
                                            ),
                                          );
                                      }
                                    }
                                  },
                                  child: const Text("Delete"),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              const Text(
                                "Downloaded",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (_isAdLoading) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1B2A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    }

                    return InkWell(
                      onTap: () => _downloadWithAd(video),
                      child: _actionBtn("Download", Icons.download_outlined),
                    );
                  }),

                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () async {
                      if (_isBookmarked) return;
                      videoController.downloadVideo(
                        video.id,
                      ); // Re-using backend logic
                      setState(() {
                        video.bookmarks++;
                        _isBookmarked = true;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      List<String> bookmarkedVideos =
                          prefs.getStringList('bookmarked_videos') ?? [];
                      bookmarkedVideos.add(video.id);
                      await prefs.setStringList(
                        'bookmarked_videos',
                        bookmarkedVideos,
                      );
                      if (mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reported!')),
                        );
                    },
                    child: _actionBtn(
                      _isBookmarked ? "Reported" : "Report",
                      _isBookmarked ? Icons.report : Icons.report_outlined,
                      textColor: Colors.red,
                    ),
                  ),

                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Save Video"),
                          content: const Text(
                            "You can save this video to your own admin account.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                final Uri url = Uri.parse(
                                  'https://t.me/DisklyFileUploader_Bot',
                                );
                                if (!await launchUrl(
                                  url,
                                  mode: LaunchMode.externalApplication,
                                )) {
                                  if (context.mounted)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Could not launch Telegram.',
                                        ),
                                      ),
                                    );
                                }
                              },
                              child: const Text("Open Telegram"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: _actionBtn("Save", Icons.cloud_download_outlined),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),

            if (video.adminName != null && video.adminName!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade800,
                      backgroundImage:
                          video.adminAvatar != null &&
                              video.adminAvatar!.isNotEmpty
                          ? NetworkImage(video.adminAvatar!)
                          : null,
                      child:
                          video.adminAvatar == null ||
                              video.adminAvatar!.isEmpty
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.adminName!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (video.adminEmail != null &&
                              video.adminEmail!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              video.adminEmail!,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: NativeVideoAdCard(adKey: "videoplayerscreenNative"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(
    String text,
    IconData icon, {
    Color? bgColor,
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor ?? const Color(0xFF1B1B2A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor ?? const Color(0xFFB0B0C3), size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: textColor ?? const Color(0xFFB0B0C3),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// CUSTOM VIDEO PLAYER
////////////////////////////////////////////////////////////

class CustomVideoPlayer extends StatefulWidget {
  final String videoPath;
  final VideoModel videoModel;
  final bool isFullScreen;
  final VoidCallback onFullScreenToggle;
  final VoidCallback onViewCounted;

  const CustomVideoPlayer({
    super.key,
    required this.videoPath,
    required this.videoModel,
    required this.isFullScreen,
    required this.onFullScreenToggle,
    required this.onViewCounted,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController? _controller;
  bool _showControls = true;
  bool _countedView = false;
  bool _hasError = false;
  String _errorMessage = "";
  Timer? _hideTimer;

  final videoController = Get.find<VideoController>();

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();

    final path = widget.videoPath.trim();
    debugPrint("🎬 VideoPlayer Init: path=$path");

    _initializeVideo();
    _startHideTimer();
  }

  @override
  void didUpdateWidget(CustomVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoPath != widget.videoPath) {
      debugPrint("🎬 VideoPlayer path updated: ${widget.videoPath}");
      _initializeVideo();
    }
  }

  void _initializeVideo() {
    debugPrint("🎬 VideoPlayer Attempting Init...");
    setState(() {
      _hasError = false;
      _errorMessage = "";
    });

    final path = widget.videoPath.trim();

    _controller?.dispose();

    _controller = path.startsWith("http")
        ? VideoPlayerController.networkUrl(Uri.parse(path))
        : VideoPlayerController.file(File(path));

    _controller!
        .initialize()
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException("Video source too slow or unreachable.");
          },
        )
        .then((_) {
          debugPrint("✅ Video initialized successfully");
          if (!mounted) return;
          setState(() {
            _hasError = false;
          });
          _controller?.play();

          _controller!.addListener(() {
            if (!mounted) return;

            if (_controller!.value.position.inSeconds >= 1 && !_countedView) {
              _countedView = true;
              videoController.countViewAndEarning(widget.videoModel);
              widget.onViewCounted();
            }

            if (_controller!.value.isPlaying) {
              setState(() {});
            }
          });
        })
        .catchError((error) {
          debugPrint("❌ Video Init Error: $error");
          if (!mounted) return;
          setState(() {
            _hasError = true;
            _errorMessage = error.toString();
          });
        });
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 7), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _controller?.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: 220,
        color: Colors.black,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.white, size: 40),
            const SizedBox(height: 10),
            const Text(
              "Video Failed to Load",
              style: TextStyle(color: Colors.white),
            ),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: _initializeVideo,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return SizedBox(
        width: double.infinity,
        height: widget.isFullScreen ? MediaQuery.of(context).size.height : 220,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: () {
            setState(() => _showControls = !_showControls);
            if (_showControls) _startHideTimer();
          },
          child: SizedBox(
            width: double.infinity,
            height: widget.isFullScreen
                ? MediaQuery.of(context).size.height
                : 220,
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),
        ),

        if (_controller!.value.isBuffering)
          const Center(child: CircularProgressIndicator(color: Colors.white)),

        if (_showControls && !_controller!.value.isBuffering)
          Container(
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, right: 10),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(
                        widget.isFullScreen
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: widget.onFullScreenToggle,
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.replay_10_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                      onPressed: () {
                        final pos = _controller!.value.position;
                        final target = pos - const Duration(seconds: 10);
                        _controller!.seekTo(
                          target < Duration.zero ? Duration.zero : target,
                        );
                        _startHideTimer();
                      },
                    ),

                    const SizedBox(width: 30),

                    IconButton(
                      icon: Icon(
                        _controller!.value.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill,
                        size: 64,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _controller!.value.isPlaying
                              ? _controller!.pause()
                              : _controller!.play();
                        });
                        _startHideTimer();
                      },
                    ),

                    const SizedBox(width: 30),

                    IconButton(
                      icon: const Icon(
                        Icons.forward_10_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                      onPressed: () {
                        final pos = _controller!.value.position;
                        final end = _controller!.value.duration;
                        final target = pos + const Duration(seconds: 10);
                        _controller!.seekTo(target > end ? end : target);
                        _startHideTimer();
                      },
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Row(
                    children: [
                      Text(
                        _formatDuration(_controller!.value.position),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          activeColor: kblueaccent,
                          inactiveColor: Colors.white24,
                          min: 0,
                          max: _controller!.value.duration.inSeconds.toDouble(),
                          value: _controller!.value.position.inSeconds
                              .toDouble()
                              .clamp(
                                0,
                                _controller!.value.duration.inSeconds
                                    .toDouble(),
                              ),
                          onChanged: (val) {
                            _controller!.seekTo(Duration(seconds: val.toInt()));
                            _startHideTimer();
                          },
                        ),
                      ),
                      Text(
                        _formatDuration(_controller!.value.duration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      final hh = d.inHours.toString().padLeft(2, '0');
      final mm = (d.inMinutes % 60).toString().padLeft(2, '0');
      final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
      return "$hh:$mm:$ss";
    }
    final mm = d.inMinutes.toString().padLeft(2, '0');
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$mm:$ss";
  }
}

////////////////////////////////////////////////////////////
/// HELPER
////////////////////////////////////////////////////////////

String resolveVideoPath(VideoModel video) {
  if (video.localPath != null &&
      video.localPath!.isNotEmpty &&
      File(video.localPath!).existsSync()) {
    return video.localPath!;
  }
  return video.url;
}
