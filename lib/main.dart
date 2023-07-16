
import 'package:chitchat/ViewModel/constants/color.dart';
import 'package:chitchat/view/SplashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  await Firebase.initializeApp();

  runApp( const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'Chit Chat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(

        scaffoldBackgroundColor: backgroundColor,

        ),
        home: const SplashScreen());
  }
}
