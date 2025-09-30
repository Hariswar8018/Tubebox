

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as ds;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Home extends StatefulWidget {
 Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final CarouselSliderController _controller = CarouselSliderController();
  Future<void> fetchImages() async {
    try {
      final ds.QuerySnapshot querySnapshot = await ds.FirebaseFirestore.instance
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
    loadas();
    initUniLinks();
  }

  void _loadAd() {
    final bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: "ca-app-pub-2242333705148339/2839435264",
      request: const AdRequest(),
      listener: BannerAdListener(
        // Called when an ad is successfully received.
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
      ),
    );

    // Start loading.
    bannerAd.load();
  }
  BannerAd? _bannerAd;
  @override
  void dispose() {
    videolink = "";      // Resetting state
    fetching = false;    // Resetting state
    text.dispose();      // Disposing controller
    super.dispose();
  }


  StreamSubscription<String>? _linkSubscription;

  Future<void> initUniLinks() async {
    try {
      final appLinks = AppLinks();

      // Handle initial link (when app launches for the first time)
      String? initialLink = await appLinks.getInitialLinkString();
      if (initialLink != null) {
        fetchVideoByLink(initialLink);
      }


      _linkSubscription = appLinks.stringLinkStream.listen((String link) async {
        String prefix = "https://tubebox.in/";
        String videoId = link.substring(prefix.length);

        // Ensure the ID is valid
        if (videoId.isEmpty) {
          print("Error: No video ID found in the link.");
          setState(() {
            fetching=false;
          });
          return null;
        }
        ds.DocumentSnapshot doc = await ds.FirebaseFirestore.instance
            .collection("video")
            .doc(videoId)
            .get();
        if (doc.exists) {
          vi= VideoModel.fromJson(doc.data() as Map<String, dynamic>);
          Navigator.push(
            context,
            PageTransition(
              child: VideoPlayerScreen( video: vi,),
              type: PageTransitionType.rightToLeft,
              duration: const Duration(milliseconds: 200),
            ),
          );
        }else{

        }
      }, onError: (err) {
        print("Error receiving link: $err");
      });
    } catch (e) {
      print("Error initializing links: $e");
    }
  }



  String videolink="";
 bool fetching=false;

 String picresult="";

 void clear(){
   picresult="";
   fetching=false;
   videolink="";
   text.text="";
   yes=false;
 }

 Future<void> picresulttoo(String piclink) async {
   try {
     final urlResult1 = await Amplify.Storage.getUrl(
       path: StoragePath.fromString(piclink),
       options: const StorageGetUrlOptions(
         pluginOptions: S3GetUrlPluginOptions(
           expiresIn: Duration(days: 1),
           validateObjectExistence: true,
           useAccelerateEndpoint: false,
         ),
       ),
     );

     final getUrlResult = await urlResult1.result;
     final downloadUrl = getUrlResult.url.toString();

     print("🔗 Link Key: ${vi.link}");
     print("📥 Download URL: $downloadUrl");
     setState(() {
       picresult=downloadUrl;
     });
   }catch(e){

   }
 }
  void fetchVideoById(String videoId) async {
    try {
      ds.DocumentSnapshot doc = await ds.FirebaseFirestore.instance
          .collection("video")
          .doc(videoId)
          .get();
      if (doc.exists) {
        vi= VideoModel.fromJson(doc.data() as Map<String, dynamic>);
        if(vi.link.isNotEmpty){
          if(vi.aws){
            print(vi.link);
            print(vi.toJson());
            try {
              picresulttoo(vi.pic);
              setState(() {
                yes = true;
                fetching = false;
              });
            }catch(e){
              setState(() {
                fetching=false;
                yes=false;
              });
              Global.showMessage(context, "$e");
            }
          }else{
            setState(() {
              yes=true;
              fetching=false;
              videolink=vi.link;
            });

          }

        }
      } else {
        setState(() {
          fetching=false;
        });
        Global.showMessage(context, "No video found in $videoId.");

        print("No video found with ID: $videoId");
        return null;
      }
    } catch (e) {
      setState(() {
        fetching=false;
      });
      Global.showMessage(context, "Error: fetching video  $e");
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

  bool yes=false;
  VideoModel vi=VideoModel(name: "", id: "", pic: "", link: "", hd: false, sd: false, s1: "00:00", pin: false, aws: false, views: 100);

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
                                          hintText:" Paste the Link here.....",
                                          hintStyle: TextStyle(color: !isnight?Colors.black:Colors.white),
                                          labelStyle: TextStyle(color: !isnight?Colors.black:Colors.white),
                                          prefixIcon: text.text.isEmpty?Icon(Icons.search,color: Colors.blue,):InkWell(
                                              onTap: (){
                                                setState(() {
                                                  text.text="";
                                                  text.clear();
                                                });
                                              },
                                              child: Icon(Icons.close,color: Colors.red,)),
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
                                padding: const EdgeInsets.only(bottom: 14.0,left: 14,right: 14),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:Colors.white,
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1), // Shadow color
                                        spreadRadius: 2, // How wide the shadow spreads
                                        blurRadius: 5,   // How blurry the shadow is
                                        offset: Offset(0, 3), // X and Y offset
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    onTap: (){
                                      addn(vi.id);
                                      load(context, vi.link);
                                    },
                                    leading: Container(
                                      width: 90,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(image: NetworkImage(picresult.isNotEmpty?picresult:vi.pic),fit: BoxFit.cover)
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
                            vi.id.isNotEmpty?Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                fetching?SizedBox():InkWell(
                                    onTap: (){
                                      fetchVideoByLink(text.text);
                                    },
                                    child:Container(
                                      width: w/2-40,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          color: Color(0xff009788),
                                          borderRadius: BorderRadius.circular(5)
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.refresh,color: Colors.white,),
                                          Text(" Fetch Again",style: TextStyle(color: Colors.white,fontSize: 16),),
                                        ],
                                      ),
                                    ),
                                ),
                                SizedBox(width: 10,),
                                InkWell(
                                    onTap: (){
                                      if(vi.id.isNotEmpty){
                                        addn(vi.id);
                                        load(context, videolink);
                                        return ;
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
                                    ):Container(
                                      width: w/2-40,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          color: Color(0xff009788),
                                          borderRadius: BorderRadius.circular(5)
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.play_circle,color: Colors.white,),
                                          Text(" Play Video",style: TextStyle(color: Colors.white,fontSize: 16),),
                                        ],
                                      ),
                                    ),
                                ),

                              ],
                            ):Center(
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
                                )
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
              SizedBox(height: 1,),
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
              SizedBox(
                width: w,
                height: 50,
                child: _bannerAd == null
                // Nothing to render yet.
                    ? const SizedBox()
                // The actual ad.
                    : AdWidget(ad: _bannerAd!),
              ),
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


  Future<void> load(BuildContext context,String link) async {
    nowstartprocess(context, );
    return ;
  }

  void loadInterstitialAd(BuildContext context, String link,bool v) {
    setState(() {
      fetching = true;
    });

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

  InterstitialAd? _interstitialAd;

  Future<void> _incrementCounter() async {
    final prefs = await SharedPreferences.getInstance();
    int counter = prefs.getInt('ad_counter') ?? 0;
    counter++;
    await prefs.setInt('ad_counter', counter);
  }

  Future<int> _getCounter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('ad_counter') ?? 0;
  }

  void loadas() {
    InterstitialAd.load(
      adUnitId: "ca-app-pub-2242333705148339/5805608406", // replace with yours
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  Future<void> nowstartprocess(BuildContext context) async {
    // increment counter
    await _incrementCounter();

    // get current value
    int counter = await _getCounter();
    print("Counter value: $counter");

    if (counter % 2 == 0) {
      // divisible by 2 → show ad
      if (_interstitialAd != null) {
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _interstitialAd = null;
            _loadAd(); // preload for next

            _navigateToVideo(context);
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            _interstitialAd = null;
            _navigateToVideo(context);
          },
        );

        _interstitialAd!.show();
      } else {
        _navigateToVideo(context);
      }
    } else if (counter % 3 == 0) {
      // divisible by 3 → don't show ad
      print("Counter divisible by 3 → no ad");
      _navigateToVideo(context, );
    } else {
      // otherwise → direct navigation
      _navigateToVideo(context,);
    }
  }

  void _navigateToVideo(BuildContext context) {
    Navigator.push(
      context,
      PageTransition(
        child: VideoPlayerScreen( video: vi,),
        type: PageTransitionType.rightToLeft,
        duration: const Duration(milliseconds: 200),
      ),
    );
  }

}


class Home1 extends StatelessWidget {
  const Home1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("Test Videos", style: TextStyle(color: Colors.black)),
      ),
      body: Home(),
    );
  }
}
