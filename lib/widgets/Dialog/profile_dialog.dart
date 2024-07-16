import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/view_profile_screen.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});
  final ChatUser user;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(14),
      backgroundColor: Colors.blueGrey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      //for sizing alert box
      content: SizedBox(
        width: mq.width * .6,
        height: mq.height * .36,
        child: Stack(
          children: [
            //for profile image
            Align(
              alignment: Alignment.topCenter,
              child: ClipRRect(
                //for circular image(clipRRect give borderRadius functionality)
                borderRadius: BorderRadius.circular((mq.height * 0.01)),
                //for give placeHolder and error
                child: CachedNetworkImage(
                  //set image height and width
                  width: mq.width * 0.63,
                  height: mq.height * 0.29,
                  fit: BoxFit.fill,
                  imageUrl: user.image,
                  //show loadingBar till then image load
                  placeholder: (context, url) => CircularProgressIndicator(),
                  // if image not show then by default image
                  errorWidget: (context, url, error) => CircleAvatar(
                      child: Image.asset('assets/images/avatar.png')),
                ),
              ),
            ),
            //for user name
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      user.name,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                  //for icon
                  Row(
                    children: [
                      MaterialButton(
                        padding: EdgeInsets.zero,
                        minWidth: 0,
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ChatScreen(user: user)));
                        },
                        child: Icon(
                          Icons.chat,
                          size: 35,
                          color: Color.fromARGB(255, 32, 42, 51),
                        ),
                      ),
                      MaterialButton(
                        padding: EdgeInsets.zero,
                        minWidth: 0,
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ViewProfileScreen(user: user)));
                        },
                        child: Icon(
                          Icons.info_outline,
                          size: 35,
                          color: Color.fromARGB(255, 32, 42, 51),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
