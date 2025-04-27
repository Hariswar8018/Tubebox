import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubebox/firebase_options.dart';
import 'package:tubebox/home/navigation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(MobileAds.instance.initialize());
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final SharedPreferences pref= await SharedPreferences.getInstance();
  bool night=pref.getBool("night")??false;
  runApp(
     MyApp(night: night),
  );
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
  void initState(){
    h();
    Timer(Duration(seconds: 3), () async {
        print("Going...................90");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Navigation(),));
    });

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
