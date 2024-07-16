import 'dart:async';
import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/screens/login_screen.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/apis.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isAnimate = true;
  void initState() {
    super.initState();

    //after this time animation start
    Future.delayed(Duration(milliseconds: 500),(){
      setState(() {
        _isAnimate = !_isAnimate;
      });
      //calling Splash Screen for time out Splash Screen
      splashScreen();
    });
  }


  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        // color: Colors.white,
        child: Stack(
          children: [
            AnimatedPositioned(
              width: mq.width*.50,
              top: _isAnimate? mq.height*-0.50 : mq.height*.15 ,
              left: mq.width*.25,
              duration: Duration(seconds: 2),
              child: Image.asset('assets/images/chat.png'),
            ),
            Positioned(
              width: mq.width*.90,
              height: mq.height*0.06,
              bottom: mq.height*.30,
              left: mq.width*.05,
                child:Center(
                  child: RichText(
                    text: TextSpan(
                        style: TextStyle(
                          color: Color(0xffef2fef),
                          // color: Color(0xfffd00f2),
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(text: 'Welcome to '),
                          TextSpan(text: 'Chat Karo ❤️',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,color: Color(0xff0ff1f5)
                              ),
                          ),
                        ]
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void splashScreen() {
    Timer(Duration(seconds: 3), () {

      //For Exit Full Screen(show notch)
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      //for style notch
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        //bottom navigationBar color(bottom notch area)
          systemNavigationBarColor: Color.fromARGB(255, 32, 42, 51),
        //top notch area color
        statusBarColor: Color.fromARGB(255, 32, 42, 51),
      ));

        if(APIs.auth.currentUser != null){
          //goto HomeScreen
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomeScreen()));
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>SignupPage()));
        }else{
          // goto login screen
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
        }
    });
  }
}

