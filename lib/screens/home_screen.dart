import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubeboxs/backend/video/video_api.dart';
import 'package:tubeboxs/model/video.dart';
import 'package:tubeboxs/screens/video/video_player.dart'
    show AdvancedPlayerScreen;
import 'package:tubeboxs/utils/adsunit/adsunit.dart';
import 'package:tubeboxs/utils/messages/show_message.dart';
import 'package:app_links/app_links.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController controller = TextEditingController();

  Video? video = null;
  bool isloading = false;
  BannerAd? _bannerAd;
  NativeAd? _nativeAd;
  bool _isNativeAdLoaded = false;

  void loadNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: Adsunit.native,
      factoryId: 'listTile',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isNativeAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print("Native Ad failed to load: $error");
        },
      ),
    )..load();
  }
  String extractId(String url) {
    try {
      final uri = Uri.parse(url);

      // Example: https://domain.com/video/abc123
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last;
      }

      return url; // fallback
    } catch (e) {
      return url;
    }
  }
  fetchbyLink(String link) async {
    try {
      final id = extractId(link);
      setState(() {
        isloading = true;
        controller.text = id;
      });
      print(id);
      Video myvideo = await VideoService.getVideoById(id);
      setState(() {
        video = myvideo;
        isloading = false;
      });
      Send.topic(
        context,
        "Successful",
        "Video Fetched Successfully from Link. Click to View the Video",
        b: true,
      );
    } catch (e) {
      print("Error------------------------------>");
      print(e);
      setState(() {
        isloading = false;
      });
    }
  }
  StreamSubscription<String>? _linkSubscription;

  Future<void> initUniLinks() async {
    try {
      final appLinks = AppLinks();
      // Handle initial link (when app launches for the first time)
      String? initialLink = await appLinks.getInitialLinkString();
      if (initialLink != null) {
        fetchbyLink(initialLink);
      }
      _linkSubscription = appLinks.stringLinkStream.listen((String link) async {
        fetchbyLink(link);
      }, onError: (err) {
        print("Error receiving link: $err");
      });
    } catch (e) {
      print("Error initializing links: $e");
    }
  }
  @override
  void initState() {
    super.initState();
    initUniLinks();
    loadNativeAd();
    _bannerAd = BannerAd(
      adUnitId: Adsunit.banner,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(),
    )..load();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _nativeAd?.dispose();
    super.dispose();
  }
  InterstitialAd? _interstitialAd;
  int tapCount = 0;
  bool shouldShowAd(int count) {
    return count % 2 == 1;
  }
  Future<void> loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    tapCount = prefs.getInt('tapCount') ?? 0;
  }
  Future<void> saveCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tapCount', tapCount);
  }
  void loadInterstitialAd() {
    InterstitialAd.load( adUnitId: Adsunit.interstitial, request: AdRequest(), adLoadCallback: InterstitialAdLoadCallback( onAdLoaded: (ad) => _interstitialAd = ad, onAdFailedToLoad: (error) => print(error), ), ); }

  Future<void> onButtonPressed(BuildContext context) async {
    tapCount++;
    await saveCounter();

    if (tapCount % 2 == 1) {
      // SHOW AD
      if (_interstitialAd != null) {
        _interstitialAd!.fullScreenContentCallback =
            FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                loadInterstitialAd(); // preload next
                navigateNext(context);
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                navigateNext(context);
              },
            );

        _interstitialAd!.show();
        _interstitialAd = null;
      } else {
        navigateNext(context);
      }
    } else {
      navigateNext(context);
    }
  }
  void navigateNext(BuildContext context) {
    addId(video!.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AdvancedPlayerScreen(video: video!),
      ),
    );
  }
  Future<void> addId(String id) async {
    const String _kIdsKey = 'stored_unique_ids';
    final prefs = await SharedPreferences.getInstance();

    final List<String> ids = prefs.getStringList(_kIdsKey) ?? [];

    if (!ids.contains(id)) {
      ids.add(id);
      await prefs.setStringList(_kIdsKey, ids);
    }
  }
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width - 15;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            isloading
                ? LinearProgressIndicator(
                    backgroundColor: Colors.white,
                    color: Color(0xFF10B981),
                  )
                : SizedBox(),
            const SizedBox(height: 20),
            Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: Container(
                      width: w - 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: const Color(0xff181818),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 40),
                          const Text(
                            'Input your Tubebox Link to access',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: TextField(
                                style: const TextStyle(color: Colors.white),
                                controller: controller,
                                decoration: InputDecoration(
                                  hintText: 'Paste Tuebbox URL here...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          isloading
                              ? const CircularProgressIndicator(
                                  color: Color(0xFF10B981),
                                  backgroundColor: Colors.white,
                                )
                              : video == null
                              ? Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.black,
                                    ),
                                    onPressed: () async {
                                      try {
                                        setState(() {
                                          isloading = true;
                                        });
                                        print(controller.text);
                                        final String id = controller.text
                                            .trim()
                                            .substring(19);
                                        print(id);
                                        final fetchvideo =
                                            await VideoService.getVideoById(id);
                                        Send.topic(
                                          context,
                                          "Successful",
                                          "Video Fetched Successfully. Click to View the Video",
                                          b: true,
                                        );
                                        setState(() {
                                          video = fetchvideo;
                                          isloading = false;
                                        });
                                      } catch (e) {
                                        Send.topic(
                                          context,
                                          "Error on Video Fetching",
                                          "${e}",
                                        );
                                        setState(() {
                                          isloading = false;
                                        });
                                      }
                                    },
                                  ),
                                )
                              : InkWell(
                                  onTap: () {
                                    onButtonPressed(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Container(
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 13.0),
                                        child: Row(
                                          children: [
                                            const SizedBox(width: 4,),
                                            Container(
                                              width: 90,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(4),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                    video!.thumbnailUrl,
                                                  ),fit: BoxFit.cover
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10,),
                                            SizedBox(
                                              width: w-230,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    video!.title,
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.w800,fontSize: 14
                                                    ),
                                                    maxLines: 1,
                                                  ),
                                                  Text(
                                                    video!.description,
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.w300,fontSize: 9
                                                    ),
                                                    maxLines: 2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Spacer(),
                                            const CircleAvatar(
                                              backgroundColor:  Color(0xFF10B981),
                                              child: Icon(
                                                Icons.arrow_forward_outlined,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          if (_isNativeAdLoaded && _nativeAd != null) ...[
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 300,
                              child: AdWidget(ad: _nativeAd!),
                            ),
                          ],
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Access TubeBox Video',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_bannerAd != null)
              SizedBox(
                height: _bannerAd!.size.height.toDouble(),
                width: _bannerAd!.size.width.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            const SizedBox(height: 20),
            Stack(
              children: [
                Center(child: Container(width: w, height: 280)),
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 25),
                    child: Container(
                      width: w - 20,
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Color(0xff181818),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top:15.0,bottom: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildFeatureItem(Icons.cloud, 'Cloud Storage'),
                                _buildFeatureItem(Icons.file_copy, 'Multiple Files'),
                                _buildFeatureItem(Icons.share, 'Share via Link'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildFeatureItem(Icons.security, 'AI Powered Data'),
                                _buildFeatureItem(Icons.speed, 'Fast Playback'),
                                _buildFeatureItem(Icons.apps, 'CDN Caching'),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Features',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 140),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: const Color(0xFF10B981), size: 32),
        const SizedBox(height: 12),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}
