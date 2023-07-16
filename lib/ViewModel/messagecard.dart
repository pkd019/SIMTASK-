import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/ViewModel/constants/color.dart';
import 'package:chitchat/ViewModel/date.dart';
import 'package:chitchat/ViewModel/freture/Firebaseapi.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'message.dart';

/// showing the send and recieve msg  and decorate them

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = FirebaseApi.user.uid == widget.message.fromId;
    return InkWell(
        onLongPress: () {
          _showBottomSheet(isMe);
        },
        child: isMe ? sendMessage() : recieveMessage());
  }


  Widget recieveMessage() {
    //update last read message if sender and receiver are different
    if (widget.message.read.isEmpty) {
      FirebaseApi.updateMessageReadStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? Get.width * .03
                : Get.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: Get.width * .04, vertical: Get.height * .01),
            decoration: BoxDecoration(
                color: messageColor,
                border: Border.all(color: tabColor),

                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: widget.message.type == Type.text
                ?

                Text(
                  widget.message.msg,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                )
                :
            ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  imageUrl: widget.message.msg,
                  placeholder: (context, url) => const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.image, size: 70),
                ),
              ),
            ),
          ),



             Padding(
    padding: EdgeInsets.only(right: Get.width * .04),
    child: Text(
      Dateinfo.getFormattedTime(
    context: context, time: widget.message.sent),
    style: const TextStyle(fontSize: 13),
    ),
    ),
      ],
    );
  }


  Widget sendMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Row(
          children: [

            SizedBox(width: Get.width * .04),


            if (widget.message.read.isNotEmpty)
              const Icon(Icons.done_all_rounded, size: 20,color: Colors.blue,),


            const SizedBox(width: 2),


            Text(
              Dateinfo.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, ),
            ),
          ],
        ),


        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? Get.width * .03
                : Get.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: Get.width * .04, vertical: Get.height * .01),
            decoration: BoxDecoration(
                color: senderMessageColor,
                border: Border.all(color: senderMessageColor),

                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child: widget.message.type == Type.text
                ?
                Text(
              widget.message.msg,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            )
                :

            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: widget.message.msg,
                placeholder: (context, url) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) =>
                const Icon(Icons.image, size: 70),
              ),
            ),
          ),
        ),
      ],
    );
  }


  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        backgroundColor: Colors.white70,
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [

              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: Get.height * .015, horizontal: Get.width * .4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),

              widget.message.type == Type.text
                  ?

              _OptionItem(
                  icon: const Icon(Icons.copy_all_rounded,
                      color: Colors.blue, size: 26),
                  name: 'Copy Text',
                  onTap: () async {
                    await Clipboard.setData(
                        ClipboardData(text: widget.message.msg))
                        .then((value) {
                      //for hiding bottom sheet
                      Navigator.pop(context);

                      Get.snackbar("", 'Text Copied!');
                    });
                  })
                  :

              _OptionItem(
                  icon: const Icon(Icons.download_rounded,
                      color: Colors.blue, size: 26),
                  name: 'Save Image',
                  onTap: () async {
                    try {
                      log('Image Url: ${widget.message.msg}');
                      await GallerySaver.saveImage(widget.message.msg,
                          albumName: 'Chit Chat')
                          .then((success) {
                      Get.back();
                        if (success != null && success) {
                         Get.snackbar(
                              "", 'Image Successfully Saved!');
                        }
                      });
                    } catch (e) {
                      log('ErrorWhileSavingImg: $e');
                    }
                  }),

              if (isMe)
                Divider(
                  color: Colors.black54,
                  endIndent: Get.width * .04,
                  indent: Get.width * .04,
                ),


              if (widget.message.type == Type.text && isMe)
                _OptionItem(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 26),
                    name: 'Edit Message',
                    onTap: () {
                    Get.back();

                      _showMessageUpdateDialog();
                    }),

              //delete option
              if (isMe)
                _OptionItem(
                    icon: const Icon(Icons.delete_forever,
                        color: Colors.red, size: 26),
                    name: 'Delete Message',
                    onTap: () async {
                      await FirebaseApi.deleteMessage(widget.message).then((value) {
                        //for hiding bottom sheet
                        Navigator.pop(context);
                      });
                    }),


              Divider(
                color: Colors.black54,
                endIndent: Get.width * .04,
                indent: Get.width * .04,
              ),


              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                  name:
                  'Sent At: ${Dateinfo.getMessageTime(context: context, time: widget.message.sent)}',
                  onTap: () {}),


              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.green),
                  name: widget.message.read.isEmpty
                      ? 'Read At: Not seen yet'
                      : 'Read At: ${Dateinfo.getMessageTime(context: context, time: widget.message.read)}',
                  onTap: () {}),
            ],
          );
        });
  }

  //dialog for updating message content
  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          contentPadding: const EdgeInsets.only(
              left: 24, right: 24, top: 20, bottom: 10),

          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),

          //title
          title: const Row(
            children: [
              Icon(
                Icons.message,
                color: Colors.blue,
                size: 28,
              ),
              Text(' Update Message')
            ],
          ),

          //content
          content: TextFormField(
            initialValue: updatedMsg,
            maxLines: null,
            onChanged: (value) => updatedMsg = value,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),

          //actions
          actions: [
            //cancel button
            MaterialButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                )),


            MaterialButton(
                onPressed: () {

                 Get.back();
                  FirebaseApi.editMessage(widget.message, updatedMsg);
                },
                child: const Text(
                  'Update',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ))
          ],
        ));
  }
}


class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.only(
              left: Get.width * .05,
              top: Get.height * .015,
              bottom: Get.height * .015),
          child: Row(children: [
            icon,
            Flexible(
                child: Text('    $name',
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        letterSpacing: 0.5)))
          ]),
        ));
  }

}