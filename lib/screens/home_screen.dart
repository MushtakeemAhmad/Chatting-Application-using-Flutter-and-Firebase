import 'dart:developer'; //For using Log
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/widgets/chat_user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../main.dart';

bool isSearching = false;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  //for storing all users
  List<ChatUser> list = [];
  // for storing search user
  final List<ChatUser> _searchList = [];
  //for storing search status
  //  bool _isSearching = false;
  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    //for updating user active status according to lifecycle events
    //resume --> active or online
    //pause ---> inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message:  $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    // gesture use for tap any where just close the keyboard
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(255, 32, 42, 51),
    ));
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      // willPop give back button functionality
      child: PopScope(
        onPopInvoked: (_) async {
          if (isSearching) {
            setState(() {
              isSearching = !isSearching;
            });
            //if search bar on then just close it and don't go back
            return Future.value(false);
          } else {
            // if search bar off then go back
            return Future.value(true);
          }
        },
        child: SafeArea(
          child: Scaffold(
            // use for appbar size
            appBar: AppBar(
              // leading: const Icon(CupertinoIcons.home),
              title: isSearching
                  ? TextField(
                      //Auto write bar on field
                      autofocus: true,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        // fontWeight: FontWeight.w500
                      ),
                      //when search text change then updated search list
                      onChanged: (val) {
                        //search logic
                        _searchList.clear();
                        for (var i in list) {
                          if (i.name
                                  .toLowerCase()
                                  .contains(val.toLowerCase()) ||
                              i.email
                                  .toLowerCase()
                                  .contains(val.toLowerCase())) {
                            _searchList.add(i);
                          }
                          setState(() {
                            _searchList;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Name or Email...',
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 155, 168, 184),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : Text('Chat Karo'),
              actions: [
                IconButton(
                    onPressed: () {
                      if(isSearching){
                        setState(() {
                          isSearching = !isSearching;
                        });
                      }
                      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomeScreen()));
                    },
                    icon: Icon(
                      Icons.home,
                      size: 28,
                    )),
                IconButton(
                    onPressed: () {
                      setState(() {
                        isSearching = !isSearching;
                      });
                    },
                    icon: Icon(
                      isSearching ? Icons.cancel_outlined : Icons.search,
                      size: 28,
                    )),
                IconButton(
                  onPressed: () {

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                                  user: APIs.me,
                                )));
                    if(isSearching){
                      setState(() {
                        isSearching = !isSearching;
                      });
                    }
                  },
                  icon: const Icon(
                    Icons.person,
                    size: 28,
                  ),
                ),
              ],
            ),
            //floating button to add new user
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: FloatingActionButton(
                onPressed: () {
                  _addUserDialog();
                },
                // backgroundColor: Color.fromARGB(255, 32, 42, 51),
                backgroundColor: Colors.blueGrey,
                child: const Icon(
                  Icons.chat,
                  color: Colors.white,
                ),
              ),
            ),
            body: StreamBuilder(
                stream: APIs.getMyUsersId(),
                //get id of only known user
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    //if data is loading
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Center(child: CircularProgressIndicator());

                    //if some or all data is loaded then show it
                    case ConnectionState.active:
                    case ConnectionState.done:
                      return StreamBuilder(
                        //function call for getting user data
                        stream: APIs.getAllUser(
                            snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                        //get only those user who's ids are provided
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            //if data is loading
                            case ConnectionState.waiting:
                            case ConnectionState.none:
                              // return Center(child: CircularProgressIndicator());
                            //if some or all data is loaded then show it
                            case ConnectionState.active:
                            case ConnectionState.done:
                              final data = snapshot.data?.docs;
                              list = data
                                      ?.map((e) => ChatUser.fromJson(e.data()))
                                      .toList() ??
                                  [];
                              if (list.isNotEmpty) {
                                return ListView.builder(
                                    itemCount: isSearching
                                        ? _searchList.length
                                        : list.length,
                                    physics: BouncingScrollPhysics(),
                                    padding:
                                        EdgeInsets.only(top: mq.height * 0.01),
                                    itemBuilder: (context, index) {
                                      return ChatUserCard(
                                        user: isSearching
                                            ? _searchList[index]
                                            : list[index],
                                      );
                                      // return Text('Name: ${list[index]}');
                                    });
                              } else {
                                return Center(
                                    child: Text(
                                  'No Connection Found',
                                  style: TextStyle(fontSize: 20),
                                ));
                              }
                          }
                        },
                        // builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {  },
                      );
                  }
                }),
          ),
        ),
      ),
    );
  }

  //for adding new chat user
  void _addUserDialog() {
    String email = '';
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: Color.fromARGB(255, 19, 25, 32),
              contentPadding:
                  EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 24),
              //title
              title: Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 26,
                    color: Color.fromARGB(255, 155, 168, 184),
                  ),
                  Text('  Add New User',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
              //content
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                initialValue: '',
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    hintText: 'Enter Email id',
                    hintStyle: TextStyle(color: Colors.white24),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.white))),
              ),
              //action
              actions: [
                // cancel button
                MaterialButton(
                  onPressed: () {
                    //for hiding bottom sheet
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                //Add button
                MaterialButton(
                  onPressed: () async {
                    //for hiding bottom sheet
                    Navigator.pop(context);
                    if (email.isNotEmpty)
                      await APIs.addChatUser(email).then((value) {
                        if (!value) {
                          Dialogs.showSnackBar(
                              context, 'User does not exists!');
                        }
                      });
                    // if(preMsg!=updatedmsg){
                    //   _isEdit = true;
                    // }
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ));
  }
}
