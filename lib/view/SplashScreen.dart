import 'dart:developer';
import 'package:chitchat/ViewModel/constants/color.dart';
import 'package:chitchat/ViewModel/freture/Firebaseapi.dart';
import 'package:chitchat/view/home.dart';
import 'package:chitchat/view/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:resize/resize.dart';





class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {

      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: appBarColor,
          statusBarColor: appBarColor));

      if (FirebaseApi.auth.currentUser != null) {
        log('\nUser: ${FirebaseApi.auth.currentUser}');

      Get.off(const home());
      } else {
        Get.off( LoginScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {



    return Resize(
      builder: () {
        return Scaffold(
          appBar: AppBar(backgroundColor: backgroundColor,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: backgroundColor,
              statusBarIconBrightness: Brightness.dark, // For Android (dark icons)

            ),
            elevation: 0,
          ),
          //body
          body: Stack(children: [

            Positioned(
                top: Get.height * .15,
                right: Get.width * .25,
                width: Get.width * .5,
                child: Image.asset('assets/splash.png')),


          ]),
        );
      }
    );
  }
}
