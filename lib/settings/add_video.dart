import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tubebox/global.dart';
import 'package:tubebox/model/video_model.dart';
import 'package:tubebox/provider/storage.dart';

class AddVideo extends StatefulWidget {
 AddVideo({super.key});

  @override
  State<AddVideo> createState() => _AddVideoState();
}

class _AddVideoState extends State<AddVideo> {
String pic="";

 pickImage(ImageSource source) async {
   final ImagePicker _imagePicker = ImagePicker();
   XFile? _file = await _imagePicker.pickImage(source: source);
   if (_file != null) {
     return await _file.readAsBytes();
   }
   print('No Image Selected');
 }
bool on=false;
  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Video"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    String photoUrl = await StorageMethods()
                        .uploadImageToStorage('users', _file!, true);
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
            Text("   Length of Movie ( Optional )",style: TextStyle(fontSize: 19),),
            as(w,s1, "Length in ( HH:MM:SS )"),
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
      ),
      persistentFooterButtons: [
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
              VideoModel vi=VideoModel(name: name.text, id: id, pic: pic, link: link.text, hd: hd, sd: sd, s1: s1.text);
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
    );
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
