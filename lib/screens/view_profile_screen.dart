
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../main.dart';
import '../models/chat_user.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({super.key, required this.user});

  @override
  State<StatefulWidget> createState() => _ViewProfileScreen();
}

// on tap of the chat screen appbar view profile screen
class _ViewProfileScreen extends State<ViewProfileScreen> {

  //storing latitude and longitude for location
  String coordinates = 'NO location found';
  //storing address
  String address = 'No address found';
  //showing add or not
  bool scanning = false;

  //for testing
  // ValueNotifier<bool> isToggled = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isSwitched = ValueNotifier<bool>(false);



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for removing keyboard from screen on tap  screen anywhere
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.user.name),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Join On:  ',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            Text(MyDateUtil.getLastMessageTime(
                context: context, time: widget.user.createdAt, showYear: true),style: TextStyle(
              color: Colors.white
            ),)
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Profile Picture
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ClipRRect(
                    //for circular image(clipRRect give borderRadius functionality)
                    borderRadius: BorderRadius.circular((mq.height * 0.2) / 2),
                    //for give placeHolder and error
                    child: CachedNetworkImage(
                      //set image height and width
                      width: mq.height * 0.2,
                      height: mq.height * 0.2,
                      fit: BoxFit.fill,
                      imageUrl: widget.user.image,
                      //show loadingBar till then image load
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      // if image not show then by default image
                      errorWidget: (context, url, error) => CircleAvatar(
                          child: Image.asset('assets/images/avatar.png')),
                    ),
                  ),
                ),

                //For showing Email
                Text(
                  widget.user.email,
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 155, 168, 184),
                  ),
                ),

                // giving space between email and Name field
                SizedBox(height: mq.height * 0.05),

                SizedBox(
                  width: mq.width * .90,
                  //Name Input
                  child: TextFormField(
                    // readOnly: true,
                    enabled: false,
                    initialValue: widget.user.name,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: mq.width * .90,
                  //About Input
                  child: TextFormField(
                    enabled: false,
                    initialValue: widget.user.about,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.info_outline,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),



                /**
                ValueListenableBuilder<bool>(
                  valueListenable: isToggled,
                  builder: (BuildContext context, bool value, Widget? child) {
                    return Switch(
                      value: value,
                      onChanged: (newValue) {
                        isToggled.value = newValue; // Update the value directly
                      },
                    );
                  },
                ),
                SizedBox(height: 20.0),
                Text(
                  'Toggle State: ${isToggled.value}',
                  style: TextStyle(color: Colors.white,fontSize: 20.0),
                ),

                **/

/**
                // Center(
                //   child: ValueListenableBuilder<bool>(
                //     valueListenable: isSwitched,
                //     builder: (context, value, child) {
                //       return Column(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: <Widget>[
                //           Switch(
                //             value: value,
                //             onChanged: (newValue) {
                //               isSwitched.value = newValue;
                //             },
                //           ),
                //           Text(
                //             'Switch is ${value ? "ON" : "OFF"}',style: TextStyle(color: Colors.white),
                //           ),
                //         ],
                //       );
                //     },
                //   ),
                // ),

    **/

              ],
            ),
          ),
        ),
      ),
    );
  }
}
