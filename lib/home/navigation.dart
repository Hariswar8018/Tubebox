import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubebox/history.dart';
import 'package:tubebox/home/hh.dart';
import 'package:tubebox/home/home.dart';
import 'package:tubebox/home/profile.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _currentIndex = 0;
  Widget diu(){
    if(_currentIndex==2){
      return Profile();
    }else if(_currentIndex==1){
      return J();
    }
    return Home();
  }
  final _pageController = PageController(initialPage: 0);

  /// Controller to handle bottom nav bar and also handles initial page
  final NotchBottomBarController _controller = NotchBottomBarController(index: 0);

  int maxCount = 5;

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  Future<bool> _onWillPop(BuildContext context) async {
    bool exitApp = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Exit App"),
          content: Text("Are you sure you want to exit?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // Stay in the app
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // Exit the app
              child: Text("Exit"),
            ),
          ],
        );
      },
    ) ?? false; // If the dialog is dismissed, return false (stay in the app)
    return exitApp;
  }
  @override
  Widget build(BuildContext context) {
    final List<Widget> bottomBarPages = [
    Home(),
    J(),
    Profile(),
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isnight?Colors.black:greens,
        centerTitle: true,
        leading: Image.asset("assets/logos.png"),
        title: Text(_currentIndex==0?"TubeBox":_currentIndex==1?"History":"Privacy Policy",style: TextStyle(fontSize: 24,color: isnight?Colors.white:Colors.black),),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: InkWell(
              onTap: (){
                Share.share('Hello ! I got New App name *TubeBox* that have many Videos from Disney to Private Videos ! Also you could view Important Features too. \n\nSo, What are you waiting for?\nDownload now from PlayStore \nhttps://play.google.com/store/apps/details?id=com.tube.box.entertainment.app');
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.link,color: Colors.blue,),
              ),
            ),
          ),
          IconButton(onPressed: (){
            setState(() async {
              isnight=!isnight;
              final SharedPreferences pref= await SharedPreferences.getInstance();
              pref.setBool("night", isnight);
              Navigator.pushReplacement(
                  context, PageTransition(
                  child:   MyHomePage(title: isnight), type: PageTransitionType.rightToLeft, duration: Duration(milliseconds: 200)
              ));
            });
          }, icon:isnight?Icon(Icons.sunny,color:isnight?Colors.white:Colors.black): Icon(Icons.nightlight,color:isnight?Colors.white:Colors.black)),
        ],
      ),
      backgroundColor:  isnight?Colors.black:bgcolor,
      extendBodyBehindAppBar: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(bottomBarPages.length, (index) => bottomBarPages[index]),
      ),
      extendBody: true,
      bottomNavigationBar:AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        color: !isnight?Colors.black:bgcolor,
        showLabel: true,
        textOverflow: TextOverflow.fade,
        maxLine: 1,
        shadowElevation: 5,
        kBottomRadius: 28.0,
        notchColor: gree,
        removeMargins: false,
        bottomBarWidth: 500,
        showShadow: false,
        durationInMilliSeconds: 300,
        itemLabelStyle: TextStyle(fontSize: 10,color: isnight?Colors.black:bgcolor),
        elevation: 1,
        bottomBarItems: [
          BottomBarItem(
            inActiveItem: Icon(
              Icons.home_filled,
              color: isnight?Colors.black:bgcolor
            ),
            activeItem: Icon(
              Icons.home_filled,
              color: isnight?Colors.black:bgcolor
            ),
            itemLabel: 'Home',
          ),
          BottomBarItem(
            inActiveItem: Icon(
              Icons.refresh,
              color: isnight?Colors.black:bgcolor
            ),
            activeItem: Icon(
              Icons.refresh,
              color: isnight?Colors.black:bgcolor
            ),
            itemLabel: 'History',
          ),
          BottomBarItem(
            inActiveItem: Icon(
              Icons.privacy_tip,
              color: isnight?Colors.black:bgcolor
            ),
            activeItem: Icon(
              Icons.privacy_tip_outlined,
              color: isnight?Colors.black:bgcolor
            ),
            itemLabel: 'History',
          ),
        ],
        onTap: (index) {
          _pageController.jumpToPage(index);
          _currentIndex=index;
          setState(() {

          });
        },
        kIconSize: 24.0,
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _currentIndex,
      //   onTap: (index) {
      //
      //     _currentIndex=index;
      //     setState(() {
      //
      //     });
      //
      //   },
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: "Home",
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.access_time_sharp),
      //       label: "History",
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.privacy_tip),
      //       label: "Privacy",
      //     ),
      //   ],
      //   selectedItemColor: Colors.blueAccent, // Selected icon color
      //   unselectedItemColor:isnight?Colors.white: Colors.black, // Unselected icon color
      //   backgroundColor: isnight?Colors.black:bgcolor, // Background color
      // ),
    );
  }
}
