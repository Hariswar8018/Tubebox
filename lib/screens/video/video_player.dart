import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tubeboxs/utils/adsunit/adsunit.dart';
import 'package:video_player/video_player.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:tubeboxs/model/video.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class AdvancedPlayerScreen extends StatefulWidget {
  final Video video;

  const AdvancedPlayerScreen({super.key, required this.video});

  @override
  State<AdvancedPlayerScreen> createState() => _AdvancedPlayerScreenState();
}

class _AdvancedPlayerScreenState extends State<AdvancedPlayerScreen> {
  late VideoPlayerController _controller;

  bool isFullScreen = false;
  bool showControls = true;

  double brightness = 0.5;
  double volume = 0.5;

  bool showVolumeUI = false;
  bool showBrightnessUI = false;

  Timer? _hideTimer;

  int skipSeconds = 10;

  @override
  void initState() {
    super.initState();
    loadAd();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.videoUrl),
    )..initialize().then((_) {
      setState(() {});
      _controller.play();
      WakelockPlus.enable();
      startHideTimer();
    });
  }
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  void loadAd() {
    _nativeAd = NativeAd(
      adUnitId: Adsunit.native,
      factoryId: 'listTile',
      request: AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _isAdLoaded = true;
          setState(() {});
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print("Ad failed: $error");
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _hideTimer?.cancel();
    _nativeAd?.dispose();
    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    super.dispose();
  }

  // ------------------ UTIL ------------------

  void togglePlay() {
    setState(() {
      _controller.value.isPlaying
          ? _controller.pause()
          : _controller.play();
    });
    startHideTimer();
  }

  void seekRelative(int seconds) {
    final position = _controller.value.position;
    final duration = _controller.value.duration;

    final newPosition = position + Duration(seconds: seconds);

    _controller.seekTo(
      newPosition < Duration.zero
          ? Duration.zero
          : newPosition > duration
          ? duration
          : newPosition,
    );
  }

  void startHideTimer() {
    _hideTimer?.cancel();

    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => showControls = false);
      }
    });
  }

  void toggleFullScreen() {
    if (isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } else {
      // Force landscape right/left for better video viewing, and let orientation sensor handle it
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    setState(() {
      isFullScreen = !isFullScreen;
    });
  }

  Widget _buildVideo() {
    BoxFit fit;

    switch (fitMode) {
      case VideoFitMode.cover:
        fit = BoxFit.cover;
        break;
      case VideoFitMode.fill:
        fit = BoxFit.fill;
        break;
      default:
        fit = BoxFit.contain;
    }

    return SizedBox.expand( // 🔥 FORCE FULL SCREEN
      child: FittedBox(
        fit: fit,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }

  String format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  // ------------------ BUILD ------------------

  @override
  Widget build(BuildContext context) {
    return isFullScreen?Scaffold(
      backgroundColor: Colors.black,
      body: _buildPlayerStack(),
    ):Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.web_sharp)),
          IconButton(onPressed: (){}, icon: Icon(Icons.warning_outlined)),
        ],
      ),
      body: SafeArea(
        child: _buildPortraitLayout(),
      ),
    );
  }


  Widget _buildPortraitLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🎬 VIDEO
          Container(
            height: MediaQuery.of(context).size.width * 9 / 16,
            child: _buildPlayerStack(),
          ),

          /// 📝 TITLE + META
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.video.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "1.2M views • 2 days ago",
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _ActionItem(icon: Icons.thumb_up_alt_outlined, label: "Like"),
                _ActionItem(icon: Icons.share_outlined, label: "Share"),
                //_ActionItem(icon: Icons.download_outlined, label: "Download"),
                _ActionItem(icon: Icons.document_scanner_rounded, label: "Info"),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _isAdLoaded
              ? SizedBox(
            height: 250,
            child: AdWidget(ad: _nativeAd!),
          )
              : SizedBox()

        ],
      ),
    );
  }
  Widget _buildPlayerStack() {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => showControls = !showControls);
        if (showControls) startHideTimer();
      },

      onVerticalDragUpdate: (details) async {
        final dx = details.localPosition.dx;
        final width = MediaQuery.of(context).size.width;

        if (dx < width / 2) {
          /// Brightness
          brightness -= details.delta.dy * 0.005;
          brightness = brightness.clamp(0.0, 1.0);
          await ScreenBrightness().setScreenBrightness(brightness);

          showBrightnessUI = true;
          showVolumeUI = false;
        } else {
          /// Volume
          volume -= details.delta.dy * 0.005;
          volume = volume.clamp(0.0, 1.0);
          _controller.setVolume(volume);

          showVolumeUI = true;
          showBrightnessUI = false;
        }

        setState(() {});

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              showVolumeUI = false;
              showBrightnessUI = false;
            });
          }
        });
      },

      child: Stack(
        children: [
          Center(child: _buildVideo()),
          /// Gesture indicators
          if (showBrightnessUI)
            const Center(
              child: Icon(Icons.brightness_6,
                  color: Colors.white, size: 50),
            ),

          if (showVolumeUI)
            const Center(
              child: Icon(Icons.volume_up,
                  color: Colors.white, size: 50),
            ),

          /// Controls
          if (showControls)
            isFullScreen
                ? _buildFullControls()
                : _buildPortraitControls(),
        ],
      ),
    );
  }

  // ------------------ PORTRAIT CONTROLS ------------------

  Widget _buildPortraitControls() {
    return Positioned.fill(
      child: Container(
        color: Colors.black45,
        child: Column(
          children: [
            const Spacer(),

            /// 🎮 CENTER CONTROLS (ALL IN ONE LINE)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                /// Fit option
                IconButton(
                  icon: Icon(
                    _getFitIcon(),
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      if (fitMode == VideoFitMode.contain) {
                        fitMode = VideoFitMode.cover;
                      } else if (fitMode == VideoFitMode.cover) {
                        fitMode = VideoFitMode.fill;
                      } else {
                        fitMode = VideoFitMode.contain;
                      }
                    });
                  },
                ),

                /// ⏪ BACKWARD
                IconButton(
                  icon: const Icon(Icons.replay_10, color: Colors.white),
                  onPressed: () => seekRelative(-skipSeconds),
                ),

                /// ▶️ PLAY / PAUSE (CENTER BIG)
                IconButton(
                  icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause_circle
                        : Icons.play_circle,
                    color: Colors.white,
                    size: 55,
                  ),
                  onPressed: togglePlay,
                ),

                /// ⏩ FORWARD
                IconButton(
                  icon: const Icon(Icons.forward_10, color: Colors.white),
                  onPressed: () => seekRelative(skipSeconds),
                ),

                /// ⛶ FULLSCREEN (RIGHT)
                IconButton(
                  icon: const Icon(Icons.fullscreen, color: Colors.white),
                  onPressed: toggleFullScreen,
                ),
              ],
            ),

            const SizedBox(height: 15),

            /// 📊 PROGRESS BAR (BOTTOM) with remaining/elapsed duration
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Text(
                    format(_controller.value.position),
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Colors.orange,
                        bufferedColor: Colors.grey,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    format(_controller.value.duration),
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ------------------ FULLSCREEN CONTROLS ------------------

  Widget _buildFullControls() {
    return Positioned.fill(
      child: Stack(
        children: [
          /// 🔝 TOP BAR
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: Colors.black.withOpacity(0.7),
              child: Row(
                children: [
                  /// 🎬 THUMBNAIL
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      widget.video.thumbnailUrl,
                      height: 45,
                      width: 70,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// 📝 TITLE + DESCRIPTION
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.video.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.video.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  /// ⚙️ MENU
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: _openMenu,
                  ),
                ],
              ),
            ),
          ),



          /// 🔻 BOTTOM CONTROLS
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  /// 📊 PROGRESS BAR
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Text(
                          format(_controller.value.position),
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: VideoProgressIndicator(
                            _controller,
                            allowScrubbing: true,
                            colors: const VideoProgressColors(
                              playedColor: Colors.orange,
                              bufferedColor: Colors.grey,
                              backgroundColor: Colors.white24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          format(_controller.value.duration),
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const SizedBox(width: 10),
                      IconButton(
                        icon: Icon(
                          _getFitIcon(),
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            if (fitMode == VideoFitMode.contain) {
                              fitMode = VideoFitMode.cover;
                            } else if (fitMode == VideoFitMode.cover) {
                              fitMode = VideoFitMode.fill;
                            } else {
                              fitMode = VideoFitMode.contain;
                            }
                          });
                        },
                      ),


                      IconButton(
                        icon: const Icon(Icons.replay_10,
                            color: Colors.white, size: 30),
                        onPressed: () => seekRelative(-skipSeconds),
                      ),



                      IconButton(
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause_circle
                              : Icons.play_circle,
                          color: Colors.white,
                          size: 65,
                        ),
                        onPressed: togglePlay,
                      ),


                      IconButton(
                        icon: const Icon(Icons.forward_10,
                            color: Colors.white, size: 30),
                        onPressed: () => seekRelative(skipSeconds),
                      ),
                      IconButton(
                        icon: const Icon(Icons.fullscreen_exit,
                            color: Colors.white),
                        onPressed: toggleFullScreen,
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  IconData _getFitIcon() {
    switch (fitMode) {
      case VideoFitMode.contain:
        return Icons.fit_screen;     // normal fit
      case VideoFitMode.cover:
        return Icons.zoom_out_map;   // zoom / crop
      case VideoFitMode.fill:
        return Icons.fullscreen;     // stretch
    }
  }
  bool isLooping = false;
  void toggleLoop() {
    setState(() {
      isLooping = !isLooping;
      _controller.setLooping(isLooping);
    });
  }
  // ------------------ MENU ------------------

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.repeat,
                color: isLooping ? Colors.orange : Colors.white,
              ),
              title: Text(
                isLooping ? "Loop: ON" : "Loop: OFF",
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                toggleLoop();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading:
              const Icon(Icons.speed, color: Colors.white),
              title: const Text("Playback Speed",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showSpeedDialog();
              },
            ),
            ListTile(
              leading:
              const Icon(Icons.timer, color: Colors.white),
              title: const Text("Skip Duration",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showSkipDialog();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSpeedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text("Playback Speed",
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [0.5, 1.0, 1.5, 2.0].map((speed) {
            return ListTile(
              title: Text("$speed x",
                  style: const TextStyle(color: Colors.white)),
              onTap: () {
                _controller.setPlaybackSpeed(speed);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSkipDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text("Skip Duration",
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [5, 10, 15, 30].map((sec) {
            return ListTile(
              title: Text("$sec sec",
                  style: const TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => skipSeconds = sec);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
  VideoFitMode fitMode = VideoFitMode.contain;
}
enum VideoFitMode { contain, cover, fill }

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}