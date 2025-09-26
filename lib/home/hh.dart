import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubebox/admin/all.dart';
import 'package:tubebox/main.dart';
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
      backgroundColor: isnight?Colors.black:bgcolor,
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
                  return EachCard(vi: vi, admin: false);
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

   int _retryCount = 0;
   final int _maxRetries = 4;


}
