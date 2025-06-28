import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:page_transition/page_transition.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubebox/global.dart';
import 'package:tubebox/main.dart';
import 'package:tubebox/model/video_model.dart';
import 'package:tubebox/settings/video.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart' show PlatformException;
import 'package:uni_links5/uni_links.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'dart:io';


class Home extends StatefulWidget {
 Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final CarouselSliderController _controller = CarouselSliderController();
  Future<void> fetchImages() async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('video')
          .where("pin", isEqualTo: true)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Initialize empty lists to collect all `pic` and `link` values
        List<String> allPics = [];
        List<String> allLinks = [];

        // Iterate through each document in the QuerySnapshot
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Check and add `pic` if it exists
          if (data.containsKey('pic') && data['pic'] is String) {
            allPics.add(data['pic'] as String);
          }

          // Check and add `link` if it exists
          if (data.containsKey('id') && data['id'] is String) {
            allLinks.add(data['id'] as String);
          }
        }
        setState(() {
          images = allPics;
          links = allLinks;
        });
      } else {
        print('No documents found with "pin" == true.');
      }
    } catch (e) {
      print('Error fetching images: $e');
    }
  }


  List<String> images=[],links=[];

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
      adUnitId:isIOS?"ca-app-pub-2242333705148339/3985786939": Global.bannerid,
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
  VideoModel vi=VideoModel(name: "", id: "", pic: "", link: "", hd: false, sd: false, s1: "00:00", pin: false);



  bool get isIOS {
    return Platform.isIOS;
  }

  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isnight?Colors.black:bgcolor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 5,),
              _bannerAd == null
                  ? SizedBox.shrink()
                  : Padding(
                    padding: const EdgeInsets.only(bottom: 9.0),
                    child: Container(
                                  width: _bannerAd!.size.width.toDouble(),
                                  height: _bannerAd!.size.height.toDouble(),
                                  child: AdWidget(ad: _bannerAd!),
                                ),
                  ),
              Container(
                width: w,height:yes?350: 260,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0,top: 23,right: 16),
                      child: Container(
                        width: w,height:yes?300: 200,
                        decoration: BoxDecoration(
                          color: isnight?Colors.white:greens,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                                    color:isnight?Colors.black: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10,bottom: 6.0,top: 9,right: 12),
                                    child: TextFormField(
                                      controller: text,
                                      style: TextStyle(color: !isnight ? Colors.black : Colors.white), // Input text color
                                      decoration: InputDecoration(
                                          hintText:" Paste the Link here.....",hintStyle: TextStyle(color: !isnight?Colors.black:Colors.white),
                                          labelStyle: TextStyle(color: !isnight?Colors.black:Colors.white),
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
                                padding: const EdgeInsets.only(bottom: 9.0,left: 9,right: 9),
                                child: Card(
                                  color:Colors.white,
                                  child: ListTile(
                                    onTap: (){
                                      addn(vi.id);
                                      load(context, vi.link);
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
                                              color:gree,
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
                                  ),
                                ),
                              ),
                            ):SizedBox(),
                            Center(
                              child: InkWell(
                                onTap: (){
                                  if(vi.id.isNotEmpty){
                                    addn(vi.id);
                                    load(context, vi.link);
                                  }
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
                                ):CircleAvatar(
                                  backgroundColor: gree,
                                  child: Icon(Icons.arrow_forward_outlined,color: Colors.white,),
                                ) /*Container(
                                  width: w-60,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Color(0xff009788),
                                    borderRadius: BorderRadius.circular(5)
                                  ),
                                  child: Center(child: Text(yes?"Fetch Again":"Continue",style: TextStyle(color: Colors.white,fontSize: 18),)),
                                ),*/
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Column(
                        children:[ Center(
                          child: Container(
                            width: w/2+50,
                            height: 45,
                            decoration: BoxDecoration(
                                color: gree,
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: Center(child: Text("Access File via Link",style: TextStyle(color: Colors.white,fontSize: 17),)),
                          ),
                        ),
                          Spacer(),]
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15,),

              images.isNotEmpty?Container(
                width: w,height: 250,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0,right: 16,top: 23),
                      child: Container(
                        width: w,height: 200,
                        decoration: BoxDecoration(
                          color: isnight?Colors.white:greens,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width-80,
                            height: 150,
                            child: CarouselSlider(
                                controller: _controller,
                                items: images.map((imageUrl) {
                                  return InkWell(
                                    onTap: (){
                                      int y= images.indexOf(imageUrl);
                                      print(links);
                                      fetchVideoByLink("https://tubebox.in/"+links[y]);
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width-80,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        image: DecorationImage(image: NetworkImage(
                                          imageUrl,
                                        ),
                                          fit: BoxFit.cover,)
                                      ),
                                    ),
                                  );
                                }).toList(),
                                options: CarouselOptions(
                                  height: 150,
                                  aspectRatio: 16/9,
                                  viewportFraction: 1,
                                  initialPage: 0,
                                  enableInfiniteScroll: true,
                                  reverse: false,
                                  autoPlay: true,
                                  autoPlayInterval: Duration(seconds: 3),
                                  autoPlayAnimationDuration: Duration(milliseconds: 400),
                                  autoPlayCurve: Curves.fastOutSlowIn,
                                  enlargeCenterPage: true,
                                  enlargeFactor: 0.5,
                                  scrollDirection: Axis.horizontal,
                                )
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                        children:[ Center(
                          child: Container(
                            width: w/2+60,
                            height: 45,
                            decoration: BoxDecoration(
                                color: gree,
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: Center(child: Text("Trending Videos",style: TextStyle(color: Colors.white,fontSize: 17),)),
                          ),
                        ),
                          Spacer(),]
                    ),
                  ],
                ),
              ): SizedBox(),

              SizedBox(height: 15,),
              Container(
                width: w,
                height: 290,
                child: Stack(
                  children: [
                    Container(
                      width: w,
                      height: 150,
                      color: Colors.transparent,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Image.asset("assets/girl.png",width: w/2-15,height: 150,),
                          Image.asset("assets/png.png",width: w/2-15,height: 100,),
                          SizedBox(width: 15,)
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 80.0),
                      child: Container(
                        width: w,height: 230,
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0,right: 16,bottom: 12,top: 22),
                              child: Container(
                                width: w,height: 240,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child:Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(height: 15,),
                                    Container(
                                      width: w,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: w/3-40,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Icon(Icons.movie,color: Colors.pinkAccent,size: 30,),
                                                SizedBox(height: 2,),
                                                Text("Trending Videos",style: TextStyle(fontSize: 10),)
                                              ],
                                            ),
                                          ),Container( width: w/3-40,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Icon(Icons.video_collection,color: Colors.pinkAccent,size: 30,),
                                                SizedBox(height: 2,),
                                                Text("Multiple Format",style: TextStyle(fontSize: 10),)
                                              ],
                                            ),
                                          ),Container( width: w/3-40,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Icon(Icons.share,color: Colors.pinkAccent,size: 30,),
                                                SizedBox(height: 2,),
                                                Text("Shareable",style: TextStyle(fontSize: 10),)
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),SizedBox(height: 1,),
                                Container(
                                  width: w,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width:w/3-40,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(Icons.speed,color: Colors.pinkAccent,size: 30,),
                                            SizedBox(height: 2,),
                                            Text("Fast Playback",style: TextStyle(fontSize: 10),)
                                          ],
                                        ),
                                      ),Container(
                                        width:w/3-40,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(Icons.file_copy,color: Colors.pinkAccent,size: 30,),
                                            SizedBox(height: 2,),
                                            Text("Multiple Links",style: TextStyle(fontSize: 10),)
                                          ],
                                        ),
                                      ),Container(
                                        width:w/3-40,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(Icons.admin_panel_settings,color: Colors.pinkAccent,size: 30,),
                                            SizedBox(height: 2,),
                                            Text("AI Security",style: TextStyle(fontSize: 10),)
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),SizedBox(height: 1,),
                                  ],
                                ),
                              ),
                            ),
                            Column(
                              children:[ Center(
                                child: Container(
                                  width: w/2+50,
                                  height: 45,
                                  decoration: BoxDecoration(
                                      color: gree,
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Center(child: Text("App Features",style: TextStyle(color: Colors.white,fontSize: 17),)),
                                ),
                              ),
                              Spacer(),]
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          SizedBox(height: 80,),
            ],
          ),
        ),
      ),
    );
  }
  InterstitialAd? _interstitialAd;

  Future<void> load(BuildContext context,String link) async {
    nowstartprocess(context, link);

    return ;

    final SharedPreferences pref= await SharedPreferences.getInstance();
    int y= pref.getInt("time")??0;
    await pref.setInt("time",y+1);


    print(y);
    if(y%3==0||y!=0){
      loadInterstitialAd(context, link,true);
    }else{
      setState(() {
        fetching = false;
      });
      nowstartprocess(context, link);
    }

  }
  void loadInterstitialAd(BuildContext context, String link,bool v) {
    setState(() {
      fetching = true;
    });
    InterstitialAd.load(
      adUnitId: isIOS?"ca-app-pub-2242333705148339/7063392325":"ca-app-pub-2242333705148339/5805608406",
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          debugPrint("Interstitial Ad loaded successfully.");
          _interstitialAd = ad;
          _showInterstitialAd(context, link);
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint("Failed to load Interstitial Ad: ${error.message}");
          // Call the process directly if ad fails to load
          setState(() {
            fetching = false;
          });
          nowstartprocess(context, link);
        },
      ),
    );
  }

  void _showInterstitialAd(BuildContext context, String link) {
    if (_interstitialAd == null) {
      // Call the process directly if ad is not available
      setState(() {
        fetching = false;
      });
      nowstartprocess(context, link);
      debugPrint("No Interstitial Ad available to show. Skipping ad.");
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint("Interstitial Ad dismissed.");
        ad.dispose();
        setState(() {
          fetching = false;
        });
        nowstartprocess(context, link);
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint("Failed to show Interstitial Ad: ${error.message}");
        ad.dispose();
        setState(() {
          fetching = false;
        });
        nowstartprocess(context, link);
      },
    );

    _interstitialAd!.show();
  }

  void nowstartprocess(BuildContext context, String link) {
    Navigator.push(
      context,
      PageTransition(
        child: VideoPlayerScreen(link: link),
        type: PageTransitionType.rightToLeft,
        duration: Duration(milliseconds: 200),
      ),
    );
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
