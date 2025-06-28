import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubebox/global.dart';
import 'package:tubebox/main.dart';
import 'package:tubebox/model/video_model.dart';
import 'package:tubebox/provider/storage.dart';
import 'package:tubebox/settings/video.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart' show PlatformException;
import 'package:uni_links5/uni_links.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'dart:io';


class Upload extends StatefulWidget {
  Upload({super.key});

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  String pic="";

  pickImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();
    XFile? _file = await _imagePicker.pickImage(source: source);
    if (_file != null) {
      return await _file.readAsBytes();
    }
    print('No Image Selected');
  }
  final ImagePicker _picker = ImagePicker();
  bool on=false;
  Future<void> pickVideo() async {
    final XFile? videoFile = await _picker.pickVideo(
      source: ImageSource.gallery, // or ImageSource.camera
    );
    if (videoFile != null) {
      print('Video selected: ${videoFile.path}');
    } else {
      print('No video selected');
    }
  }
  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    double h=MediaQuery.of(context).size.height;
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(

        ),
      child: SafeArea(child: Row(
        children: [
          Container(
            width: w/2-40,height: h,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey , width: 4)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children:[
                InkWell(
                  onTap: () async {
                    final XFile? videoFile = await _picker.pickVideo(
                      source: ImageSource.gallery, // or ImageSource.camera
                    );
                    if (videoFile != null) {
                      print('Video selected: ${videoFile.path}');
                    } else {
                      print('No video selected');
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black,
                            width: 4
                          )
                        ),
                        height: 200,width: 200,
                        child: Icon(Icons.upload,size: 90,),
                      ),
                      SizedBox(height: 10,),
                      Text("Upload Video from PC",style: TextStyle(fontSize: 21,fontWeight: FontWeight.w800),)
                    ],
                  ),
                ),
              ]
            ),
          ),
          Container(
            width: w/2-40,height: h,
            decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade100 , width: 4)
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  pic.isNotEmpty?Container(
                    width: 240,
                    height: 120,
                    decoration: BoxDecoration(
                        image: DecorationImage(image: NetworkImage(pic),fit: BoxFit.cover)
                    ),
                  ):Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: ListTile(
                      onTap: () async {
                        try {
                          setState(() {
                            on=true;
                          });
                          Uint8List? _file = await pickImage(
                              ImageSource.gallery);
                          Global.showMessage(context, "Uploading...............");
                          String photoUrl = "done";
                          setState(() {
                            pic=photoUrl;
                            on=false;
                          });
                          Global.showMessage(context, "Uploaded");
                        }catch(e){
                          setState(() {
                            on=false;
                          });
                          Global.showMessage(context, "$e");
                        }
                      },
                      leading: Icon(Icons.add),
                      title: Text("Add Picture"),
                      subtitle: Text("Select to Upload Pic"),
                      trailing: Icon(Icons.photo),
                    ),
                  ),
                  Text("   Name of Movie",style: TextStyle(fontSize: 19),),
                  as(w, name, "Name of Movie"),
                  Text("   Link of Movie",style: TextStyle(fontSize: 19),),
                  as(w,link, "Link of Movie"),
                  Row(
                    children: [
                      Text("   Length of Movie ",style: TextStyle(fontSize: 19),),
                      Container(
                          width: 130,
                          child: as(w,s1, "Length in ( HH:MM:SS )")),
                      Text("   HD",style: TextStyle(fontSize: 19),),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Switch(
                          value: hd,
                          onChanged: (toggleSwitch){
                            setState(() {
                              hd=toggleSwitch;
                            });
                          },
                          activeColor: Colors.green,
                          inactiveThumbColor: Colors.grey,
                        ),
                      ),
                      Text("   SD",style: TextStyle(fontSize: 19),),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Switch(
                          value: sd,
                          onChanged: (toggleSwitch){
                            setState(() {
                              sd=toggleSwitch;
                            });
                          },
                          activeColor: Colors.green,
                          inactiveThumbColor: Colors.grey,
                        ),
                      ),
                    ],
                  ),


                  Spacer(),
                  done&&mine.isNotEmpty?InkWell(
                    onTap: (){
                      Clipboard.setData(ClipboardData(text: "https://tubebox.in/$mine"));
                      Global.showMessage(context, "Copied to Clipboard");
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Center(
                          child: Container(
                            width: w-90,
                            height: 50,
                            decoration: BoxDecoration(
                                color: Color(0xff009788),
                                borderRadius: BorderRadius.circular(5)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0,right: 8),
                              child: Center(child: Text(maxLines: 1,"https://tubebox.in/$mine",style: TextStyle(color: Colors.white,fontSize: 12),)),
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            width: 60,
                            height: 50,
                            decoration: BoxDecoration(
                                color: Color(0xff009788),
                                borderRadius: BorderRadius.circular(5)
                            ),
                            child: Center(child: Text("COPY",style: TextStyle(color: Colors.white,fontSize: 14),)),
                          ),
                        ),
                      ],
                    ),
                  ):(on?Center(child: CircularProgressIndicator()):InkWell(
                    onTap: () async {
                      setState(() {
                        on=true;
                      });
                      try{
                        String id=DateTime.now().microsecondsSinceEpoch.toString();
                        VideoModel vi=VideoModel(name: name.text, id: id, pic: pic, link: link.text, hd: hd, sd: sd, s1: s1.text, pin: false);
                        await FirebaseFirestore.instance.collection("video").doc(id).set(vi.toJson());
                        setState(() {
                          on=false;
                          done=true;
                          mine=id;
                        });
                      }catch(e){
                        Global.showMessage(context, "$e");
                        setState(() {
                          on=false;
                        });
                      }
                    },
                    child: Center(
                      child: Container(
                        width: w-60,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Color(0xff009788),
                            borderRadius: BorderRadius.circular(5)
                        ),
                        child: Center(child: Text("Add Now",style: TextStyle(color: Colors.white,fontSize: 18),)),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
    ),
    ));
  }
  String mine="";bool done=false;
  bool hd=false,sd=false;
  TextEditingController link=TextEditingController();

  TextEditingController name=TextEditingController();

  TextEditingController s1=TextEditingController();

  Widget as(double w,TextEditingController text,String te){
    return Padding(
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
            readOnly: done,
            decoration: InputDecoration(
                hintText:te,
                border: InputBorder.none
            ),
            onFieldSubmitted: (String s){

            },
            onSaved: ( str){

            },
          ),
        ),
      ),
    );
  }
}
