import 'package:flutter/material.dart';

class GloablWeb{
  static mess(BuildContext context, String str, bool s){
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(str),
        width: MediaQuery.of(context).size.width/2+70,
        behavior: SnackBarBehavior.floating, // 👈 important for Web
        duration: Duration(seconds: 3),
        backgroundColor: s?Colors.red:Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  // amplifyconfiguration.dart
  static const amplifyconfig = '''{
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "auth": { ... },
  "storage": {
    "plugins": {
      "awsS3StoragePlugin": {
        "bucket": "videoStorage",
        "region": "ap-south-1",
        ...
      }
    }
  }
}''';

}