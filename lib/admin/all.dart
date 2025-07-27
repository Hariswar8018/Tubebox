
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tubebox/global.dart';

import '../model/video_model.dart';
import '../models/Video.dart';

class All_Videos extends StatelessWidget {
  const All_Videos({super.key});


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("All Videos",style: TextStyle(color: Colors.black),),
      ),
      body: Center(child: Text("No videos found")),
    );
  }
  /*
  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    double h=MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("All Videos",style: TextStyle(color: Colors.black),),
      ),
      body: FutureBuilder<List<Video>>(
        future: getVideos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text("No videos found"));
          }
          if(snapshot.data!.isEmpty){
            return Center(child: Text("No videos foundS"));
          }
          final videos = snapshot.data!;
          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final vi = videos[index];
              return ListTile(
                title: Text(vi.title),
                subtitle: Text("https://tubebox.in/${vi.id}"),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: "https://tubebox.in/${vi.id}"));
                  Global.showMessage(context, "Copied to Clipboard");
                },
              );
            },
          );
        },
      ),
    );
  }
  Future<List<Video>> getVideos() async {
    try {
      final request = ModelQueries.list(Video.classType);
      final response = await Amplify.API.query(
        request: request,// Ensure auth
      ).response;

      if (response.hasErrors) {
        print("GraphQL error: ${response.errors.first.message}");
        return [];
      }

      final List<Video> videos = response.data?.items?.whereType<Video>().toList() ?? [];
      return videos;
    } catch (e) {
      print("API error: $e");
      return [];
    }
  }
*/
}
