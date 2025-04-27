import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tubebox/global.dart';

import '../model/video_model.dart';

class All_Videos extends StatelessWidget {
  const All_Videos({super.key});

  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    double h=MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(

        title: Text("All Videos",style: TextStyle(color: Colors.black),),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("video")
            .snapshots(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.active:
            case ConnectionState.done:
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text("No stories available"));
              }
              List<VideoModel> stories = snapshot.data!.docs
                  .map((doc) => VideoModel.fromJson(doc.data() as Map<String, dynamic>))
                  .toList();
              return ListView.builder(
                scrollDirection: Axis.vertical, // Enable horizontal scrolling
                itemCount: stories.length,
                itemBuilder: (context, index) {
                  VideoModel vi = stories[index];
                  return Container(
                    width:w,height:122,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0), // Adds spacing
                      child: InkWell(
                        onLongPress: () async {
                          await FirebaseFirestore.instance
                              .collection("video").doc(vi.id).update({
                            "pin":!(vi.pin),
                          });
                        },
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: "https://tubebox.in/${vi.id}"));
                          Global.showMessage(context, "Copied to Clipboard");
                        },
                        child: Column(
                          children: [
                            ListTile(
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
                                  vi.pin?Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Container(
                                        color: Colors.red,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 8,right: 8,top: 3.0,bottom: 3),
                                          child: Text("PIN",style: TextStyle(color: Colors.white,fontSize: 12),),
                                        )),
                                  ):SizedBox(),
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
                              trailing: IconButton(onPressed: (){
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Delete"),
                                      content: Text("Are you sure you want to delete? Old Users also couldn't view the Video"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context); // Close dialog
                                          },
                                          child: Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            await FirebaseFirestore.instance
                                                .collection("video").doc(vi.id).delete();
                                            // Add your action here
                                          },
                                          child: Text("OK"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }, icon: Icon(Icons.delete)),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Center(
                                  child: Container(
                                    width: w-94,
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: Color(0xff009788),
                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0,right: 8),
                                      child: Center(child: Text(maxLines: 1,"https://tubebox.in/${vi.id}",style: TextStyle(color: Colors.white,fontSize: 12),)),
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
                                    child: Center(child: Icon(Icons.copy,color: Colors.white,)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
          }
        },
      ),
    );
  }
}
