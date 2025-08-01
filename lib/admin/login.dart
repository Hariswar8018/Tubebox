import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:share_plus/share_plus.dart' show Share;
import 'package:tubebox/home/profile.dart';
import 'package:tubebox/main.dart';

import '../websuport/globa.dart';

class Login extends StatefulWidget {
   Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController link=TextEditingController();

  TextEditingController name=TextEditingController();

  TextEditingController s1=TextEditingController();

  bool on = false;
  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    double h=MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: Image.asset("assets/logos.png"),
        title: Text("TubeBox",style: TextStyle(fontSize: 24,color: Colors.white),),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: InkWell(
              onTap: (){
                Navigator.pop(context);
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.close,color: Colors.blue,),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15,),
          Text("   Email",style: TextStyle(fontSize: 19),),
          as(w, name, "admin@gmail.com"),
          Text("   Security PIN",style: TextStyle(fontSize: 19),),
          as(w,link, "********"),
          SizedBox(height: 15,),
          on?Center(child: CircularProgressIndicator()):InkWell(
            onTap: () async {
              try {
                setState(() {
                  on=true;
                });
                print(link.toString());
                print("Trying login with email: [${name.text} & ${link}]");
                final res = await Amplify.Auth.signIn(
                  username:name.text,
                  password: link.text,
                );
                if (res.isSignedIn) {
                  GloablWeb.mess(context, "Login successful..........Redirecting", true);
                  Future.delayed(const Duration(milliseconds: 500), () {
// Here you can write yo
                    Navigator.pushReplacement(
                      context,
                      PageTransition(
                        child:MyApp(night: false),
                        type: PageTransitionType.rightToLeft,
                        duration: Duration(milliseconds: 100),
                      ),
                    );
                    setState(() {
                      on=false;
                    });
                  });
                  print("✅ Login successful!");
                } else {
                  setState(() {
                    on=false;
                  });
                  print("❗ Login challenge: ${res.nextStep.signInStep}");
                  GloablWeb.mess(context, "Login challenge: ${res.nextStep.signInStep}", false);
                }
              } on AuthException catch (e) {
                setState(() {
                  on=false;
                });
                print("❌ Login error: ${e.message}");
                GloablWeb.mess(context, e.message, false);
              }},child: Center(
            child: Container(
              width: w-60,
              height: 50,
              decoration: BoxDecoration(
                  color: Color(0xff009788),
                  borderRadius: BorderRadius.circular(5)
              ),
              child: Center(child: Text("Sign In",style: TextStyle(color: Colors.white,fontSize: 18),)),
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget as(double w,TextEditingController text,String te){
    return Padding(
      padding: const EdgeInsets.only(left: 14.0,right: 14,bottom: 15,top: 10),
      child: Container(
        width: w-15,height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 10,bottom: 6.0,top: 9,right: 12),
          child: TextFormField(
            controller: text,
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
