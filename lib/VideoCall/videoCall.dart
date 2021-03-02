import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:http/http.dart' as http;
import 'dart:math';
const APP_ID = '93fa9003ab1a44fa9f3279bc6e54f7b9';
// const Token = '00693fa9003ab1a44fa9f3279bc6e54f7b9IACy56/lPaMUyQYbGLk4uyTcJr9/66CINx0ICo7f1iTNtTELE08AAAAAEADqgOQ9pSk+YAEAAQCjKT5g';


class VideoCall extends StatefulWidget {
  @override
  _VideoCallState createState() => _VideoCallState();
}

// App states
class _VideoCallState extends State<VideoCall> {
  bool _joined = false;
  int _remoteUid = null;
  bool _switch = false;
  RtcEngine engine;
  int count=0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer)async {
      count++;

      if(count==15 && _remoteUid==null ){
        
        // engine.leaveChannel();
      _key.currentState.showSnackBar(SnackBar(content: Text("Please Try Again"),duration: Duration(seconds:1)));
      engine.leaveChannel();

      Future.delayed(Duration(seconds: 2)).then((value) {
        Navigator.of(context).pop;});
      
      
      // engine.leaveChannel();
      
      // Navigator.of(context).pop();
      
      }
    });
    joinToActiveUser();
  }

  GlobalKey<ScaffoldState> _key=GlobalKey();

FirebaseFirestore firestore=FirebaseFirestore.instance;
String uid='';
  
    joinToActiveUser()async{
       await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );

      firestore.collection("Users").where("isSecond",isEqualTo:null).where("isFirst",isNotEqualTo: FirebaseAuth.instance.currentUser.uid).get().then((value)async {
        
        if(value.docs.isEmpty){
          uid=FirebaseAuth.instance.currentUser.uid;
           engine = await RtcEngine.create(APP_ID);

          engine.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          print('joinChannelSuccess ${channel} ${uid}');
          setState(() {
            _joined = true;
          });
        }, userJoined: (int uid, int elapsed) {
      print('userJoined ${uid}');
      setState(() {
        _remoteUid = uid;
      });
    }, userOffline: (int uid, UserOfflineReason reason) {
      print('userOffline ${uid}');
    // if(reason==UserOfflineReason.Quit){
    //     FirebaseFirestore.instance.collection("Users").doc(this.uid).delete();
      
    //   Navigator.of(context).pop();
    
    // }
      setState(() {
        _remoteUid = null;
      });
    
    }));

    

    

           var random=Random();
           var channel=random.nextInt(100000).toString();
         http.Response response=await http.get('https://agrokey031.herokuapp.com/access_token?channel=$channel');
         var data=jsonDecode(response.body);
          String token=data["token"];
             await engine.enableVideo();
           await engine.joinChannel(token, channel, null, 0).then((va){
             firestore.collection("Users").doc(FirebaseAuth.instance.currentUser.uid).set({

                "isFirst":FirebaseAuth.instance.currentUser.uid,
                "isSecond":null,
                "channel":channel,
                "token":token
             });
           } );
        }else{
          
        engine = await RtcEngine.create(APP_ID);
        uid=value.docs[0].id;

        engine.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          print('joinChannelSuccess ${channel} ${uid}');
          setState(() {
            _joined = true;
          });
        }, userJoined: (int uid, int elapsed) {
      print('userJoined ${uid}');
      setState(() {
        _remoteUid = uid;
      });
    }, userOffline: (int uid, UserOfflineReason reason) {
      print('userOffline ${uid}');
      setState(() {
        _remoteUid = null;
      });
      
    }));
    // Enable video


          
          await engine.enableVideo();
           await engine.joinChannel(value.docs[0]["token"],value.docs[0]["channel"], null, 0).then((va) => firestore.collection("Users").doc(value.docs[0].id).update({
             "isSecond":FirebaseAuth.instance.currentUser.uid
           }));
        }
      });
    }

    @override
  void dispose() {
    
    super.dispose();
    engine.destroy();
  }
  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _key,
        appBar: AppBar(
          title: const Text('Flutter example app'),
        ),
        body: Stack(
          children: [
            Center(
              child: _switch ? _renderRemoteVideo() : _renderLocalPreview(context),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _switch = !_switch;
                    });
                  },
                  child: Center(
                    child:
                    _switch ? _renderLocalPreview(context) : _renderRemoteVideo(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Generate local preview
  Widget _renderLocalPreview(BuildContext context) {
    if (_joined) {
      return Stack(
        children: [
          RtcLocalView.SurfaceView(),
         Padding(
           padding: const EdgeInsets.all(8.0),
           child: Align(
             alignment: Alignment.bottomCenter,
                      child: FloatingActionButton(
                        
                  child: Icon(Icons.call_end,color: Colors.red,size: 30,),
                  backgroundColor: Colors.white,
                  onPressed: (){
                      engine.leaveChannel();
                      FirebaseAuth.instance.signOut().then((value) => Navigator.of(context).pop());
                     
                  },
                ),
           ),
         ),
         
          
          
        ],
      );
    } else {
      return Text(
        'Wait We are Searching Users For you.',
        textAlign: TextAlign.center,
      );
    }
  }

  // Generate remote preview
  Widget _renderRemoteVideo() {
    if (_remoteUid != null) {
      return RtcRemoteView.SurfaceView(uid: _remoteUid);
    } else {
      return Text(
        'We are Searching for users',
        textAlign: TextAlign.center,
      );
    }
  }
}