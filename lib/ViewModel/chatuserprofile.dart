import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/ViewModel/constants/color.dart';
import 'package:chitchat/model/usermodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


/// showing user profile

class chatuserprofile extends StatefulWidget {
  final UserModel user;

  const chatuserprofile({super.key, required this.user});

  @override
  State<chatuserprofile> createState() => _chatuserprofileState();
}

class _chatuserprofileState extends State<chatuserprofile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(

          appBar: AppBar(title: Text(widget.user.name),backgroundColor: appBarColor,),


          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: Get.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [

                  SizedBox(width: Get.width, height: Get.height * .03),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(Get.height * .1),
                    child: CachedNetworkImage(
                      width: Get.height * .2,
                      height: Get.height * .2,
                      fit: BoxFit.cover,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),


                  SizedBox(height: Get.height * .03),


                  Text(widget.user.email,
                      style:
                      const TextStyle( fontSize: 16)),


                  SizedBox(height: Get.height * .02),


                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'About: ',
                        style: TextStyle(

                            fontWeight: FontWeight.w500,
                            fontSize: 15),
                      ),
                      Text(widget.user.about,
                          style: const TextStyle(
                             fontSize: 15)),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
