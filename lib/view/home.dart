
import 'dart:developer';
import 'package:chitchat/ViewModel/chatuser.dart';
import 'package:chitchat/ViewModel/constants/color.dart';
import 'package:chitchat/ViewModel/freture/Firebaseapi.dart';
import 'package:chitchat/model/usermodel.dart';
import 'package:chitchat/view/profilepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:resize/resize.dart';
class home extends StatefulWidget {
  const home({Key? key}) : super(key: key);

  @override
  State<home> createState() => _homeState();
}


class _homeState extends State<home> {

  List<UserModel> _list = [];

  List<UserModel> search = [];

  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    FirebaseApi.getSelfInfo();

    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (FirebaseApi.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          FirebaseApi.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          FirebaseApi.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Resize(
      builder: (){
        return GestureDetector(

          onTap: () => FocusScope.of(context).unfocus(),
          child: WillPopScope(

            onWillPop: () {
              if (_isSearching) {
                setState(() {
                  _isSearching = !_isSearching;
                });
                return Future.value(false);
              } else {
                return Future.value(true);
              }
            },
            child: Scaffold(

              /// home - Searching - Profile
              //app bar
              appBar: AppBar(backgroundColor: appBarColor,systemOverlayStyle: const SystemUiOverlayStyle(

                statusBarColor: appBarColor,
                statusBarIconBrightness: Brightness.dark, // For Android (dark icons)

              ),
                leading: const Icon(Icons.home),
                title: _isSearching
                    ? TextField(
                  decoration: const InputDecoration(
                      border: InputBorder.none, hintText: 'Name, Email, ...'),
                  autofocus: true,
                  style: const TextStyle(fontSize: 17, letterSpacing: 0.5),

                  onChanged: (val) {

                    search.clear();

                    for (var i in _list) {
                      if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                          i.email.toLowerCase().contains(val.toLowerCase())) {
                        search.add(i);
                        setState(() {
                          search;
                        });
                      }
                    }
                  },
                )
                    : const Text('Chit Chat'),
                actions: [

                  IconButton(
                      onPressed: () {
                        setState(() {
                          _isSearching = !_isSearching;
                        });
                      },
                      icon: Icon(_isSearching
                          ? Icons.clear_rounded
                          : Icons.search)),


                  IconButton(
                      onPressed: () {
                       Get.to(Profile_screen(user: FirebaseApi.myself,));
                      },
                      icon: const Icon(Icons.person))
                ],
              ),


              floatingActionButton: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FloatingActionButton(
                    onPressed: () {
                      _addChatUserDialog();
                    },backgroundColor: Colors.white,
                    child: const Icon(Icons.add_comment_rounded),
              ),
),


              /// showing users
              //body
              body: StreamBuilder(
                stream: FirebaseApi.getMyUsersId(),


                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {

                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(child: CircularProgressIndicator());


                    case ConnectionState.active:
                    case ConnectionState.done:
                      return StreamBuilder(
                        stream: FirebaseApi.getAllUsers(
                            snapshot.data?.docs.map((e) => e.id).toList() ?? []),


                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {

                            case ConnectionState.waiting:
                            case ConnectionState.none:



                            case ConnectionState.active:
                            case ConnectionState.done:
                              final data = snapshot.data?.docs;
                              _list = data
                                  ?.map((e) => UserModel.fromJson(e.data()))
                                  .toList() ??
                                  [];

                              if (_list.isNotEmpty) {
                                return ListView.builder(
                                    itemCount: _isSearching
                                        ? search.length
                                        : _list.length,
                                    padding: EdgeInsets.only(top: Get.height * .01),
                                    physics: const BouncingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return ChatUserCard(
                                          user: _isSearching
                                              ? search[index]
                                              : _list[index]);
                                    });
                              } else {
                                return const Center(
                                  child: Text('No Connections Found!',
                                      style: TextStyle(fontSize: 20)),
                                );
                              }
                          }
                        },
                      );
                  }
                },
              ),
            ),
          ),
        );
      }
    );
  }

  /// add user to chat

  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(backgroundColor:  Colors.blue.shade900,
          contentPadding: const EdgeInsets.only(
              left: 24, right: 24, top: 20, bottom: 10),

          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),

          //title
          title: const Row(
            children: [
              Icon(
                Icons.person_add,
              color: Colors.white,
                size: 28,
              ),
              Text('  Add User')
            ],
          ),

          //content
          content: TextFormField(
            maxLines: null,
            onChanged: (value) => email = value,
            decoration: InputDecoration(
                hintText: 'Email Id',
                prefixIcon: const Icon(Icons.email, color: Colors.white),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),


          actions: [

            MaterialButton(
                onPressed: () {

                 Get.back();
                },
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.white,fontSize: 16))),

            //add button
            MaterialButton(
                onPressed: () async {

                Get.back();
                  if (email.isNotEmpty) {
                    await FirebaseApi.addChatUser(email).then((value) {
                      if (!value) {
                        Get.snackbar('error','User does not Exists!'
                            );
                      }
                    });
                  }
                },
                child: const Text(
                  'Add',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ))
          ],
        ));
  }
 }
