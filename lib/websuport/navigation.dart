import 'package:flutter/material.dart';
import 'package:tubebox/websuport/all_videos.dart';
import 'package:tubebox/websuport/upload.dart';

class NavigationRails extends StatefulWidget {
  @override
  _NavigationRailExampleState createState() => _NavigationRailExampleState();
}

class _NavigationRailExampleState extends State<NavigationRails> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all, // Other options: none, selected
            leading: Container(width:70,child: Image.asset("assets/logos.png")),
            destinations: const [
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
                icon: Icon(Icons.logout),
                selectedIcon: Icon(Icons.logout_sharp),
                label: Text('Logout'),
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

class LoginNow extends StatelessWidget {
 LoginNow({super.key});

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
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text("   Password",style: TextStyle(fontSize: 19),),
                    as(w, name, "Name of Movie"),
                    Text("   Security PIN",style: TextStyle(fontSize: 19),),
                    as(w,link, "Link of Movie"),
                   SizedBox(height: 40,),
                    InkWell(
                      child: Center(
                        child: Container(
                          width: w-60,
                          height: 50,
                          decoration: BoxDecoration(
                              color: Color(0xff009788),
                              borderRadius: BorderRadius.circular(5)
                          ),
                          child: Center(child: Text("Add Now",style: TextStyle(color: Colors.white,fontSize: 18),)),
                        ),
                      ),
                    ),
                    SizedBox(height: 40,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
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
                          child: Center(
                            child: Container(
                              width: w/4-45,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(5)
                              ),
                              child: Center(child: Text("Close App",style: TextStyle(color: Colors.white,fontSize: 18),)),
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
  String mine="";bool done=false;
  bool hd=false,sd=false;
  TextEditingController link=TextEditingController();

  TextEditingController name=TextEditingController(text: "TubeBoxAdmin");

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
            readOnly: te=="Name of Movie",
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
