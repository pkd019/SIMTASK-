import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/ViewModel/constants/color.dart';
import 'package:chitchat/ViewModel/freture/Firebaseapi.dart';

import 'package:chitchat/model/usermodel.dart';

import 'package:chitchat/view/loginpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resize/resize.dart';


class Profile_screen extends StatefulWidget {
  const Profile_screen({
    Key? key, required this.user,
  }) : super(key: key);

///taking user detail  from firebase
  final UserModel user;
  @override
  State<Profile_screen> createState() => _Profile_screen();
}

class _Profile_screen extends State<Profile_screen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return Resize(
      builder: () {
        return GestureDetector(

          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            //app bar
              appBar: AppBar(backgroundColor: appBarColor,
                  title: const Text('Profile Screen')),

     /// logout
              floatingActionButton: SizedBox(width: Get.width*0.14,height: Get.height * .08,
                child: Padding(

                  padding: const EdgeInsets.only(bottom: 20),
                  child: FloatingActionButton(
                    backgroundColor: Colors.red.shade600,
                      onPressed: () async {
                       Get.snackbar("",'logout sucessfully');

                        await FirebaseApi.updateActiveStatus(false);


                        await FirebaseApi.auth.signOut().then((value) async {
                          await GoogleSignIn().signOut().then((value) {

                            FirebaseApi.auth = FirebaseAuth.instance;


                           Get.offAll( const LoginScreen());
                          });
                        });
                      },
                     child:  const Icon(Icons.power_settings_new_outlined)),
                ),
              ),

              ///profile section
              body: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Get.width * .05),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // for adding some space
                        SizedBox(width: Get.width, height: Get.height * .03),

                        //user profile picture
                        Stack(
                          children: [

                            _image != null
                                ?


                            ClipRRect(
                                borderRadius:
                                BorderRadius.circular(Get.height * .1),
                                child: Image.file(File(_image!),
                                    width: Get.height * .2,
                                    height: Get.height * .2,
                                    fit: BoxFit.cover))
                                :


                            ClipRRect(
                              borderRadius:
                              BorderRadius.circular(Get.height * .1),
                              child: CachedNetworkImage(
                                width: Get.height * .2,
                                height: Get.height * .2,
                                fit: BoxFit.cover,
                                imageUrl: widget.user.image,
                                errorWidget: (context, url, error) =>
                                const CircleAvatar(
                                    child: Icon(Icons.person)),
                              ),
                            ),

    ///photo edit
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: MaterialButton(
                                elevation: 1,
                                onPressed: () {
                                  _showBottomSheet();
                                },
                                shape: const CircleBorder(),
                                color: Colors.white,
                                child: const Icon(Icons.edit, color: Colors.blue),
                              ),
                            )
                          ],
                        ),


                        SizedBox(height: Get.height * .03),


                        Text(widget.user.email,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16)),


                        SizedBox(height: Get.height * .05),


                        TextFormField(
                          initialValue: widget.user.name,
                          onSaved: (val) => FirebaseApi.myself.name = val ?? '',
                          validator: (val) => val != null && val.isNotEmpty
                              ? null
                              : 'Required Field',
                          decoration: InputDecoration(
                              prefixIcon:
                              const Icon(Icons.person),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              hintText: 'eg. Ms Dhoni',
                              label: const Text('Name')),
                        ),


                        SizedBox(height: Get.height * .02),


                        TextFormField(
                          initialValue: widget.user.about,
                          onSaved: (val) => FirebaseApi.myself.about = val ?? '',
                          validator: (val) => val != null && val.isNotEmpty
                              ? null
                              : 'Required Field',
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.info_outline,
                                 ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              hintText: 'eg. Welcome to Chit Chat',
                              label: const Text('About')),
                        ),


                        SizedBox(height: Get.height * .05),


                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              minimumSize: Size(Get.width * .3, Get.height * .06)),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              FirebaseApi.updateUserInfo().then((value) {
                               Get.snackbar(
                                  "", 'Profile Updated Successfully!');
                              });
                            }
                          },


                           child:const Text('SAVE', style: TextStyle(fontSize: 20)),
                        )
                      ],
                    ),
                  ),
                ),
              )),
        );
      }
    );
  }

  ///to get photo from device


  void _showBottomSheet() {
    Get.bottomSheet(
      ListView(
      shrinkWrap: true,
      padding:
      EdgeInsets.only(top: Get.height * .03, bottom: Get.height * .05),
      children: [

        const Text('Pick Profile Picture',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),


        SizedBox(height: Get.height * .02),


        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            ElevatedButton(
                style: ElevatedButton.styleFrom(

                    shape: const CircleBorder(),
                    fixedSize: Size(Get.width * .3, Get.height * .15)),
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();


                  final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery, imageQuality: 80);
                  if (image != null) {
                    log('Image Path: ${image.path}');
                    setState(() {
                      _image = image.path;
                    });

                    FirebaseApi.updateProfilePicture(File(_image!));

                    Get.back();
                  }
                },
                child: const Icon(Icons.photo,size: 40,)),


            ElevatedButton(
                style: ElevatedButton.styleFrom(

                    shape: const CircleBorder(),
                    fixedSize: Size(Get.width * .3, Get.height * .15)),
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();


                  final XFile? image = await picker.pickImage(
                      source: ImageSource.camera, imageQuality: 80);
                  if (image != null) {
                    log('Image Path: ${image.path}');
                    setState(() {
                      _image = image.path;
                    });

                    FirebaseApi.updateProfilePicture(File(_image!));

                    Get.back();
                  }
                },
                child: const Icon(Icons.camera_alt,size: 40,)),
          ],
        )
      ],
    ),

    );
  }
}
