import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubebox/global.dart';
import 'package:tubebox/model/video_model.dart';
import 'package:tubebox/settings/video.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart' show PlatformException;
import 'package:uni_links5/uni_links.dart';
class Home extends StatefulWidget {
 Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  void initState(){
    initUniLinks();
    _loadAd();
  }
 Future<void> initUniLinks() async {
   try {
     final initialLink = await getInitialLink();
     print(initialLink);
     print("XXXXXXXXXXXXX");
     fetchVideoByLink(initialLink!);
     print("XXXXXXXXXXXXX");
   } catch(e) {

     print(e);
   }
 }
 bool fetching=false;
  void fetchVideoById(String videoId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("video")
          .doc(videoId)
          .get();

      if (doc.exists) {
        vi= VideoModel.fromJson(doc.data() as Map<String, dynamic>);
        if(vi.link.isNotEmpty){
          setState(() {
            yes=true;
            fetching=false;
          });
        }
      } else {
        setState(() {
          fetching=false;
        });
        print("No video found with ID: $videoId");
        return null;
      }
    } catch (e) {
      setState(() {
        fetching=false;
      });
      print("Error fetching video: $e");
      return null;
    }
  }
  void fetchVideoByLink(String link) async {
    setState(() {
      fetching=true;
    });
    if (link.isEmpty) {
      print("Error: The link cannot be empty.");
      Global.showMessage(context, "Error: The link cannot be empty.");
      setState(() {
        fetching=false;
      });
      return null;
    }

    // Check if the link starts with the correct prefix
    String prefix = "https://tubebox.in/";
    if (!link.startsWith(prefix)) {
      setState(() {
        fetching=false;
      });
      print("Error: Invalid link! The link must start with '$prefix'.");
      Global.showMessage(context, "Error: Invalid link! The link must start with '$prefix'.");
      return null;
    }

    // Extract the ID from the URL
    String videoId = link.substring(prefix.length);

    // Ensure the ID is valid
    if (videoId.isEmpty) {
      print("Error: No video ID found in the link.");
      setState(() {
        fetching=false;
      });
      Global.showMessage(context, "Error: No video ID found in the link.");
      return null;
    }
    fetchVideoById(videoId);

  }
  void _loadAd() {
    final bannerAd = BannerAd(
      adUnitId: Global.bannerid,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ), size: AdSize.banner,
    );
    bannerAd.load();
  }
  BannerAd? _bannerAd;
  bool yes=false;
  VideoModel vi=VideoModel(name: "", id: "", pic: "", link: "", hd: false, sd: false, s1: "00:00");
  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xffFDE7EA),
      appBar: AppBar(
        backgroundColor: Color(0xffFDE7EA),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Image.asset("assets/WhatsApp Image 2025-02-24 at 09.41.55_864c159b.jpg",width: w-100,),
          Text("For Endless Entertainment with AI Powered Links",style: TextStyle(fontSize: 6),),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: w,height:yes?300: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '     Paste your '),
                        TextSpan(
                          text: 'TubeBox Link',
                          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red),
                        ),
                        TextSpan(text: ' to view'),
                      ],
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 14.0,right: 14,bottom: 15,top: 10),
                      child: Container(
                        width: w-15,height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10,bottom: 6.0,top: 9,right: 12),
                          child: TextFormField(
                            controller: text,
                            decoration: InputDecoration(
                                hintText:" Paste the Link here.....",
                                prefixIcon: Icon(Icons.search,color: Colors.blue,),
                                border: InputBorder.none
                            ),
                            onFieldSubmitted: (String s){

                            },
                            onSaved: ( str){

                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  yes?Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 9.0),
                      child: ListTile(
                        onTap: (){
                          addn(vi.id);
                          loadRewardedAd(context, vi.link);
                        },
                        leading: Container(
                          width: 90,
                          height: 60,
                          decoration: BoxDecoration(
                            image: DecorationImage(image: NetworkImage(vi.pic),fit: BoxFit.cover)
                          ),
                        ),
                        title: Text(vi.name,style: TextStyle(fontWeight: FontWeight.w800),maxLines: 2,),
                        subtitle: Row(
                          children: [
                            vi.sd?Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                  color: Color(0xff009788),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8,right: 8,top: 3.0,bottom: 3),
                                    child: Text("SD",style: TextStyle(color: Colors.white,fontSize: 12),),
                                  )),
                            ):SizedBox(),
                            vi.hd?Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                  color: Color(0xff009788),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8,right: 8,top: 3.0,bottom: 3),
                                    child: Text("HD",style: TextStyle(color: Colors.white,fontSize: 12),),
                                  )),
                            ):SizedBox(),
                            Text(vi.s1,style: TextStyle(fontWeight: FontWeight.w500,color: Colors.grey),),
                          ],
                        ),
                        trailing: Container(
                          width: 90,
                          height: 45,
                          decoration: BoxDecoration(
                              color: Color(0xff009788),
                              borderRadius: BorderRadius.circular(5)
                          ),
                          child: Center(child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow,color: Colors.white,size: 20,),
                              Text("Watch",style: TextStyle(color: Colors.white,fontSize: 13),),
                            ],
                          )),
                        ),
                      ),
                    ),
                  ):SizedBox(),
                  Center(
                    child: InkWell(
                      onTap: (){
                        if(text.text.isEmpty){
                          return ;
                        }
                        setState(() {
                          fetching=true;
                        });
                        fetchVideoByLink(text.text);
                      },
                      child:fetching?CircularProgressIndicator(
                        backgroundColor: Color(0xff009788),
                      ): Container(
                        width: w-60,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xff009788),
                          borderRadius: BorderRadius.circular(5)
                        ),
                        child: Center(child: Text(yes?"Fetch Again":"Continue",style: TextStyle(color: Colors.white,fontSize: 18),)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          _bannerAd == null
              ? SizedBox.shrink()
              : Container(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          )
        ],
      ),
    );
  }
  RewardedAd? _rewardedAd;
  int _retryCount = 0;
  final int _maxRetries = 4;
  void loadRewardedAd(BuildContext context,String link) {
    if (_retryCount >= _maxRetries) {
      debugPrint("Max retries reached. Could not load ad.");
      return;
    }

    RewardedAd.load(
      adUnitId: Global.rewarded,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint("Rewarded Ad loaded successfully.");
          _rewardedAd = ad;
          _retryCount = 0; // Reset retry count on success
          _showRewardedAd(context,link);
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint("Failed to load Rewarded Ad: ${error.message}");
          _retryCount++;
          loadRewardedAd(context,link); // Retry loading
        },
      ),
    );
  }
  void _showRewardedAd(BuildContext context,String link) {
    if (_rewardedAd == null) {
      debugPrint("No ad available to show.");
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint("Rewarded Ad dismissed.");
        ad.dispose();
        nowstartprocess(context,link); // Call function after watching
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint("Failed to show Rewarded Ad: ${error.message}");
        ad.dispose();
        loadRewardedAd(context,link); // Retry loading on failure
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      debugPrint("User earned reward: ${reward.amount} ${reward.type}");
    });
  }
  void nowstartprocess(BuildContext context,String link) {
    Navigator.push(
      context, PageTransition(
      child: VideoPlayerScreen(link: link,), type: PageTransitionType.rightToLeft, duration: Duration(milliseconds: 200)
    ));
  }

  Future<void> addn(String str) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> items = prefs.getStringList('video') ?? [];
      items = items + [str];
      prefs.setStringList('video', items);
    }catch(e){
      print(e);
    }
  }
  TextEditingController text=TextEditingController();
}
