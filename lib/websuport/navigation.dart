import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart' show Amplify;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemNavigator;
import 'package:page_transition/page_transition.dart' show PageTransition, PageTransitionType;
import 'package:tubebox/websuport/all_videos.dart';
import 'package:tubebox/websuport/upload.dart';

import 'globa.dart';

class NavigationRails extends StatefulWidget {
  @override
  _NavigationRailExampleState createState() => _NavigationRailExampleState();
}

class _NavigationRailExampleState extends State<NavigationRails> {
  int _selectedIndex = 2;
   bool loggedin = false;
  void initState(){
    checkIfSignedIn();
  }
  Future<void> checkIfSignedIn() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (session.isSignedIn) {
        print("✅ User already signed in");
        setState(() {
          loggedin = true;
          _selectedIndex=1
      ;  });
        return;
      } else {
        print("🔒 User not signed in");
      }
    }catch(e){

    }
    loggedin = false;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {

              if(loggedin){
                setState(() {
                  _selectedIndex = index;
                });
              }else{
                GloablWeb.mess(context, "You must LogIn", true);
              }
            },
            labelType: NavigationRailLabelType.all, // Other options: none, selected
            leading: Container(width:70,child: Image.asset("assets/logos.png")),
            destinations:  [
              NavigationRailDestination(
                icon: Icon(Icons.list),
                selectedIcon: Icon(Icons.view_carousel_sharp),
                label: Text('Videos'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.upload),
                selectedIcon: Icon(Icons.upload_file_rounded),
                label: Text('Upload'),
              ),
              NavigationRailDestination(
                icon: loggedin? Icon(Icons.logout,color: Colors.red,):Icon(Icons.login_sharp,color: Colors.green,),
                selectedIcon: Icon(Icons.logout_sharp),
                label: Text(loggedin?'Log Out':"Log IN"),
              ),
            ],
          ),
          Expanded(
            child: as()
          ),
        ],
      ),
    );
  }

  Widget as(){
    if(_selectedIndex==0){
      return All_Vids();
    }else if(_selectedIndex==1){
      return Upload();
    }
    return LoginNow();
  }
}

class LoginNow extends StatefulWidget {
 LoginNow({super.key});

  @override
  State<LoginNow> createState() => _LoginNowState();
}

class _LoginNowState extends State<LoginNow> {

  bool on=false;

  bool forgetpassword=false;
  TextEditingController forgets=TextEditingController();
  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    double h=MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
        body: Row(
          children: [
            Container(
              width: w/2-40,height: h,
              decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage("assets/Ai-Password-Security.jpg"),fit: BoxFit.cover,alignment: Alignment.centerLeft)
              ),
            ),
            Container(
              width: w/2-40,height: h,
              decoration: BoxDecoration(
                  color:Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade100 , width: 4)
              ),
              child: Padding(
                padding:const EdgeInsets.all(20.0),
                child: Column(
                  children: [

                    Text("   Email",style: TextStyle(fontSize: 19),),
                    as(w, name, "admin@gmail.com"),
                    Text(forgetpassword?"     New Security PIN":"   Security PIN",style: TextStyle(fontSize: 19),),
                    as(w,link, "********"),
                    forgetpassword?Text("   Email 6Digit Pin",style: TextStyle(fontSize: 19),):SizedBox(),
                    forgetpassword?as(w,forgets, "000000"):SizedBox(),
                   SizedBox(height: 40,),
                    on?CircularProgressIndicator():InkWell(
                      onTap: () async {
                        if(forgetpassword){
                          final result = await Amplify.Auth.confirmResetPassword(
                            username: name.text,
                            newPassword: link.text,  // ✅ follow Cognito password rules
                            confirmationCode: forgets.text,         // 🔁 from email or SMS
                          );

                          if (result.isPasswordReset) {
                            print("✅ Password reset successful!");
                            GloablWeb.mess(context, "Password reset! You can log in now.", true);
                            setState((){
                              forgetpassword=false;
                            });
                          } else {
                            print("❌ Password reset failed");
                            GloablWeb.mess(context, "Reset failed. Try again.", false);
                          }

                          return ;
                        }
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
                                  child: NavigationRails(),
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
                          child: Center(child: Text(forgetpassword?"Reset Now":"Add Now",style: TextStyle(color: Colors.white,fontSize: 18),)),
                        ),
                      ),
                    ),
                    SizedBox(height:10),
                    on?LinearProgressIndicator():SizedBox(),
                    SizedBox(height: 40,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap:() async {
                            try {
                              await Amplify.Auth.resetPassword(username: "tubeboxhelp@gmail.com");
                              GloablWeb.mess(context, "Sent successful", false);
                              setState((){
                                forgetpassword=true;
                              });
                            }catch(e){
                              GloablWeb.mess(context, "$e", true);
                            }
                          },
                          child: Center(
                            child: Container(
                              width: w/4-45,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: Colors.brown,
                                  borderRadius: BorderRadius.circular(5)
                              ),
                              child: Center(child: Text("Reset Password",style: TextStyle(color: Colors.white,fontSize: 18),)),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: (){
                            setState(() {
                              name.text="";
                              link.text="";
                            });
                          },
                          child: Center(
                            child: Container(
                              width: w/4-45,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(5)
                              ),
                              child: Center(child: Text("Reset",style: TextStyle(color: Colors.white,fontSize: 18),)),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        )
    );
  }

 Future<void> signUpUser(String email, String password) async {
   try {
     final res = await Amplify.Auth.signUp(
       username: email,
       password: password,
     );
     print("Sign up complete: ${res.isSignUpComplete}");
   } on AuthException catch (e) {
     print("Sign up error: ${e.message}");
   }
 }

  String mine="";
bool done=false;
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
