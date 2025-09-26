
import 'package:amplify_flutter/amplify_flutter.dart' hide QuerySnapshot;
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubebox/global.dart';

import '../model/video_model.dart';
import '../models/Video.dart';
import '../settings/video.dart';

class All_Videos extends StatelessWidget {
  const All_Videos({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Videos", style: TextStyle(color: Colors.black)),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection("video").get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("No videos found"));
          }

          final videoDocs = snapshot.data!.docs;

          if (videoDocs.isEmpty) {
            return const Center(child: Text("No videos found"));
          }

          final List<VideoModel> videos = videoDocs.map((doc) {
            return VideoModel.fromJson(doc.data() as Map<String, dynamic>);
          }).toList();

          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final vi = videos[index];
              return EachCard(vi: vi,admin:true,);
            },
          );
        },
      ),
    );
  }
}

class EachCard extends StatefulWidget {
  bool admin;
   EachCard({super.key,required this.vi,required this.admin});

  VideoModel vi;

  @override
  State<EachCard> createState() => _EachCardState();
}

class _EachCardState extends State<EachCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shadowColor: Colors.black26,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Image.network(
          picresult,
          width: 120,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
        ),
        title: Text(widget.vi.name,style: TextStyle(fontWeight: FontWeight.w800),),
        subtitle: Container(
          width: 120,
          height: 40,
          child: Row(
            children: [
              widget.vi.hd ? const Icon(Icons.hd, color: Colors.green) : SizedBox(),
              widget.vi.sd ? const Icon(Icons.sd, color: Colors.red) : SizedBox(),
              widget.vi.s1.isNotEmpty ? Text(widget.vi.s1) : SizedBox(),
            ],
          ),
        ),
        trailing: InkWell(
            onTap: (){

            },
            child: Icon(Icons.delete,color: Colors.red,size: 20,)),
        onTap: () {
          if(widget.admin){
            Clipboard.setData(ClipboardData(text: "https://tubebox.in/${widget.vi.id}"));
            Global.showMessage(context, "Copied to Clipboard");
          }else{
            watch(widget.vi.link);
          }
        },
        onLongPress: (){
          if(widget.admin){
            watch(widget.vi.link);
          }else{

          }
        },
      ),
    );
  }

  void watch(String link) async {
    try {
      final urlResult = await Amplify.Storage.getUrl(
        path: StoragePath.fromString(link),
        options: const StorageGetUrlOptions(
          pluginOptions: S3GetUrlPluginOptions(
            expiresIn: Duration(days: 1),
            validateObjectExistence: true,
            useAccelerateEndpoint: false,
          ),
        ),
      );

      final getUrlResult = await urlResult.result;
      final downloadUrl = getUrlResult.url.toString();
      nowstartprocess(context, downloadUrl);
    }catch(e){
      Global.showMessage(context, e.toString());
    }
  }

  void initState(){
    picresulttoo(widget.vi.pic);
    loadas();
  }
  String picresult="https://media.gettyimages.com/id/2172513824/video/error-404-page-in-glitch-style-page-not-found-concept-system-error-illustration-geometric.jpg?s=640x640&k=20&c=G3mUndBTQzJyiUpFPkQKXQ5eKcdkOg4oG2YWPxVj-XE=";

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
      setState(() {
        picresult=downloadUrl;
      });
    }catch(e){

    }
  }
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

  Future<void> nowstartprocess(BuildContext context, String link) async {
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
            loadas();
            _navigateToVideo(context, link);
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            _interstitialAd = null;
            _navigateToVideo(context, link);
          },
        );

        _interstitialAd!.show();
      } else {
        _navigateToVideo(context, link);
      }
    } else if (counter % 3 == 0) {
      // divisible by 3 → don't show ad
      print("Counter divisible by 3 → no ad");
      _navigateToVideo(context, link);
    } else {
      // otherwise → direct navigation
      _navigateToVideo(context, link);
    }
  }

  void _navigateToVideo(BuildContext context, String link) {
    Navigator.push(
      context,
      PageTransition(
        child: VideoPlayerScreen(link: link),
        type: PageTransitionType.rightToLeft,
        duration: const Duration(milliseconds: 200),
      ),
    );
  }


}
