
import 'package:chitchat/ViewModel/chatuserprofile.dart';
import 'package:chitchat/ViewModel/constants/color.dart';
import 'package:chitchat/ViewModel/date.dart';
import 'package:chitchat/ViewModel/freture/Firebaseapi.dart';
import 'package:chitchat/ViewModel/message.dart';
import 'package:chitchat/ViewModel/messagecard.dart';
import 'package:chitchat/model/usermodel.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resize/resize.dart';




class chattingpage extends StatefulWidget {
  final UserModel user;

  const chattingpage({Key? key, required this.user}) : super(key: key);

  @override
  State<chattingpage> createState()  => _chattingpageState();

}
class _chattingpageState extends State<chattingpage> {
  List<Message> _list = [];


  final _textController = TextEditingController();

  bool _showEmoji = false, _isUploading = false;


  @override
  Widget build(BuildContext context) {

    return Resize(
      builder: () {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: WillPopScope(

              onWillPop: () {
                if (_showEmoji) {
                  setState(() => _showEmoji = !_showEmoji);
                  return Future.value(false);
                } else {
                  return Future.value(true);
                }
              },
              child: Scaffold(
                //app bar
                appBar: AppBar(backgroundColor: appBarColor,
                  automaticallyImplyLeading: false,
                  flexibleSpace: _appBar(),
                ),



                //body
                body: Column(
                  children: [
                    Expanded(
                      child: StreamBuilder(
                        stream: FirebaseApi.getAllMessages(widget.user),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                          //if data is loading
                            case ConnectionState.waiting:
                            case ConnectionState.none:
                              return const SizedBox();

                          //if some or all data is loaded then show it
                            case ConnectionState.active:
                            case ConnectionState.done:
                              final data = snapshot.data?.docs;
                              _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                                  [];

                              if (_list.isNotEmpty) {
                                return ListView.builder(
                                    reverse: true,
                                    itemCount: _list.length,
                                    padding: EdgeInsets.only(top: Get.height * .01),
                                    physics: const BouncingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return MessageCard(message: _list[index]);
                                    });
                              } else {
                                return const Center(
                                  child: Text('',
                                      style: TextStyle(fontSize: 20)),
                                );
                              }
                          }
                        },
                      ),
                    ),


                    if (_isUploading)
                      const Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                              padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                              child: CircularProgressIndicator(strokeWidth: 2))),


                    _chatInput(),


                    if (_showEmoji)
                      SizedBox(
                        height: Get.height * .35,
                        child: EmojiPicker(
                          textEditingController: _textController,
                          config: Config(

                            columns: 8,
                            emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }


  Widget _appBar() {
    return InkWell(
        onTap: () {
          Get.to(chatuserprofile(user: widget.user));

        },
        child: StreamBuilder(
            stream: FirebaseApi.getUserInfo(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => UserModel.fromJson(e.data())).toList() ?? [];

              return Row(
                children: [
                  //back button
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon:
                      const Icon(Icons.arrow_back)),

                  //user profile picture
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Get.height * .03),
                    child: CachedNetworkImage(
                      width: Get.height * .05,
                      height: Get.height * .05,
                      imageUrl:
                      list.isNotEmpty ? list[0].image : widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(Icons.person)),
                    ),
                  ),

                  //for adding some space
                  const SizedBox(width: 10),


                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(list.isNotEmpty ? list[0].name : widget.user.name,
                          style: const TextStyle(
                              fontSize: 16,

                              fontWeight: FontWeight.w500)),


                      const SizedBox(height: 2),


                      Text(
                          list.isNotEmpty
                              ? list[0].is_online
                              ? 'Online'
                              : Dateinfo.getLastSeen(
                              context: context,
                              lastActive: list[0].last_seen)
                              : Dateinfo.getLastSeen(
                              context: context,
                              lastActive:widget.user.last_seen),
                          style: const TextStyle(
                              fontSize: 13)),
                    ],
                  )
                ],
              );
            }));
  }


  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: Get.height * .01, horizontal: Get.width * .025),
      child: Row(
        children: [

          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  //emoji button
                  IconButton(
                      onPressed: () {
     FocusManager.instance.rootScope.requestFocus();
                        setState(() => _showEmoji = !_showEmoji);
                      },
                      icon: const Icon(Icons.emoji_emotions,
                         size: 25)),

                  Expanded(
                      child: TextField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onTap: () {
                          if (_showEmoji) setState(() => _showEmoji = !_showEmoji);
                        },
                        decoration: const InputDecoration(
                            hintText: 'your message',

                            border: InputBorder.none),
                      )),


                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Picking multiple images
                        final List<XFile> images =
                        await picker.pickMultiImage(imageQuality: 70);

                        // uploading & sending image one by one
                        for (var i in images) {
                          log('Image Path: ${i.path}');
                          setState(() => _isUploading = true);
                          await FirebaseApi.sendChatImage(widget.user, File(i.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: const Icon(Icons.image,
                          size: 26)),

                  //take image from camera button
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() => _isUploading = true);

                          await FirebaseApi.sendChatImage(
                              widget.user, File(image.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: const Icon(Icons.camera_alt_rounded,
                          size: 26)),


                  SizedBox(width: Get.width * .02),
                ],
              ),
            ),
          ),


          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                if (_list.isEmpty) {

                  FirebaseApi.sendFirstMessage(
                  widget.user, _textController.text, Type.text);
                } else {

                  FirebaseApi.sendMessage(
                    widget.user, _textController.text, Type.text);
                }
                _textController.text = '';
              }
            },
            minWidth: 0,
            padding:
            const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            color: tabColor,
            child: const Icon(Icons.send, color: Colors.white, size: 28),
          )
        ],
      ),
    );
  }}

