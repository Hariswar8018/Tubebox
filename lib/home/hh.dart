import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubebox/admin/all.dart';
import 'package:tubebox/settings/add_video.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tubebox/global.dart';
import 'package:tubebox/settings/video.dart';
import '../model/video_model.dart';


class J extends StatefulWidget {
  const J({super.key});

  @override
  State<J> createState() => _JState();
}

class _JState extends State<J> {

   List<String> s1=[];

  void initState(){
    hg();
  }
  void hg()async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
     List<String> items = prefs.getStringList('video') ??[];
     print(items);
     print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
    setState(() {
      s1=items;
      print(s1);
    });
  }

  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    double h=MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xffFDE7EA),
      appBar: AppBar(
        backgroundColor: Color(0xffFDE7EA),
        title: Text(" History",style: TextStyle(fontWeight: FontWeight.w800),),
        automaticallyImplyLeading: false,
      ),
      body: s1.isNotEmpty
          ? StreamBuilder(
        stream:FirebaseFirestore.instance
            .collection("video")
            .where("id", whereIn: s1)
            .snapshots(), // If s1 is empty, don't run the query,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.active:
            case ConnectionState.done:
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Container(
                height: h,width: w,
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                Image.asset("assets/7486744.png",width: w/2,),
                Center(
                child: Text("No Videos Exists",style: TextStyle(fontWeight: FontWeight.w800,fontSize: 19),),
                ),
                Center(
                child: Text("Looks like you haven't Watched Any Video"),
                ),
                ],
                ),
                );
              }
              List<VideoModel> stories = snapshot.data!.docs
                  .map((doc) => VideoModel.fromJson(doc.data() as Map<String, dynamic>))
                  .toList();
              return ListView.builder(
                scrollDirection: Axis.vertical, // Enable horizontal scrolling
                itemCount: stories.length,
                itemBuilder: (context, index) {
                  VideoModel vi = stories[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0), // Adds spacing
                    child: ListTile(
                      onTap: (){
                        loadRewardedAd(context, vi.link);
                      },
                      leading: Container(
                        width: 90,
                        height: 60,
                        decoration: BoxDecoration(
                            image: DecorationImage(image: NetworkImage(vi.pic),fit: BoxFit.cover)
                        ),
                      ),
                      title: Text(vi.name,style: TextStyle(fontWeight: FontWeight.w800,height: 1.1),maxLines: 2),
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
                  );
                },
              );
          }
        },
      ):Container(
        height: h,width: w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/7486744.png",width: w/2,),
            Center(
              child: Text("No Videos",style: TextStyle(fontWeight: FontWeight.w800,fontSize: 19),),
            ),
            Center(
              child: Text("Looks like you haven't Watched Any Video"),
            ),
          ],
        ),
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

}
