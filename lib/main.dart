// import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import './VideoCall/videoCall.dart';
// const APP_ID = '93fa9003ab1a44fa9f3279bc6e54f7b9';
// const Token = '00693fa9003ab1a44fa9f3279bc6e54f7b9IACy56/lPaMUyQYbGLk4uyTcJr9/66CINx0ICo7f1iTNtTELE08AAAAAEADqgOQ9pSk+YAEAAQCjKT5g';

void main() {
    WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(home: MyApp()));

}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context,snapshot){
        
        if(snapshot.hasError){
          print("Error Occured");
        }
        if(snapshot.connectionState==ConnectionState.done){
          return Home();
        }
        return Center(child:CircularProgressIndicator());
      },

    );
  }
}


class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
 
// BannerAd _bannerAd;

// static const MobileAdTargetingInfo targetingInfo=MobileAdTargetingInfo(

// );

//   BannerAd createBannerAd() {
//     return BannerAd(
//       adUnitId: BannerAd.testAdUnitId,
//       targetingInfo: targetingInfo,
//       size: AdSize.smartBanner,
//       listener: (MobileAdEvent event) {
//         print("BannerAd event $event");
//       },
//     );
//   }
   
//     int _coins = 0;


    @override
  void initState() {
    super.initState();
    // FirebaseAdMob.instance.initialize(appId:"ca-app-pub-4554832681720651~8307423134");
    // _bannerAd = createBannerAd()..load();
   
  }

  @override
  Widget build(BuildContext context) {
    // _bannerAd?.show();
    return Scaffold(
      appBar: AppBar(
        title: Text("Random Call"),
      ),
      body: Column(
        children: [
          Center(
            child:RaisedButton(child: Text("Get Started"),onPressed: ()async{
                await FirebaseAuth.instance.signInAnonymously().then((value) => Navigator.of(context).push(MaterialPageRoute(builder:(context)=>VideoCall())));
               
            },),
          ),
          
        ],
      ),
    );
  }
}
