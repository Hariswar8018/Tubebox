import 'dart:async';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart' show AmplifyAuthCognito;
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart' show AmplifyStorageS3;
import 'package:flutter/foundation.dart';
import 'package:amplify_datastore/amplify_datastore.dart'; // DataStore
import 'models/ModelProvider.dart'; // ModelProvider
import 'amplifyconfiguration.dart'; // Auto-generated config
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubebox/firebase_options.dart';
import 'package:tubebox/home/navigation.dart';

import 'package:tubebox/websuport/globa.dart' show GloablWeb;
import 'package:tubebox/websuport/navigation.dart';
import 'dart:io';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'dart:io' show File;

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:aws_common/vm.dart';

import 'package:tubebox/websuport/upload.dart';

import 'amplifyconfiguration.dart';
final bool isMobile = (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android);
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if(!isMobile){
    runApp(
      MyApp(night: false),
    );
    return ;
  }
  final SharedPreferences pref= await SharedPreferences.getInstance();
  bool night=pref.getBool("night")??false;

  runApp(
     MyApp(night: night),
  );
  bool _amplifyConfigured = false;

}

class MyApp extends StatelessWidget {
  MyApp({super.key,required this.night});
  bool get isIOS {
    return Platform.isIOS;
  }
  bool night;
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'TubeBox',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: night),
    );
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({super.key, required this.title});

  final bool title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
bool isnight=false;

Color bgcolor = false?Color(0xffFDE7EA):Colors.white;

Color gree= Color(0xff009788);

Color greens=Colors.green.withOpacity(0.10);


class _MyHomePageState extends State<MyHomePage> {
  bool _amplifyConfigured = false;
  Future<void> _configureAmplify() async {
    if (!_amplifyConfigured) {
      try {
        await Amplify.addPlugins([
          AmplifyAuthCognito(),
          AmplifyStorageS3(),

        ]);
        await Amplify.configure(amplifyconfig);
        setState(() {
          _amplifyConfigured = true;
        });
        print('Amplify configured');
      } catch (e) {
        print('Amplify already configured or error: $e');
      }
    }
  }
  Future<void> uploadFile(File file) async {
    try {
      final result = await Amplify.Storage.uploadFile(
        localFile: AWSFilePlatform.fromFile(file),
        path: const StoragePath.fromString('picture-submissions/myPhoto.png'),
      ).result;
      safePrint('Uploaded file: ${result.uploadedItem.path}');
    } on StorageException catch (e) {
      safePrint(e.message);
    }
  }

  Future confirm() async {
    final result = await Amplify.Auth.confirmSignUp(
      username: "hariswarsamasi@gmail.com",
      confirmationCode: "676944",
    );

    if (result.isSignUpComplete) {
      print("✅ User confirmed!");
      GloablWeb.mess(context, "Account confirmed. You can now log in!", true);
    } else {
      print("⚠️ Still not complete: ${result.nextStep}");
      GloablWeb.mess(context, "Something went wrong. Try again.", false);
    }
  }

  Future<void> signUpUser(String email, String password) async {
    try {

      final res = await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: SignUpOptions(
          userAttributes: {
            AuthUserAttributeKey.email: email,
          }
        )

      );
      print("🔐 Sign up complete: ${res.isSignUpComplete}");
    } on AuthException catch (e) {
      print("❌ Sign up error: ${e.message}");
    }
  }


  void initState(){
    _configureAmplify();
    h();

    if(isMobile){
      Timer(Duration(seconds: 3), () async {
        print("Going...................90");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Navigation(),));
      });
    }else{
      Timer(Duration(seconds: 3), () async {
        print("Going...................90");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NavigationRails(),));
      });
    }


  }
  h() async {
    isnight=widget.title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color:widget.title?Colors.black: Colors.white,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Image(
                image: AssetImage('assets/logos.png'),
                fit: BoxFit.contain,
              ),
            ),
            Spacer(),
            Text("Made with ❤️ in India",style: TextStyle(fontWeight: FontWeight.w800,fontSize: 19,color: widget.title?Colors.white:Colors.black),),
            Text("Tubebox v1.0.8",style: TextStyle(fontWeight: FontWeight.w300,fontSize: 9,color: widget.title?Colors.white:Colors.black),),
            SizedBox(height: 80,)
          ],
        ),
      ),
    );
  }
}
