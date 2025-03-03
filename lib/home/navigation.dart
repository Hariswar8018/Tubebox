import 'package:flutter/material.dart';
import 'package:tubebox/history.dart';
import 'package:tubebox/home/hh.dart';
import 'package:tubebox/home/home.dart';
import 'package:tubebox/home/profile.dart';

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
    return Scaffold(
      backgroundColor: Color(0xffFDE7EA),
      extendBodyBehindAppBar: true,
      body: diu(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {

          _currentIndex=index;
          setState(() {

          });

        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time_sharp),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.privacy_tip),
            label: "Privacy",
          ),
        ],
        selectedItemColor: Colors.blueAccent, // Selected icon color
        unselectedItemColor: Colors.black, // Unselected icon color
        backgroundColor:Color(0xffFDE7EA), // Background color
      ),
    );
  }
}
