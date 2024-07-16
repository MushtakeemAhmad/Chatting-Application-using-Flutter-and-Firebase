// import 'dart:developer';
import 'package:chat_app/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  bool _isAnimate = true;
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = !_isAnimate;
      });
    });
  }

  _handleGoogleBtnClicked() {
    //show progressBar (Loading)
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      // Navigator.pop(context);
      if (user != null) {
        // log('\nUser: ${user.user}');
        // log('\nAdditionalUserInfo : ${user.additionalUserInfo}');
        // print('\nUser: ${user.user}');
        // print('\nAdditionalUserInfo : ${user.additionalUserInfo}');
        if (await APIs.userExists()) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        } else {
          APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      // we use here APIs.auth instead of FirebaseAuth.instance
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      Navigator.pop(context);
      Dialogs.showSnackBar(context,
          'Somethings Went Wrong \n(Please Check Internet Connectivity)');
    }
    return null;
  }

  //for signOut
  // _signOut() async {
  //   await FirebaseAuth.instance.signOut();
  //   await GoogleSignIn.signOut();
  // }
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Chat Karo'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            width: mq.width * .50,
            top: _isAnimate ? mq.height * -0.50 : mq.height * .15,
            left: mq.width * .25,
            duration: Duration(seconds: 3),
            child: Image.asset('assets/images/chat.png'),
          ),
          Positioned(
            width: mq.width * .80,
            height: mq.height * 0.06,
            bottom: mq.height * .15,
            left: mq.width * .10,
            child: AnimatedOpacity(
              opacity: _isAnimate ? 0.0 : 1.0,
              duration: Duration(seconds: 3),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>HomeScreen()));
                  _handleGoogleBtnClicked();
                },
                icon: Image.asset(
                  'assets/images/google.png',
                  height: mq.height * 0.04,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffdaeef1),
                  shape: StadiumBorder(),
                  elevation: 1,
                ),
                label: RichText(
                  text: TextSpan(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                      ),
                      children: [
                        TextSpan(text: 'SignUp/LogIn with '),
                        TextSpan(
                            text: 'Google',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
