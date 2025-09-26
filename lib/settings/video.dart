import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart' show Amplify, StorageGetUrlOptions, StoragePath;
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tubebox/model/video_model.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart'; // For orientation lock
import 'package:screen_brightness/screen_brightness.dart'; // Brightness Control
import 'package:flutter_volume_controller/flutter_volume_controller.dart'; // Volume Control
import 'dart:async';

import '../main.dart'; // For auto-hide overlay

class VideoPlayerScreen extends StatefulWidget {

  final VideoModel video;
  VideoPlayerScreen({required this.video});

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
    loadAd();
    _initializePlayer();
  }
  final List<Size> aspectRatios = [
    Size(16, 9),
    Size(4, 3),
    Size(1, 1),
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
    try {
        final urlResult = await Amplify.Storage.getUrl(
          path: StoragePath.fromString(widget.video.link),
          options:  StorageGetUrlOptions(
            pluginOptions: S3GetUrlPluginOptions(
              expiresIn: Duration(days: 1),
              validateObjectExistence: false,
              useAccelerateEndpoint: false,
            ),
          ),
        );

        final getUrlResult = await urlResult.result;
        final downloadUrl = getUrlResult.url.toString();
      _videoController = VideoPlayerController.network(downloadUrl);
      await _videoController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: true,
        allowFullScreen: true,
        playbackSpeeds: [1.0, 1.5, 1.25, 1.75, 2.0, 0.75, 0.5],
        showControls: false,
      );

      brightness = await ScreenBrightness().current;
      volume = (await FlutterVolumeController.getVolume())!;
      setState(() {
        mess="Success";
      });
    }catch(e){
      setState(() {
        mess=e.toString();
      });
    }

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

  String mess="NA";

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

  bool landscape_is=false;

  void _seekVideo(int seconds) {
    final currentPosition = _videoController.value.position;
    final newPosition = currentPosition + Duration(seconds: seconds);
    _videoController.seekTo(newPosition);
  }

  bool mute=false;
  Widget _buildBottomControls() {
    return landscape_is? AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: showControls ? 1.0 : 0.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          VideoProgressIndicator(
            _videoController,
            allowScrubbing: true,
            colors: VideoProgressColors(
              playedColor: Colors.red,
              bufferedColor: Colors.white60,
              backgroundColor: Colors.grey,
            ),
          ),
          Container(
            color: Colors.black54,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 25,),
                IconButton(
                  icon: mute?Icon(
                    Icons.volume_mute,
                    color: Colors.white,
                    size: 30,
                  ): Icon(
                    Icons.volume_down,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    if(mute){
                      _videoController.setVolume(0.5);
                      mute=false;

                    }else{
                      _videoController.setVolume(0);
                      mute=true;
                    }
                    setState(() {

                    });

                  },
                ),
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
                IconButton(
                  icon: Icon(Icons.fit_screen, color: Colors.white, size: 30),
                  onPressed: () {
                    _setPortraitMode();
                    landscape_is=false;
                    setState(() {

                    });
                  },
                ),
                SizedBox(width: 25,),
              ],
            ),
          ),
        ],
      ),
    ):AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: showControls ? 1.0 : 0.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          VideoProgressIndicator(
            _videoController,
            allowScrubbing: true,
            colors: VideoProgressColors(
              playedColor: Colors.red,
              bufferedColor: Colors.white60,
              backgroundColor: Colors.grey,
            ),
          ),
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
                    landscape_is=true;
                    _toggleScreenOrientation();
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
  Icon g({bool b=false}){
    if(aspectRatios==Size(16,9)){
      return Icon(Icons.photo_size_select_actual,color: b?Colors.greenAccent:b?Colors.greenAccent:Colors.white, size: 30,);
    }else  if(aspectRatios==Size(4,3)){
      return Icon(Icons.photo_filter_rounded,color: b?Colors.greenAccent:b?Colors.greenAccent:Colors.white, size: 30,);
    }else  if(aspectRatios==Size(1,1)){
      return Icon(Icons.square_sharp,color: b?Colors.greenAccent:b?Colors.greenAccent:Colors.white, size: 30,);
    }else  if(aspectRatios==Size(21,9)){
      return Icon(Icons.phone_android_outlined,color: b?Colors.greenAccent:b?Colors.greenAccent:Colors.white, size: 30,);
    }else  if(aspectRatios==Size(2,1)){
      return Icon(Icons.photo,color: b?Colors.greenAccent:b?Colors.greenAccent:Colors.white, size: 30,);
    }else  if(aspectRatios==Size(16,10)){
      return Icon(Icons.photo_camera_back_rounded,color: b?Colors.greenAccent:b?Colors.greenAccent:Colors.white, size: 30,);
    }else{
      return Icon(Icons.open_in_full_outlined,color: b?Colors.greenAccent:b?Colors.greenAccent:Colors.white, size: 30,);
    }
  }
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return landscape_is ? Scaffold(
      backgroundColor: Colors.black,
      body:  GestureDetector(
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
      )
    ) :Scaffold(
      backgroundColor:Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: CircleAvatar(
              backgroundColor: black,
              child: Icon(Icons.arrow_back,color: Colors.greenAccent,),
            ),
          ),
          actions: [
            InkWell(
              onTap: (){

              },
              child:                      Padding(
                padding: const EdgeInsets.only(left:9.0),
                child: CircleAvatar(
                  backgroundColor: black,
                  child: Icon(Icons.share_rounded,color: Colors.greenAccent,),
                ),
              ),
            ),
            InkWell(
              onTap: (){
                mess="NA";
                _initializePlayer();
                setState(() {

                });
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: CircleAvatar(
                  backgroundColor: black,
                  child: Icon(Icons.refresh,color: Colors.greenAccent,),
                ),
              ),
            ),
            InkWell(
              onTap: (){
                if(mute){
                  _videoController.setVolume(0.5);
                  mute=false;

                }else{
                  _videoController.setVolume(0);
                  mute=true;
                }
                setState(() {

                });
              },
              child: Padding(
                padding: const EdgeInsets.only(left:6.0 ),
                child: CircleAvatar(
                  backgroundColor: black,
                  child: mute==0?Icon(Icons.volume_mute,color: Colors.greenAccent,):Icon(Icons.volume_down,color: Colors.greenAccent,),
                ),
              ),
            ),
            InkWell(
              onTap: (){
                _changeAspectRatio();
              },
              child:                      Padding(
                padding: const EdgeInsets.only(left:6.0),
                child: CircleAvatar(
                  backgroundColor: black,
                  child: g(b: true),
                ),
              ),
            ),
            InkWell(
              onTap: (){
                landscape_is=true;
                _toggleScreenOrientation();
              },
              child: Padding(
                padding: const EdgeInsets.only(left:6.0,right: 12),
                child: CircleAvatar(
                  backgroundColor: black,
                  child: Icon(Icons.screen_lock_rotation,color: Colors.greenAccent,),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            mess=="Success"?GestureDetector(
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
              child: Stack(
                children: [
                  Container(
                    width: w,height: w*9/16,
                    child: Center(
                      child: _chewieController != null &&
                          _chewieController!.videoPlayerController.value.isInitialized
                          ? Chewie(controller: _chewieController!)
                          : CircularProgressIndicator(),
                    ),
                  ),
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
            ):(mess=="NA"?Container(
              width: w,height: w*9/16,
              child: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
              ),
            ):Container(
              width: w,height: w*9/16,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.warning,color: Colors.white,size: 30,),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7.0),
                    child: Text("Video have Error or is Deleted",style: TextStyle(fontWeight: FontWeight.w800,color: Colors.white),),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text(mess,textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontSize: 10),),
                  ),
                ],
              ),
            )),
            Padding(
              padding: const EdgeInsets.only(left: 22,right: 22,top: 9),
              child: Text("ayuksh"=="ayush"?"Aikatsu Dreaming Stars New Song":widget.video.name,style: TextStyle(fontSize: 22,fontWeight: FontWeight.w800,color: Colors.white),),
            ),
            Row(
              children: [
                SizedBox(width: 22,),
                t("43 Views"),
                t("649 MB"), t("20 Days Ago"),

               ],
            ),
            SizedBox(height: 10,),
            Row(
              children: [
                SizedBox(width: 19,),
                widget.video.hd ? const Icon(Icons.hd, color: Colors.green,size: 30,) : SizedBox(),
                widget.video.sd ? const Icon(Icons.sd, color: Colors.red,size: 30,) : SizedBox(),
                SizedBox(width: 6,),
                Icon(Icons.share_outlined, color: Colors.blue,size: 27,),
                widget.video.s1.isNotEmpty ? Text(widget.video.s1,style: TextStyle(fontWeight: FontWeight.w700),) : SizedBox(),
              ],
            ),
            SizedBox(height: 10,),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: AssetImage("assets/tubebox.png"),
              ),
              title: Text("TubeBox.in",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w800),),
            ),
            Spacer(),
            _nativeAdIsLoaded
                ? Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                                height: 300, // Give some height
                                child: AdWidget(ad: nativeAd!),
                              ),
                )
                : SizedBox(),

          ],
        ),
    );
  }
  Widget t(String str)=>Padding(
    padding: const EdgeInsets.only(right: 14.0),
    child: Text(str,style: TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.w600),),
  );

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-2242333705148339/1612989900'
      : 'ca-app-pub-3940256099942544/3986624511';
  NativeAd? nativeAd;

  bool _nativeAdIsLoaded = false;

  void loadAd() {
    nativeAd = NativeAd(
        adUnitId: _adUnitId,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            debugPrint('$NativeAd loaded.');
            setState(() {
              _nativeAdIsLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            // Dispose the ad here to free resources.
            debugPrint('$NativeAd failed to load: $error');
            ad.dispose();
          },
        ),
        request: const AdRequest(),
        // Styling
        nativeTemplateStyle: NativeTemplateStyle(
          // Required: Choose a template.
            templateType: TemplateType.medium,
            // Optional: Customize the ad's style.
            mainBackgroundColor: Colors.purple,
            cornerRadius: 10.0,
            callToActionTextStyle: NativeTemplateTextStyle(
                textColor: Colors.cyan,
                backgroundColor: Colors.red,
                style: NativeTemplateFontStyle.monospace,
                size: 16.0),
            primaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.red,
                backgroundColor: Colors.cyan,
                style: NativeTemplateFontStyle.italic,
                size: 16.0),
            secondaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.green,
                backgroundColor: Colors.black,
                style: NativeTemplateFontStyle.bold,
                size: 16.0),
            tertiaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.brown,
                backgroundColor: Colors.amber,
                style: NativeTemplateFontStyle.normal,
                size: 16.0)))
      ..load();
  }

  Color black=Colors.black;
}
