import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/widgets/Dialog/profile_dialog.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../screens/home_screen.dart';

class ChatUserCard extends StatefulWidget {
  // for taking user all data
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  //last message info(if null -> no message)
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        isSearching = false;
        //Goto Chat Screen
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)));
      },
      child: StreamBuilder(
        stream: APIs.getLastMessages(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list =
              data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
          if (list.isNotEmpty) {
            _message = list[0];
          }

          return ListTile(
            //Profile Picture
            leading: InkWell(
              onTap: ()=>{
                showDialog(context: context, builder: (_)=>ProfileDialog(user: widget.user,))
              },
              child: Stack(
                children: [

                  ClipRRect(
                    //for circular image(clipRRect give borderRadius functionality)
                    borderRadius: BorderRadius.circular((mq.height * 0.055) / 2),
                    //for give placeHolder and error
                    child: CachedNetworkImage(
                      //set image height and width
                      width: mq.height * 0.055,
                      height: mq.height * 0.055,
                      imageUrl: widget.user.image,
                      //show loadingBar till then image load
                      placeholder: (context, url) => CircularProgressIndicator(),
                      // if image not show then by default image
                      errorWidget: (context, url, error) => CircleAvatar(
                          child: Image.asset('assets/images/avatar.png')),
                    ),
                  ),
                  //if user online then show a green dot
                  Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: widget.user.isOnline?Colors.green:Colors.transparent
                    ),
                  ),
                ],
              )
            ),

            //User Name
            title: Text(
              widget.user.name,
              style: TextStyle(color: Colors.white),
            ),

            //Last Message
            subtitle: Text(
              _message != null
                  ? _message!.type == Type.image
                      ? "image"
                      : _message!.msg
                  : widget.user.about,
              style: TextStyle(color: Color.fromARGB(255, 155, 168, 184)),
              maxLines: 1,
            ),

            //Message Time
            // trailing: Text('3:19 PM',style: TextStyle(color: Colors.black54),),
            //last message time show
            trailing: _message == null
                ? null //if no msg then nothing show
                : _message!.read.isEmpty && _message!.fromId != APIs.user.uid
                    ?
                    //show for unread message
                    Container(
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )
                    //
                    : Text(
                        MyDateUtil.getLastMessageTime(
                            context: context, time: _message!.send),
                        style: TextStyle(
                            color: Color.fromARGB(255, 155, 168, 184))),
          );
        },
      ),
    );
  }
}
