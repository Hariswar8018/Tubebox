import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tubebox/global.dart';
import 'package:tubebox/model/video_model.dart';
import 'package:tubebox/provider/storage.dart';
import 'dart:typed_data';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'dart:typed_data';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:uuid/uuid.dart';
import '../models/Video.dart' show Video;
import '../websuport/globa.dart';
import 'dart:io' show File;

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:aws_common/vm.dart';


class AddVideo extends StatefulWidget {
  AddVideo({super.key});

  @override
  State<AddVideo> createState() => _AddVideoState();
}

class _AddVideoState extends State<AddVideo> {
  String pic = "";


  pickImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();
    XFile? _file = await _imagePicker.pickImage(source: source);
    if (_file != null) {
      return await _file.readAsBytes();
    }
    print('No Image Selected');
  }


  bool on = false;
  double uploadProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Video"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            uploadProgress > 0 && uploadProgress < 1
                ? LinearProgressIndicator(value: uploadProgress)
                : SizedBox.shrink(),
            pic1.isNotEmpty ? Container(
              width: 240,
              height: 120,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(pic1), fit: BoxFit.cover)
              ),
            ) : Padding(
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
            Text("   Name of Movie", style: TextStyle(fontSize: 19),),
            as(w, name, "Name of Movie"),
            Text("   Link of Movie", style: TextStyle(fontSize: 19),),
            as(w, link, "Link of Movie"),
            Padding(
              padding: const EdgeInsets.only(left: 13.0),
              child: InkWell(
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
                child: Container(
                  width:160,
                  height:45,
                  decoration: BoxDecoration(
                    color: Colors.red,borderRadius: BorderRadius.circular(5)
                  ),
                  child:Center(child: Text("Upload Instead",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700),)),
                ),
              ),
            ),
            Text("     * Could be Lengthy if Space is more",
              style: TextStyle(fontSize: 12,color: Colors.red),),
            SizedBox(height: 4,),
            Text("   Length of Movie ( Optional )",
              style: TextStyle(fontSize: 19),),
            as(w, s1, "Length in ( HH:MM:SS )"),
            Text("   HD", style: TextStyle(fontSize: 19),),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Switch(
                value: hd,
                onChanged: (toggleSwitch) {
                  setState(() {
                    hd = toggleSwitch;
                  });
                },
                activeColor: Colors.green,
                inactiveThumbColor: Colors.grey,
              ),
            ),
            Text("   SD", style: TextStyle(fontSize: 19),),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Switch(
                value: sd,
                onChanged: (toggleSwitch) {
                  setState(() {
                    sd = toggleSwitch;
                  });
                },
                activeColor: Colors.green,
                inactiveThumbColor: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      persistentFooterButtons: [
        done && mine.isNotEmpty ? InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: "https://tubebox.in/$mine"));
            Global.showMessage(context, "Copied to Clipboard");
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Center(
                child: Container(
                  width: w - 90,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Color(0xff009788),
                      borderRadius: BorderRadius.circular(5)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Center(child: Text(maxLines: 1,
                      "https://tubebox.in/$mine",
                      style: TextStyle(color: Colors.white, fontSize: 12),)),
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
                  child: Center(child: Text("COPY",
                    style: TextStyle(color: Colors.white, fontSize: 14),)),
                ),
              ),
            ],
          ),
        ) : (on ? Center(child: CircularProgressIndicator()) : InkWell(
          onTap: () async {
            setState(() {
              on = true;
            });
            try {
              String id=DateTime.now().microsecondsSinceEpoch.toString();
              VideoModel video=VideoModel(
                aws:aws,
                  name: name.text, id: id, pic: pic, link: link.text, hd: hd, sd: sd, s1: "", pin:false
              );
              await FirebaseFirestore.instance.collection("video").doc(id).set(video.toJson());
              setState(() {
                done=true;
                mine="${id}"
;              });
            } catch (e) {
              print('❌ Error: $e');
              Global.showMessage(context, "Error: $e");
            } finally {
              setState(() {
                on = false;
              });
            }
          },
          child: Center(
            child: Container(
              width: w - 60,
              height: 50,
              decoration: BoxDecoration(
                  color: Color(0xff009788),
                  borderRadius: BorderRadius.circular(5)
              ),
              child: Center(child: Text("Add Now",
                style: TextStyle(color: Colors.white, fontSize: 18),)),
            ),
          ),
        )),
      ],
    );
  }

  String pic1="";

  Future<void> _uploadDummyVideo() async {
    final mutation = '''
      mutation CreateVideo(\$input: CreateVideoInput!) {
        createVideo(input: \$input) {
          id
          title
          uploaderId
          s3Key
          createdAt
        }
      }
    ''';
    final createdAt = DateTime.now()
        .toUtc()
        .toIso8601String(); // gives `2025-06-30T10:00:00Z`
    final user = await Amplify.Auth.getCurrentUser();
    final inputData = {
      "input": {
        "id": DateTime
            .now()
            .millisecondsSinceEpoch
            .toString(),
        "title": "Test Video",
        "uploaderId": user.username, // or use from Cognito
        "s3Key": "https://your-s3-url.mp4",
        "createdAt": createdAt, // optional, but safe
        "pic": "",
        "sd": true,
        "hd": true,
        "s1": null
        // ✅ DO NOT add "updatedAt"
      }
    };


    final request = GraphQLRequest<String>(
      document: mutation,
      variables: inputData,
      decodePath: "createVideo",
      // Required if response is structured
      authorizationMode: APIAuthorizationType.apiKey,
      apiName: "tubeboxs",
    );

    try {
      final response = await Amplify.API
          .mutate(request: request)
          .response;

      if (response.hasErrors) {
        print("❌ Error: ${response.errors}");
      } else {
        print("✅ Created video: ${response.data}");
      }
    } catch (e) {
      print("❌ Exception: $e");
    }
  }
  bool aws = false;

  String mine = "";
  bool done = false;
  bool hd = false,
      sd = false;
  TextEditingController link = TextEditingController();

  TextEditingController name = TextEditingController();

  TextEditingController s1 = TextEditingController();

  Widget as(double w, TextEditingController text, String te) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 14.0, right: 14, bottom: 15, top: 10),
      child: Container(
        width: w - 15, height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 10, bottom: 6.0, top: 9, right: 12),
          child: TextFormField(
            controller: text,
            readOnly: done,
            decoration: InputDecoration(
                hintText: te,
                border: InputBorder.none
            ),
            onFieldSubmitted: (String s) {

            },
            onSaved: (str) {

            },
          ),
        ),
      ),
    );
  }
}
