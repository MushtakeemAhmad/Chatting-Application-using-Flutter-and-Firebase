import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/view_profile_screen.dart';
import 'package:chat_app/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/message.dart';

import 'package:flutter/foundation.dart' as foundation;

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // for storing all messages
  List<Message> _list = [];

  //for toggle emoji keyboard, //for show emoji icon or keyboard icon,
  // for checking if image is uploading or uploaded
  bool _showEmoji = false, _emojiIcon = false, _isUploading = false;

  //for sending button or text field
  final _textController = TextEditingController();

  // Defining the focus node
  late FocusNode focusNodeKeyboard;

//for toggle
//   final ValueNotifier<bool> isSwitched = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isSwitched = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isSwitchedOff = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isSwitchedOn = ValueNotifier<bool>(false);
  @override
  void initState() {
    super.initState();

    // To manage the lifecycle, creating focus nodes in
    // the initState method
    focusNodeKeyboard = FocusNode();
  }

  // Called when the object is removed
  // from the tree permanently
  @override
  void dispose() {
    // Clean up the focus nodes
    // when the form is disposed
    focusNodeKeyboard.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(255, 32, 42, 51),
    ));

    //for placed our widget at topBar
    return GestureDetector(
      onTap: () => {
        FocusScope.of(context).unfocus(),

        // toggleSwitch(_showEmoji),
        // toggleSwitch(_emojiIcon),
        // switchOff(),
        // _showEmoji = isSwitchedOff.value,
        // _emojiIcon = isSwitchedOff.value,
        if(_emojiIcon){
          setState(() {
            _showEmoji = false;
            _emojiIcon = false;
          })
        }

      },
      child: SafeArea(
        child: WillPopScope(
          //if emoji shown and press back button
          // then just close emoji keyboard otherwise normal back
          onWillPop: () {
            if (_showEmoji) {
              // toggleSwitch(_showEmoji);
              // _showEmoji = isSwitched.value;
              // switchOff(_emojiIcon);
              // _emojiIcon = isSwitchedOff.value;

              setState(() {
                _showEmoji = !_showEmoji;
                _emojiIcon = false;
              });

              //if search bar on then just close it and don't go back
              return Future.value(false);
            } else {
              // if search bar off then go back
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              //for remove back button icon
              automaticallyImplyLeading: false,
              // own appBar design
              flexibleSpace: _appBar(),
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    //function call for getting user messages
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        //if data is loading
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return SizedBox();
                        // return Center(child: CircularProgressIndicator());

                        //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          // log('Data: ${jsonEncode(data![0].data())}');
                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                reverse: true,
                                itemCount: _list.length,
                                physics: BouncingScrollPhysics(),
                                padding: EdgeInsets.only(top: mq.height * 0.01),
                                itemBuilder: (context, index) {
                                  // return Text('Message: ${_list[index]}',style: TextStyle(
                                  //   color: Colors.white
                                  // ),);
                                  return MessageCard(
                                    message: _list[index],
                                  );
                                });
                          } else {
                            return Center(
                                child: Text(
                              'say Hey! 👋',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 20,
                              ),
                            ));
                          }
                      }
                    },
                    // builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {  },
                  ),
                ),

                //progress indicator for showing uploading image
                if (_isUploading)
                  Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: mq.width * .08,
                            vertical: mq.height * .02),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )),

                _chatInput(),
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * 0.34,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        columns: 7,
                        emojiSizeMax: 32 *
                            (foundation.defaultTargetPlatform ==
                                    TargetPlatform.iOS
                                ? 1.30
                                : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
                        verticalSpacing: 0,
                        horizontalSpacing: 0,
                        gridPadding: EdgeInsets.zero,
                        initCategory: Category.SMILEYS,
                        bgColor: Color.fromARGB(255, 32, 42, 51),
                        // indicatorColor: Colors.blue,
                        // iconColor: Colors.grey,
                        // iconColorSelected: Colors.blue,
                        // backspaceColor: Colors.blue,
                        // skinToneDialogBgColor: Colors.white,
                        // skinToneIndicatorColor: Colors.grey,
                        enableSkinTones: true,
                        recentTabBehavior: RecentTabBehavior.RECENT,
                        // recentsLimit: 28,
                        noRecents: const Text(
                          'No Recents',
                          style: TextStyle(fontSize: 20, color: Colors.white38),
                          textAlign: TextAlign.center,
                        ), // Needs to be const Widget
                        loadingIndicator:
                            const SizedBox.shrink(), // Needs to be const Widget
                        tabIndicatorAnimDuration: kTabScrollDuration,
                        categoryIcons: const CategoryIcons(),
                        buttonMode: ButtonMode.MATERIAL,
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return Column(
      children: [
        SizedBox(
          height: mq.height * 0.005,
        ),
        InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ViewProfileScreen(user: widget.user)));
          },
          child: Center(
            child: StreamBuilder(
                stream: APIs.getUserInfo(widget.user),
                builder: (context, snapshot) {
                  final data = snapshot.data?.docs;
                  final list =
                      data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                          [];

                  return Row(
                    children: [
                      //back to previous screen
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                          )),
                      //show image icon
                      ClipRRect(
                        //for circular image(clipRRect give borderRadius functionality)
                        borderRadius:
                            BorderRadius.circular((mq.height * 0.055) / 2),
                        //for give placeHolder and error
                        child: CachedNetworkImage(
                          //set image height and width
                          width: mq.height * 0.055,
                          height: mq.height * 0.055,
                          imageUrl: list.isNotEmpty
                              ? list[0].image
                              : widget.user.image,
                          //show loadingBar till then image load
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          // if image not show then by default image
                          errorWidget: (context, url, error) => CircleAvatar(
                              child: Image.asset('assets/images/avatar.png')),
                        ),
                      ),
                      SizedBox(
                        width: mq.width * 0.02,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //name of user
                          Text(
                            list.isNotEmpty ? list[0].name : widget.user.name,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w500),
                          ),
                          //last seen of user
                          Text(
                            list.isNotEmpty
                                ? list[0].isOnline
                                    ? 'Online'
                                    : MyDateUtil.getLastActiveTime(
                                        context: context,
                                        lastActive: list[0].lastActive)
                                : MyDateUtil.getLastActiveTime(
                                    context: context,
                                    lastActive: widget.user.lastActive),
                            style: TextStyle(
                                color: Color.fromARGB(255, 155, 168, 184)),
                          ),
                        ],
                      )
                    ],
                  );
                }),
          ),
        ),
      ],
    );
  }

  //bottomBar for chat input
  Widget _chatInput() {
    return Row(
      children: [
        SizedBox(width: mq.width * 0.01),
        //take max width input field
        Expanded(
          child: Card(
            color: Color.fromARGB(255, 32, 42, 51),
            child: Row(
              children: [
                //emoji icon in text field
                IconButton(
                    onPressed: () {
                      if (!_emojiIcon) {
                        FocusScope.of(context).unfocus();
                        // switchOn();
                        setState(() {
                          _showEmoji = true;
                          _emojiIcon = true;
                        });

                      } else {
                        // switchOff();
                        setState(() {
                          _showEmoji = false;
                          _emojiIcon = false;
                          focusNodeKeyboard.requestFocus();
                          // FocusScope.of(context).
                        });
                      }
                    },
                    icon: _emojiIcon
                        ? Icon(
                            Icons.keyboard,
                            color: Color.fromARGB(255, 155, 168, 184),
                            size: 28,
                          )
                        : Icon(
                            Icons.emoji_emotions,
                            color: Color.fromARGB(255, 155, 168, 184),
                            size: 28,
                          )),

                Expanded(
                    // text field or message
                    child: TextField(
                  focusNode: focusNodeKeyboard,
                  onTap: () {
                    // switchOff();
                    _showEmoji = false;
                    _emojiIcon = false;
                  },
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 5,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                      hintText: 'Type Here...',
                      hintStyle: TextStyle(
                          color: Color.fromARGB(255, 155, 168, 184),
                          fontWeight: FontWeight.w400),
                      border: InputBorder.none),
                )),

                //image icons in text field
                IconButton(
                    onPressed: () async {
                      //pick image from user
                      final ImagePicker picker = ImagePicker();
                      // Pick multiple images from gallery
                      final List<XFile> images =
                          await picker.pickMultiImage(imageQuality: 70);
                      //uploading image in firebase one by one
                      for (var i in images) {
                        log('Image Path: ${i.path}');
                        setState(() => _isUploading = true);
                        //function for update image
                        await APIs.sendChatImage(widget.user, File(i.path));
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: Icon(
                      Icons.image,
                      color: Color.fromARGB(255, 155, 168, 184),
                      size: 28,
                    )),

                //camera icons in text field
                IconButton(
                    onPressed: () async {
                      //pick image from user
                      final ImagePicker picker = ImagePicker();
                      // Pick an image in camera
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 70);
                      if (image != null) {
                        log('Image Path: ${image.path}');
                        setState(() => _isUploading = true);
                        //function for update image
                        await APIs.sendChatImage(widget.user, File(image.path));
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: Icon(
                      Icons.camera_alt_outlined,
                      color: Color.fromARGB(255, 155, 168, 184),
                      size: 28,
                    )),
              ],
            ),
          ),
        ),

        //send button
        MaterialButton(
          onPressed: () {
            // trim fun remove start and end whitespace
            String text = _textController.text.trim();
            if (text.isNotEmpty) {
              if (_list.isEmpty) {
                //on first message- add user to my_user collection of chat user
                APIs.sendFirstMessage(widget.user, text, Type.text);
                _textController.clear();
              } else {
                // send a message
                APIs.sendMessage(widget.user, text, Type.text);
                print(_textController.text);
                _textController.clear();
              }
            } else {
              _textController.clear();
            }
          },
          // padding: EdgeInsets.only(top: 10,bottom: 10,left: 10,right: 5),
          padding: EdgeInsets.all(10),
          minWidth: 0,
          shape: CircleBorder(),
          color: Colors.blueGrey,
          child: Icon(
            Icons.send,
            color: Colors.white,
            size: 26,
          ),
        ),
        SizedBox(width: mq.width * 0.02),

        /**
        ElevatedButton(
          onPressed: () {
            // Call the function to change the value
            toggleSwitch(isSwitched.value);
            log('---------${isSwitched.value}');
          },
          child: Text('Toggle Switch'),
        ),
            **/
      ],
    );
  }

  // Function to change the boolean value
  void switchOff() {
    isSwitchedOff.value = false;
  }

  void switchOn() {
    isSwitchedOn.value = true;
  }

  void toggleSwitch(bool newValue) {
    isSwitched.value = !newValue;
  }
}
