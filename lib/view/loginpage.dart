import 'dart:developer';
import 'dart:io';

import 'package:chitchat/ViewModel/constants/color.dart';
import 'package:chitchat/ViewModel/freture/Firebaseapi.dart';
import 'package:chitchat/view/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:resize/resize.dart';




class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {




  GoogleLogin() {


    _signInWithGoogle().then((user) async {

      if (user != null) {
        log('\nUser: ${user.user}');
        log('\nUserAdditionalInfo: ${user.additionalUserInfo}');

        if ((await FirebaseApi.userExists())) {
        Get.off(const home());
        } else {
          await FirebaseApi.createUser().then((value) {
            Get.off(const home());
          });
        }
      }
    });
  }

  /// creating credential
  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();


      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;


      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );


      return await FirebaseApi.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle: $e');
      Get.snackbar("", 'Something Went Wrong (Check Internet!)');
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {


    return Resize(
      builder: () {
        return Scaffold(

          appBar: AppBar(backgroundColor: backgroundColor,elevation: 0,
            systemOverlayStyle: const SystemUiOverlayStyle(

              statusBarColor: appBarColor,

              statusBarIconBrightness: Brightness.dark, // For Android (dark icons)

            ),


          ),

          //body
          body: Column(
              children: [


                ///google login button

            Expanded(flex: 3,
                  child: Image.asset('assets/bpg.png',height: Get.height*0.1
                    ,)),




             SizedBox( height: Get.height * .06,
                     width: Get.width * .9,
                     child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 223, 255, 187),
                            shape: const StadiumBorder(),
                            elevation: 1),
                        onPressed: () {
                          GoogleLogin();
                        },


                        icon: Image.asset('assets/google.png', height: Get.height * .03),


                        label: RichText(
                          text: const TextSpan(
                              style: TextStyle(color: Colors.black, fontSize: 16),
                              children: [
                                TextSpan(text: 'Login with '),
                                TextSpan(
                                    text: 'Google',
                                    style: TextStyle(fontWeight: FontWeight.w500)),
                              ]),
                        )),
                   ),
            SizedBox(height: Get.height*0.2,)

          ]),
        );
      }
    );
  }
}
