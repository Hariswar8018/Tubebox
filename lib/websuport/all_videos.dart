import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
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
import 'package:amplify_flutter/amplify_flutter.dart' hide QuerySnapshot;
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tubebox/global.dart';

import '../model/video_model.dart';
import '../models/Video.dart';
import '../settings/video.dart';

class All_Vids extends StatelessWidget {
  const All_Vids({super.key});

  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    double h=MediaQuery.of(context).size.height;
    return Scaffold(
      body:StreamBuilder(
        stream:FirebaseFirestore.instance
            .collection("video").orderBy("id",descending: true)
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
      )
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
        trailing : Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0,vertical: 6),
              child: Text("https://tubebox.in/${widget.vi.id}"),
            )),
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
        onTap: () {
            Clipboard.setData(ClipboardData(text: "https://tubebox.in/${widget.vi.id}"));
            Global.showMessage(context, "Copied to Clipboard");
        },
      ),
    );
  }


  Future<void> list() async {
    try {
      final listOp = await Amplify.Storage.list(
        path: StoragePath.fromString("public/"),
      );

      print("Available S3 files:-------------------------------------->");

      // ✅ Await here or nothing happens
      final listResult = await listOp.result;

      for (final item in listResult.items) {
        print("path: ${item.path}");
      }
    } catch (listError) {
      print("Error listing files: $listError");
    }
  }

    @override
  void initState() {
    super.initState();
    if(widget.vi.pic.isEmpty){
      return ;
    }
    picresulttoo(widget.vi.pic);
    }

  Future<void> ps(String piclink) async {
    if (piclink.trim().isEmpty) return;

    try {
      print("Fetching S3 signed URL for: $piclink");

      // Ensure it has the correct 'public/' prefix
      String fixedPath = piclink.trim();
      if (!fixedPath.startsWith("public/")) {
        fixedPath = "public/$fixedPath";
      }
      print(fixedPath);
      

      // Try fetching the signed URL
      final urlResult = await Amplify.Storage.getUrl(
        path: StoragePath.fromString(fixedPath),
        options: const StorageGetUrlOptions(
          pluginOptions: S3GetUrlPluginOptions(
            expiresIn: Duration(days: 1),
            validateObjectExistence: true,
            useAccelerateEndpoint: false,
          ),
        ),
      );
      print(urlResult);


      // On Web, we MUST await `.result` again
      final getUrlResult = await urlResult.result;
      final signedUrl = getUrlResult.url.toString();

      print("Signed URL: $signedUrl");

      setState(() {
        picresult = signedUrl;
      });
    } catch (e) {
      print("Error fetching S3 URL: $e");

      // Try listing all items to help debug missing paths
      try {
        final listOp = await Amplify.Storage.list(
          path: StoragePath.fromString("public/"),
        );

        print("Available S3 files:-------------------------------------->");

        // Await the actual result
        final listResult = await listOp.result;

        // Loop through items
        for (final item in listResult.items) {
          print("Path: ${item.path}");
          print("ETag: ${item.eTag}");
          print("Last Modified: ${item.lastModified}");
          print("Size (bytes): ${item.size}");
          print("---------------------------");
        }
      } catch (listError) {
        print("Error listing files: $listError");
      }

    }
  }



  String picresult="https://media.gettyimages.com/id/2172513824/video/error-404-page-in-glitch-style-page-not-found-concept-system-error-illustration-geometric.jpg?s=640x640&k=20&c=G3mUndBTQzJyiUpFPkQKXQ5eKcdkOg4oG2YWPxVj-XE=";
  Future<void> picresulttoo(String piclink) async {
    try {
      final urlResult1 = await Amplify.Storage.getUrl(
        path: StoragePath.fromString(piclink),
        options: const StorageGetUrlOptions(
          pluginOptions: S3GetUrlPluginOptions(
            expiresIn: Duration(days: 1),
            validateObjectExistence: false,
            useAccelerateEndpoint: false,
          ),
        ),
      );

      final getUrlResult = await urlResult1.result;
      final downloadUrl = getUrlResult.url.toString();
      setState(() {
        picresult=downloadUrl;
      });
      print("Pic link      : " + downloadUrl);
    }catch(e){
      print("NOTWOPRKING----------------------------->");
      print("Error fetching S3 URL: $e");
    }
  }
  Future<void> picresulttoos(String piclink) async {
    if (piclink.trim().isEmpty) return;

    try {
      print("1----------------------------->");

      final urlResult1 = await Amplify.Storage.getUrl(
        path: StoragePath.fromString(piclink),
        options: const StorageGetUrlOptions(
          pluginOptions: S3GetUrlPluginOptions(
            expiresIn: Duration(days: 1),
            validateObjectExistence: false,
            useAccelerateEndpoint: false,
          ),
        ),
      );
      print("2----------------------------->");
      print(urlResult1.result.toString());
      print(urlResult1.operationId);
      final getUrlResult = await urlResult1.result;
      final downloadUrl = getUrlResult.url.toString();
      print(downloadUrl);
      setState(() {
        picresult = downloadUrl;
      });
    } catch (e) {
      print("----------------------------->");
      print("Error fetching S3 URL: $e");
    }
  }
}
