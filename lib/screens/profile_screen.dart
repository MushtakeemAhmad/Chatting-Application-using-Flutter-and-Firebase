import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../main.dart';
import '../models/chat_user.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<StatefulWidget> createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  // for input from input field
  final _formKey = GlobalKey<FormState>();
  //for store user image path
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for removing keyboard from screen on tap screen anywhere
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: FloatingActionButton.extended(
            onPressed: () async {
              //Show ProgressBar
              Dialogs.showProgressBar(context);

              // for active status false before sign out
              await APIs.updateActiveStatus(false);

              //for logout/sign out app
              await APIs.auth.signOut().then((value) {
                // await GoogleSignIn.signOut();
                var auth = GoogleSignIn();
                auth.signOut().then((value) {
                  //removing progress bar
                  Navigator.pop(context);
                  //for removing profile screen and goto previous screen
                  Navigator.pop(context);

                  APIs.auth = FirebaseAuth.instance;

                  // for removing home screen & goto login screen
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                });
              });
            },
            //for SignOut background color
            backgroundColor: Colors.deepOrangeAccent,
            label: Text(
              'LogOut',
              style: TextStyle(color: Colors.white),
            ),
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Profile Picture
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Stack(
                      children: [
                        _image != null ?
                            // if user give image
                        ClipRRect(
                          //for circular image(clipRRect give borderRadius functionality)
                          borderRadius:
                          BorderRadius.circular((mq.height * 0.2) / 2),
                          //for give placeHolder and error
                          child: Image.file(File(_image!),
                            width: mq.height * 0.2,
                            height: mq.height * 0.2,
                            fit: BoxFit.cover,
                          ),

                        )
                            :
                            ClipRRect(
                          //for circular image(clipRRect give borderRadius functionality)
                          borderRadius:
                              BorderRadius.circular((mq.height * 0.2) / 2),
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
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: FloatingActionButton(
                            onPressed: () {
                              //show bottom popup for picking image
                              _showBottomSheet();

                            },
                            // backgroundColor: Color.fromARGB(255, 32, 42, 51),
                            backgroundColor: Colors.blueGrey,
                            shape: CircleBorder(),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        )
                      ],
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
                  SizedBox(
                    height: mq.height * 0.05,
                  ),

                  SizedBox(
                    width: mq.width * .90,
                    //Name Input
                    child: TextFormField(
                      initialValue: widget.user.name,
                      style: TextStyle(color: Colors.white),
                      onSaved: (val) => APIs.me.name = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                        hintText: 'Type Your Name',
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 155, 168, 184),
                        ),
                        // label: Text('Your Name'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: mq.height * 0.02,
                  ),

                  SizedBox(
                    width: mq.width * .90,
                    //About Input
                    child: TextFormField(
                      initialValue: widget.user.about,
                      style: TextStyle(color: Colors.white),
                      onSaved: (val) => APIs.me.about = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.info_outline,
                          color: Colors.white,
                        ),
                        hintText: 'Feeling Good',
                        // label: Text('About You'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: mq.height * 0.06,
                  ),

                  ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        //for save current screen
                        _formKey.currentState!.save();
                        //for update firebase
                        APIs.updatingUserInfo().then((value) {
                          //show popup when save change
                          Dialogs.showSnackBar(
                              context, 'Profile Updated Successfully');
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      // shape: StadiumBorder(),
                      minimumSize: Size(
                        mq.width * .5,
                        mq.height * .06,
                      ),
                      // backgroundColor: Color.fromARGB(255, 32, 42, 51),
                      backgroundColor: Colors.blueGrey,
                    ),
                    icon: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 27,
                    ),
                    label: Text(
                      'UPDATE',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //show bottom sheet for select DP
  void _showBottomSheet() {
    //show a popup from bottom
    showModalBottomSheet(
        // backgroundColor: Color.fromARGB(255, 32, 42, 51),
        backgroundColor: Color.fromARGB(255, 19, 25, 32),
        context: context,
        builder: (_) {
          //for showing content in bottom sheet
          return ListView(
            padding: EdgeInsets.only(
                top: mq.height * 0.03, bottom: mq.height * 0.05),
            //it shrink the size of bottomSheet and give it all content size
            shrinkWrap: true,
            children: [
              // for profile picture label
              Center(
                child: Text(
                  'Select Profile Picture',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                ),
              ),

              //give space between text & icon
              SizedBox(
                height: mq.height * .02,
              ),

              //for icon in a row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //Gallery Icon button
                  ElevatedButton(
                      onPressed: () async {
                        //pick image from user
                        final ImagePicker picker = ImagePicker();
                        // Pick an image in gallery
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);
                        if(image!=null){
                          log('Image Path: ${image.path} ------ MineType: ${image.mimeType}');
                          setState(() {
                            _image = image.path;
                          });
                          //function for update image
                          APIs.updateProfilePicture(File(_image!));
                          //for hiding bottom popup image picker
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size.square(mq.height * 0.15),
                        backgroundColor: Color.fromARGB(255, 32, 42, 51),
                      ),
                      child: Image.asset('assets/images/gallery.png')),
                  //Camera icon button
                  ElevatedButton(
                      onPressed: () async {
                        //pick image from user
                        final ImagePicker picker = ImagePicker();
                        // Pick an image in camera
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if(image!=null){
                          log('Image Path: ${image.path}');
                          setState(() {
                            _image = image.path;
                          });
                          //function for update image
                          APIs.updateProfilePicture(File(_image!));
                          //for hiding bottom popup image picker
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size.square(mq.height * 0.15),
                        backgroundColor: Color.fromARGB(255, 32, 42, 51),
                      ),
                      child: Image.asset('assets/images/camera.png')),
                ],
              ),

              //give space between icon & bottom
              SizedBox(
                height: mq.height * .02,
              ),
            ],
            // color: Colors.white10,
          );
        });
  }
}
