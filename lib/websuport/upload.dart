import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart' show AWSFile, Amplify, StorageException, StorageItem, StoragePath, StorageUploadFileOptions, StorageUploadFileResult, StorageGetUrlOptions;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'dart:io';

import 'dart:io';
import 'dart:convert'; // for base64Encode and utf8
import 'dart:io';      // for File and File operations
import 'package:file_picker/file_picker.dart';
import 'package:tubebox/websuport/globa.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';// This includes ModelMutations
import '../models/Video.dart';
// this is auto-generated



class Upload extends StatefulWidget {
  Upload({super.key});

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  String pic="";




  Future<void> uploadVideoToS3(File file) async {
    final String fileName = file.path.split('/').last;
    final StoragePath path = StoragePath.fromString('videos/$fileName');
    final AWSFile awsFile = AWSFile.fromPath(file.path);

    try {
      final operation = Amplify.Storage.uploadFile(
        path: path,
        localFile: awsFile,
      );

      final StorageUploadFileResult<StorageItem> result = await operation.result;
      GloablWeb.mess(context, 'Uploaded: ${result}', true);
    } on StorageException catch (e) {
      print(e);
      GloablWeb.mess(context, 'Upload failed: ${e.message}', false);
    }
  }

  Future<void> pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null) {
      final File file = File(result.files.single.path!);
      uploadVideoToS3(file);
    } else {
      GloablWeb.mess(context, 'No file selected.', false);
    }
  }


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
      GloablWeb.mess(context, "Done", true);
      print('Video selected: ${videoFile.path}');
    } else {
      GloablWeb.mess(context, "No File Selected", true);
      print('No video selected');
    }
  }
  double uploadProgress = 0.0;
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
                    try {
                      setState(() {
                        on = true;
                      });

                      final picker = ImagePicker();
                      final XFile? file = await picker.pickVideo(
                          source: ImageSource.gallery);
                      if (file == null) {
                        Global.showMessage(context, "No file selected");
                        setState(() => on = false);
                        return;
                      }

                      final File imageFile = File(
                          file.path); // Convert XFile to File
                      final String fileName = 'public/${DateTime
                          .now()
                          .millisecondsSinceEpoch}_${file.name}';
                      final awsFile = AWSFile.fromPath(file.path);

                      // Upload the file
                      final uploadResult = await Amplify.Storage
                          .uploadFile(
                        localFile: awsFile,
                        path: StoragePath.fromString(fileName),
                        options: const StorageUploadFileOptions(
                          // or authenticated
                        ),
                        onProgress: (progress) {
                          final fractionCompleted =
                              progress.transferredBytes / progress.totalBytes;
                          setState(() {
                            uploadProgress = fractionCompleted;
                          });
                          print("Progress: ${(fractionCompleted * 100).toStringAsFixed(2)}%");
                        },
                      ).result;
                      print('✅ Uploaded file key: ${uploadResult.uploadedItem
                          .path}');

                      // Get the file's public URL
                      print("HHHH-------------->");
                      print(uploadResult.uploadedItem.path);
                      print(uploadResult.uploadedItem.size);
                      print(uploadResult.uploadedItem.metadata);
                      print(uploadResult.uploadedItem.eTag);


                      print(uploadResult);
                      print("✅ Uploaded file key: ${uploadResult.uploadedItem
                          .path}");
                      print("📦 File size: ${uploadResult.uploadedItem.size}");
                      print("🧾 Metadata: ${uploadResult.uploadedItem.metadata}");
                      print("🆔 ETag: ${uploadResult.uploadedItem.eTag}");
                      final downloadUrl = uploadResult.uploadedItem.path;

                      print("🌐 Download URL: $downloadUrl");
                      setState(() {
                        link.text = downloadUrl;
                        on = false;
                      });

                      Global.showMessage(context, "Upload complete ✅");
                    } catch (e) {
                      setState(() => on = false);
                      Global.showMessage(context, "Upload failed: $e");
                      print("❌ Error: $e");
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
                        child: link.text.isEmpty?Icon(Icons.upload,size: 90,):Icon(Icons.verified_rounded,color: Colors.green,size:90,),
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
                  uploadProgress > 0 && uploadProgress < 1
                      ? LinearProgressIndicator(value: uploadProgress)
                      : SizedBox.shrink(),
                  uploadProgress > 0 && uploadProgress < 1
                      ? Text("${(uploadProgress*100).toInt()} % Upload",style: TextStyle(fontSize: 18,color: Colors.green),)
                      : SizedBox.shrink(),
                  SizedBox(height: 8,),
                  pic1.isNotEmpty?Container(
                    width: 240,
                    height: 120,
                    decoration: BoxDecoration(
                        image: DecorationImage(image: NetworkImage(pic1),fit: BoxFit.cover)
                    ),
                  ):Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: ListTile(
                      onTap: () async {
                        try {
                          setState(() {
                            on = true;
                          });
                          final picker = ImagePicker();
                          final XFile? file = await picker.pickImage(source: ImageSource.gallery);
                          if (file == null) {
                            Global.showMessage(context, "No file selected");
                            setState(() => on = false);
                            return;
                          }

                          final File imageFile = File(
                              file.path); // Convert XFile to File
                          final String fileName = 'public/${DateTime
                              .now()
                              .millisecondsSinceEpoch}_${file.name}';
                          final awsFile = AWSFile.fromPath(file.path);

                          // Upload the file
                          final uploadResult = await Amplify.Storage
                              .uploadFile(
                            localFile: awsFile,
                            path: StoragePath.fromString(fileName),
                            options: const StorageUploadFileOptions(
                              // or authenticated
                            ),
                            onProgress: (progress) {
                              final fractionCompleted =
                                  progress.transferredBytes / progress.totalBytes;
                              setState(() {
                                uploadProgress = fractionCompleted;
                              });
                              print("Progress: ${(fractionCompleted * 100).toStringAsFixed(2)}%");
                            },
                          ).result;
                          print('✅ Uploaded file key: ${uploadResult.uploadedItem
                              .path}');
                          // Get the file's public URL
                          final urlResult = await Amplify.Storage.getUrl(
                            path: StoragePath.fromString(
                                uploadResult.uploadedItem.path),
                          );
                          print("HHHH-------------->");
                          print(uploadResult.uploadedItem.path);
                          print(uploadResult.uploadedItem.size);
                          print(uploadResult.uploadedItem.metadata);
                          print(uploadResult.uploadedItem.eTag);

                          print(urlResult.result);
                          print(urlResult.result.toString());
                          print(uploadResult);
                          print("✅ Uploaded file key: ${uploadResult.uploadedItem
                              .path}");
                          print("📦 File size: ${uploadResult.uploadedItem.size}");
                          print("🧾 Metadata: ${uploadResult.uploadedItem.metadata}");
                          print("🆔 ETag: ${uploadResult.uploadedItem.eTag}");
                          final downloadUrl = uploadResult.uploadedItem.path;

                          final getUrlResult1 = await urlResult.result;
                          final downloadUrl1 = getUrlResult1.url.toString();
                          print("🌐 Download URL: $downloadUrl");
                          setState(() {
                            pic1=downloadUrl1;
                            pic = downloadUrl;
                            on = false;
                            aws = true;
                          });

                          Global.showMessage(context, "Upload complete ✅");
                        } catch (e) {
                          setState(() => on = false);
                          Global.showMessage(context, "Upload failed: $e");
                          print("❌ Error: $e");
                        }
                      },
                      leading: Icon(Icons.add),
                      title: Text("Add Picture"),
                      subtitle: Text("Select to Upload Pic"),
                      trailing: Icon(Icons.photo),
                    ),
                  ),
                  Text("   Name of Movies",style: TextStyle(fontSize: 19),),
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
                            width: w/2-150,
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
                        on = true;
                      });
                      try {
                        print("1");
                        String id=DateTime.now().microsecondsSinceEpoch.toString();
                        VideoModel video=VideoModel(
                          aws:true,
                            name: name.text, id: id, pic: pic, link: link.text, hd: hd, sd: sd, s1: "", pin:false
                        );
                        print("2");
                        await FirebaseFirestore.instance.collection("video").doc(id).set(video.toJson());
                        print("4");
                        setState(() {
                          done=true;
                          mine="${id}";
                        });
                        print("3");
                      } on FirebaseException catch (e) {
                        print('❌ Firebase error [${e.code}]: ${e.message}');
                        Global.showMessage(context, "Firebase error: ${e.message}");
                      } catch (e) {
                        print('❌ General error: $e');
                        Global.showMessage(context, "Unexpected error occurred.");
                      }finally {
                        setState(() {
                          on = false;
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

  String pic1="";
  bool aws = false;
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


