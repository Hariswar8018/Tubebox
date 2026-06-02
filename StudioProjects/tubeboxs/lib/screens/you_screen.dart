import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubeboxs/screens/video/video_player.dart';
import 'package:tubeboxs/utils/adsunit/adsunit.dart';
import 'package:dio/dio.dart';

import '../model/video.dart' show Video;

class YouScreen extends StatefulWidget {
  const YouScreen({super.key});

  @override
  State<YouScreen> createState() => _YouScreenState();
}

class _YouScreenState extends State<YouScreen> {
   String _kIdsKey = 'stored_unique_ids';

   @override
   void initState(){
     super.initState();
     fetchVideos();
   }
  Future<List<String>> getAllIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kIdsKey) ?? [];
  }
   final Dio _dio = Dio();

   final String baseUrl =
       "https://tubeboxservers-production.up.railway.app/api/videos/bulk";
   Future<List<Video>> fetchVideos() async {
     final ids = await getAllIds();

     if (ids.isEmpty) {
       print("No IDs found");
       return [];
     }

     final response = await _dio.post(
       baseUrl,
       data: {"ids": ids},
     );

     final data = response.data;

     final List list = data['data'];

     videos = list.map((json) => Video.fromJson(json)).toList();

     print("🔥 Videos parsed: ${videos.length}");
     setState(() {

     });
     return videos;
   }
   List<Video> videos = [];

  RewardedAd? _rewardedAd;
   bool _isRewardedReady = false;

   int _retryCount = 0;
   final int _maxRetry = 2;
   void loadRewardedAd() {
     RewardedAd.load(
       adUnitId: Adsunit.rewarded,
       request: AdRequest(),
       rewardedAdLoadCallback: RewardedAdLoadCallback(
         onAdLoaded: (ad) {
           _rewardedAd = ad;
           _isRewardedReady = true;
           _retryCount = 0;

           print("✅ Rewarded loaded");
         },
         onAdFailedToLoad: (error) {
           _isRewardedReady = false;
           print("❌ Load failed: $error");
         },
       ),
     );
   }
   Future<void> showRewardedAndProceed(BuildContext context,Video video) async {
     // If ad is ready → show immediately
     if (_isRewardedReady && _rewardedAd != null) {
       _showAd(context,video);
       return;
     }

     // Otherwise → try loading + retry
     while (_retryCount < _maxRetry) {
       _retryCount++;

       print("🔁 Retry attempt: $_retryCount");

       await _loadAndWait();

       if (_isRewardedReady && _rewardedAd != null) {
         _showAd(context,video);
         return;
       }
     }

     // ❌ After retries → just continue
     print("⚠️ Ad failed after retries → navigating");
     _navigateNext(context,video);
   }
   Future<void> _loadAndWait() async {
     final completer = Completer<void>();

     RewardedAd.load(
       adUnitId: Adsunit.rewarded,
       request: AdRequest(),
       rewardedAdLoadCallback: RewardedAdLoadCallback(
         onAdLoaded: (ad) {
           _rewardedAd = ad;
           _isRewardedReady = true;
           completer.complete();
         },
         onAdFailedToLoad: (error) {
           _isRewardedReady = false;
           completer.complete();
         },
       ),
     );

     await completer.future;
   }
   void _showAd(BuildContext context,Video video) {
     _rewardedAd!.fullScreenContentCallback =
         FullScreenContentCallback(
           onAdDismissedFullScreenContent: (ad) {
             ad.dispose();
             _rewardedAd = null;
             _isRewardedReady = false;

             loadRewardedAd(); // preload next
             _navigateNext(context,video);
           },
           onAdFailedToShowFullScreenContent: (ad, error) {
             ad.dispose();
             _navigateNext(context,video);
           },
         );

     _rewardedAd!.show(
       onUserEarnedReward: (ad, reward) {
         print("🎁 Reward earned: ${reward.amount}");
       },
     );
   }
   void _navigateNext(BuildContext context, Video video) {
     Navigator.push(
       context,
       MaterialPageRoute(
         builder: (_) =>
             AdvancedPlayerScreen(video: video),
       ),
     );
   }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: videos.isNotEmpty?Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D3323), // Dark green background
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.phone_android, color: Colors.white, size: 24),
                  const SizedBox(height: 8),
                  const Text(
                    'This data is stored locally. If you uninstall the app then this data will be gone.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Recent History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: ListView.builder(
            itemCount: videos.length,
            itemBuilder: (BuildContext context, int index) {
              final video = videos[index];
              return InkWell(
                onTap: (){
                  showRewardedAndProceed(context,video);
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
                          SizedBox(width: 4,),
                          Container(
                            width: 90,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              image: DecorationImage(
                                  image: NetworkImage(
                                    video.thumbnailUrl,
                                  ),fit: BoxFit.cover
                              ),
                            ),
                          ),
                          SizedBox(width: 10,),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video!.title,
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,fontSize: 14
                                ),
                                maxLines: 1,
                              ),
                              Text(
                                video!.description,
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,fontSize: 9
                                ),
                                maxLines: 2,
                              ),
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(3)
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      child: Text("Views "+video.views.toString(),style: TextStyle(fontSize: 7),),
                                    ),
                                  ),
                                  SizedBox(width: 4,),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.indigo,
                                        borderRadius: BorderRadius.circular(3)
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      child: Text("Likes "+video.likes.toString(),style: TextStyle(fontSize: 7),),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Spacer(),
                          CircleAvatar(
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
              );
            },
          ))
        ],
      ):Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D3323), // Dark green background
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.phone_android, color: Colors.white, size: 24),
                  const SizedBox(height: 8),
                  const Text(
                    'This data is stored locally. If you uninstall the app then this data will be gone.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Recent History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Spacer(),
          Center(child: Image.asset("assets/7486744.png",width: 90,)),
          SizedBox(height: 12,),
          Center(
              child: Text(
                'No Recent History Found !',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,fontWeight: FontWeight.w900
                ),
              ),
            ),
          SizedBox(height: 5,),
             Center(
              child: Text(
                'Start Watching Contents to fill this section Up',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
