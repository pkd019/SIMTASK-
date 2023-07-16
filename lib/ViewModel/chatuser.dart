import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/ViewModel/constants/color.dart';
import 'package:chitchat/ViewModel/date.dart';
import 'package:chitchat/ViewModel/freture/Firebaseapi.dart';
import 'package:chitchat/model/usermodel.dart';
import 'package:chitchat/view/chattingpage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chatuserprofile.dart';
import 'message.dart';



/// making user card to show in home screen

class ChatUserCard extends StatefulWidget {
  final UserModel user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {

  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      margin: EdgeInsets.symmetric(horizontal: Get.width * .01, vertical: 4),

      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15),side: BorderSide(color: Colors.blue)),
      child: InkWell(
          onTap: () {
           Get.to( chattingpage(user: widget.user));
          },
          child: StreamBuilder(
            stream: FirebaseApi.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) _message = list[0];

              return ListTile(

                leading: InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_) => chatuserprofile(user: widget.user));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Get.height * .03),
                    child: CachedNetworkImage(
                      width: Get.height * .055,
                      height: Get.height * .055,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(Icons.person)),
                    ),
                  ),
                ),


                title: Text(widget.user.name),


                subtitle: Text(
                    _message != null
                        ? _message!.type == Type.image
                        ? 'image'
                        : _message!.msg
                        : widget.user.about,
                    maxLines: 1),


                trailing: _message == null
                    ? null
                    : _message!.read.isEmpty &&
                    _message!.fromId != FirebaseApi.user.uid
                    ?

                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                      color: Colors.blue.shade900,
                      borderRadius: BorderRadius.circular(10)),
                )
                    :

                Text(
                  Dateinfo.getLastMessageTime(
                      context: context, time: _message!.sent),

                ),
              );
            },
          )),
    );
  }
}
