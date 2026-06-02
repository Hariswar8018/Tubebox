import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tubeboxs/screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tubebox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF10B981),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10B981),
          secondary: Color(0xFF10B981),
        ),
      ),
      home: SplashScreen(),
    );
  }
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  void initState(){
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>  MainScreen()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset("assets/logos.png"),
      ),
    );
  }
}
/*
1) User should also have Name, Address, Phone No ( Unique ), Place and their District ( India Kerela Distrcit + Others ). They are required to fill this information in order to Create an Application. Admin must also write this information to create new applciation for User. 2) SuperAdmin could see the User Profile Details from both application and clicking on user. 3) Application submission, They could also uploiad a SMALL PDF or Image that could be attachj with application and both user, admin, superadmin could see that document .Could we use cloudinary api or railway we have any storage system for that ? 4) Superadmin could delete Application, User, Admin and Superadmin ( except his profile ) . 5) Superadmin could export CSV / XML files of all the Applications with user information and could download them 6) Superadmin could EDIT the information of user application ( like title, description ). 7) Also each department will have a officer name, Phone and Email Address that could be seen in application too
 */
