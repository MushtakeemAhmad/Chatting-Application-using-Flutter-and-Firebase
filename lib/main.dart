// import 'dart:math';
// import 'dart:convert';
import 'dart:developer';
import 'package:chat_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'firebase_options.dart';

late Size mq;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //show Splash Screen in full screen(hide notch)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  //fix Rotation(Orientation) only portraitUp and portraitDown
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]
  ).then((value) => {
    // WidgetsFlutterBinding.ensureInitialized(),
    // Firebase.initializeApp(),
  //for active/initialize firebase
      _initializeFirebase(),
      runApp(const MyApp())
  });
}

class MyApp extends StatefulWidget{
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override


  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Color.fromARGB(255, 32, 42, 51),
    ));
    return MaterialApp(
      title: 'Chat Karo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // primarySwatch: Colors.cyan,
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 32, 42, 51),),
        useMaterial3: true,
          //set screen background color
          scaffoldBackgroundColor: Color.fromARGB(255, 19, 25, 32),
          // scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
        ),
        appBarTheme: const AppBarTheme(
          // centerTitle: true,  //For show title in center
          // elevation: 1, // for Shadow
          titleTextStyle: TextStyle(
              color: Colors.white,
            fontSize: 21,
          ),
          iconTheme: IconThemeData(
            color: Colors.white
          ),
          backgroundColor: Color.fromARGB(255, 32, 42, 51),
        )
      ),
      // home: SignupScreen(),
      home: SplashScreen(),
      // home: const LoginScreen(),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

_initializeFirebase() async{
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  var result = await FlutterNotificationChannel().registerNotificationChannel(
    description: 'For scheduling channel notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
  );
  log('the result of notification------------ $result');

}