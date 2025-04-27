import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart'; // For orientation lock
import 'package:screen_brightness/screen_brightness.dart'; // Brightness Control
import 'package:flutter_volume_controller/flutter_volume_controller.dart'; // Volume Control
import 'dart:async'; // For auto-hide overlay

class VideoPlayerScreen extends StatefulWidget {
  final String link;
  VideoPlayerScreen({required this.link});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool isLocked = false; // Lock screen functionality
  bool showControls = false; // To toggle the overlay
  double brightness = 0.5;
  double volume = 0.5;
  bool isLooping = false; // Loop toggle
  Timer? _overlayTimer;
  bool isVolumeBrightnessVisible = false; // To auto-hide Volume & Brightness UI

  @override
  void initState() {
    super.initState();
    _setLandscapeMode();
    _initializePlayer();
  }
  final List<Size> aspectRatios = [
    Size(16, 9),  // Fit to screen (Default)
    Size(4, 3),   // YouTube Size
    Size(1, 1),   // Phone Size (Square)
    Size(21, 9),  // Cinematic
    Size(2, 1),   // Zoom Mode
    Size(16, 10), // With Padding
    Size(9, 16),
  ];

  void _changeAspectRatio() {
    setState(() {
      aspectRatioIndex = (aspectRatioIndex + 1) % aspectRatios.length; // Cycle through ratios
      _chewieController?.dispose();
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: isLooping,
        allowFullScreen: true,
        playbackSpeeds: [1.0, 1.25, 1.5, 1.75, 2.0, 0.75, 0.5],
        showControls: false,
        aspectRatio: aspectRatios[aspectRatioIndex].width / aspectRatios[aspectRatioIndex].height,
      );
    });
  }
  int aspectRatioIndex = 0;
  Future<void> _initializePlayer() async {
    _videoController = VideoPlayerController.network(widget.link);
    await _videoController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping:true,
      allowFullScreen: true,playbackSpeeds: [1.0,1.5,1.25,1.75,2.0,0.75,0.5],
      showControls: false,
    );

    brightness = await ScreenBrightness().current;
    volume = (await FlutterVolumeController.getVolume())!;

    setState(() {});
  }

  @override
  void dispose() {
    _setPortraitMode();
    _videoController.dispose();
    _chewieController?.dispose();
    _overlayTimer?.cancel();
    super.dispose();
  }

  // Set landscape mode
  void _setLandscapeMode() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  // Restore portrait mode when screen is closed
  void _setPortraitMode() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Auto-hide controls after 3 seconds
  void _startOverlayTimer() {
    _overlayTimer?.cancel(); // Reset timer
    _overlayTimer = Timer(Duration(seconds: 3), () {
      setState(() {
        showControls = false;
        isVolumeBrightnessVisible = false; // Hide volume & brightness info
      });
    });
  }

  // Gesture-based controls (Brightness & Volume) - Fixed Direction
  void _onVerticalDrag(DragUpdateDetails details, bool isLeftSide) async {
    setState(() => isVolumeBrightnessVisible = true); // Show volume/brightness info

    if (isLeftSide) {
      // Adjust brightness
      brightness -= details.primaryDelta! * 0.005; // Reverse Direction
      brightness = brightness.clamp(0.0, 1.0);
      await ScreenBrightness().setScreenBrightness(brightness);
    } else {
      // Adjust volume
      volume -= details.primaryDelta! * 0.005; // Reverse Direction
      volume = volume.clamp(0.0, 1.0);
      await FlutterVolumeController.setVolume(volume);
    }

    _startOverlayTimer();
  }

  // Seek Video
  void _seekVideo(int seconds) {
    final currentPosition = _videoController.value.position;
    final newPosition = currentPosition + Duration(seconds: seconds);
    _videoController.seekTo(newPosition);
  }

  // Custom Bottom Controls with Progress Bar
  Widget _buildBottomControls() {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: showControls ? 1.0 : 0.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress Bar
          VideoProgressIndicator(
            _videoController,
            allowScrubbing: true,
            colors: VideoProgressColors(
              playedColor: Colors.red,
              bufferedColor: Colors.white60,
              backgroundColor: Colors.grey,
            ),
          ),

          // Buttons Row
          Container(
            color: Colors.black54,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 25,),
                IconButton(
                  icon: Icon(
                    isPortraitMode ? Icons.screen_rotation : Icons.stay_primary_landscape,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    _toggleScreenOrientation();
                    _startOverlayTimer();
                  },
                ),

                IconButton(
                  icon: Icon(Icons.replay_10, color: Colors.white, size: 30),
                  onPressed: () {
                    _seekVideo(-10);
                    _startOverlayTimer();
                  },
                ),
                IconButton(
                  icon: Icon(
                    _videoController.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_videoController.value.isPlaying) {
                        _videoController.pause();
                      } else {
                        _videoController.play();
                      }
                      _startOverlayTimer();
                    });
                  },
                ),

                // 15s Forward Button
                IconButton(
                  icon: Icon(Icons.forward_10, color: Colors.white, size: 30),
                  onPressed: () {
                    _seekVideo(10);
                    _startOverlayTimer();
                  },
                ),
                IconButton(
                  icon: g(),
                  onPressed: _changeAspectRatio,
                ),
                SizedBox(width: 25,),
              ],
            ),
          ),
        ],
      ),
    );
  }
  bool isPortraitMode = false; // Track Current Mode

  void _toggleScreenOrientation() {
    setState(() {
      isPortraitMode = !isPortraitMode;
    });

    if (isPortraitMode) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }
  Icon g(){
    if(aspectRatios==Size(16,9)){
      return Icon(Icons.photo_size_select_actual,color: Colors.white, size: 30,);
    }else  if(aspectRatios==Size(4,3)){
      return Icon(Icons.photo_filter_rounded,color: Colors.white, size: 30,);
    }else  if(aspectRatios==Size(1,1)){
      return Icon(Icons.square_sharp,color: Colors.white, size: 30,);
    }else  if(aspectRatios==Size(21,9)){
      return Icon(Icons.phone_android_outlined,color: Colors.white, size: 30,);
    }else  if(aspectRatios==Size(2,1)){
      return Icon(Icons.photo,color: Colors.white, size: 30,);
    }else  if(aspectRatios==Size(16,10)){
      return Icon(Icons.photo_camera_back_rounded,color: Colors.white, size: 30,);
    }else{
      return Icon(Icons.open_in_full_outlined,color: Colors.white, size: 30,);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() {
            showControls = !showControls;
            if (showControls) _startOverlayTimer();
          });
        },
        onVerticalDragUpdate: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          bool isLeftSide = details.globalPosition.dx < screenWidth / 2;
          _onVerticalDrag(details, isLeftSide);
        },
        onDoubleTap: () {
          setState(() {
            if (_videoController.value.isPlaying) {
              _videoController.pause();
            } else {
              _videoController.play();
            }
            _startOverlayTimer();
          });
        },
        child: Stack(
          children: [
            Center(
              child: _chewieController != null &&
                  _chewieController!.videoPlayerController.value.isInitialized
                  ? Chewie(controller: _chewieController!)
                  : CircularProgressIndicator(),
            ),

            // Custom Bottom Overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomControls(),
            ),

            // Brightness & Volume Info (Auto-Hide)
            Positioned(
              bottom: 60,
              left: 20,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: isVolumeBrightnessVisible ? 1.0 : 0.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Brightness: ${(brightness * 100).toInt()}%",
                        style: TextStyle(color: Colors.white)),
                    Text("Volume: ${(volume * 100).toInt()}%",
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
