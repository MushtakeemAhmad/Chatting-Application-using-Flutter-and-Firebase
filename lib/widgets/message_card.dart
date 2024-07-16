import 'dart:developer';
// import 'dart:convert';
// import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import '../helper/dialogs.dart';
import '../main.dart';
import '../models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  bool _isEdit = false;
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return GestureDetector(
        onLongPress: () {
          _showBottomSheet(isMe);
        },
        child: _messageCard());
  }

  //Sender message and receiver
  Widget _messageCard() {
    if (APIs.user.uid != widget.message.fromId) {
      if (widget.message.read.isEmpty) {
        APIs.updateMessageReadStatus(widget.message);
      }
    }

    return Align(
        alignment: (APIs.user.uid == widget.message.fromId
            ? Alignment.centerRight
            : Alignment.centerLeft),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45,
          ),
          child: Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: (APIs.user.uid == widget.message.fromId
                ? Colors.blueGrey
                : Color.fromARGB(255, 32, 42, 51)),
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Stack(children: [
              Padding(
                padding: EdgeInsets.only(
                  left: widget.message.type == Type.text ? 10 : 5,
                  right: widget.message.type == Type.text ? 60 : 5,
                  top: widget.message.type == Type.text ? 5 : 5,
                  bottom: widget.message.type == Type.text ? 20 : 5,
                ),
                child: widget.message.type == Type.text
                    ?
                    //show text meg
                    Text(
                        widget.message.msg,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        //show image msg
                      )
                    : ClipRRect(
                        //for circular image(clipRRect give borderRadius functionality)
                        borderRadius: BorderRadius.circular(8),
                        //for give placeHolder and error
                        child: CachedNetworkImage(
                          //set image height and width
                          // width: mq.height * 0.055,
                          // height: mq.height * 0.055,
                          imageUrl: widget.message.msg,
                          //show loadingBar till then image load
                          placeholder: (context, url) => Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          // if image not show then by default image
                          errorWidget: (context, url, error) => Icon(
                            Icons.image,
                            size: 70,
                          ),
                        ),
                      ),
              ),
              Positioned(
                bottom: widget.message.type == Type.text ? 4 : 10,
                right: widget.message.type == Type.text ? 10 : 15,
                child: Row(
                  children: [
                //     _isEdit?Text('Edited ',style: TextStyle(
                //   fontSize: 13,
                //   color: Color.fromARGB(255, 155, 168, 184),
                // )):Container(),
                    Text(
                        MyDateUtil.getFormattedTime(
                            context: context, time: widget.message.send),
                        style: TextStyle(
                          fontSize: 13,
                          color: Color.fromARGB(255, 155, 168, 184),
                        )),
                    SizedBox(
                      width: 5,
                    ),
                    // check if user send msg then placed a tick icon
                    (APIs.user.uid == widget.message.fromId
                        //again check if
                        ? widget.message.read.isNotEmpty
                            ? Icon(
                                Icons.done_all,
                                size: 20,
                                color: Colors.blue,
                              )
                            : Container()
                        : Container()),
                    // Container(
                    //   child: Icon(Icons.done_all, size: 20,color: Colors.blue,),
                    // )
                    // Icon(Icons.done_all, size: 20,color: Colors.blue,)
                  ],
                ),
              )
            ]),
          ),
        ));
  }

  //own or user message
  // Widget _greenMessage() {
  //   return Card(
  //     shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.only(
  //       topRight: Radius.circular(25),
  //       bottomLeft: Radius.circular(20),
  //       bottomRight: Radius.circular(20),
  //     )),
  //     // color: Colors.blueGrey,
  //     color: Color.fromARGB(255, 32, 42, 51),
  //     margin: EdgeInsets.only(top: 10, bottom: 5, left: 10, right: 100),
  //     child: Padding(
  //       padding: const EdgeInsets.all(12.0),
  //       // child: Text(widget.message.msg +' '+widget.message.send,style: TextStyle(
  //       //   color: Colors.white
  //       // ),),
  //
  //       child: RichText(
  //         text: TextSpan(children: [
  //           TextSpan(
  //             text: widget.message.msg,
  //           ),
  //           TextSpan(text: ' '),
  //           TextSpan(
  //             text: widget.message.send,
  //             style: TextStyle(
  //                 color: Color.fromARGB(255, 155, 168, 184),
  //                 fontSize: 10,
  //                 fontWeight: FontWeight.w300),
  //           ),
  //         ]),
  //       ),
  //
  //       // child: Row(
  //       //   // mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       //   children: [
  //       //     Text(
  //       //       widget.message.msg ,
  //       //       textAlign: TextAlign.left,
  //       //       style: TextStyle(color: Colors.white),
  //       //     ),
  //       //     Spacer(),
  //       //     Text(
  //       //       widget.message.send,
  //       //       textAlign: TextAlign.right,
  //       //       style: TextStyle(color: Colors.white38,fontWeight: FontWeight.w300),
  //       //     ),
  //       //   ],
  //       // ),
  //     ),
  //   );
  // }

  //show bottom sheet for modify details
  void _showBottomSheet(bool isMe) {
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
              Container(
                decoration: BoxDecoration(),
              ),
              //Copy Text or Save Image
              widget.message.type == Type.text
                  // Copy Text
                  ? _OptionItem(
                      icon: Icon(Icons.copy,
                          color: Color.fromARGB(255, 155, 168, 184), size: 26),
                      name: "Copy Text",
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          // for hiding saving bottom sheet
                          Navigator.pop(context);
                          //show dialog box or popup
                          Dialogs.showSnackBar(context, 'Text Copied');
                        });
                      })
                  // Save image
                  : _OptionItem(
                      icon: Icon(Icons.save_alt,
                          color: Color.fromARGB(255, 155, 168, 184), size: 26),
                      name: "Save Image",
                      onTap: () async {
                         try{
                           log('Image Url:- ${widget.message.msg}');
                           await GallerySaver.saveImage(widget.message.msg, albumName: 'Chat Karo').then((success) {
                             // for hiding saving bottom sheet
                             Navigator.pop(context);
                             //show dialog box or popup if image saved
                             if(success != null && success){
                               Dialogs.showSnackBar(context, 'Image saved successfully');
                             }
                           });
                         } catch(e){
                           log('gettingErrorWithImageSave: $e');
                           Navigator.pop(context);
                           Dialogs.showSnackBar(context, 'There is some problem! \nPlease check your internet connection');
                         }
                      }),

              //Divider
              if (isMe)
                Divider(
                  color: Color.fromARGB(255, 155, 168, 184),
                  indent: mq.width * .03,
                  endIndent: mq.width * .03,
                ),

              //Edit Option
              // if (widget.message.type == Type.text && isMe)
              //   _OptionItem(
              //       icon: Icon(Icons.edit,
              //           color: Color.fromARGB(255, 155, 168, 184), size: 26),
              //       name: "Edit Message",
              //       onTap: () {
              //         //for hiding bottom sheet
              //       Navigator.pop(context);
              //
              //       _showMessageUpdateDialog();
              //       }),

              //Delete Option
              if (isMe)
                _OptionItem(
                    icon: Icon(Icons.delete_forever,
                        color: Color.fromARGB(255, 155, 168, 184), size: 26),
                    name: "Delete Message",
                    onTap: () async => {
                      await APIs.deleteMessage(widget.message).then((value) {
                        // log('message deletedd');
                        Navigator.pop(context);
                        Dialogs.showSnackBar(context, 'Deleted');
                      }),
                    }),

              Divider(
                color: Color.fromARGB(255, 155, 168, 184),
                indent: mq.width * .03,
                endIndent: mq.width * .03,
              ),
              //Send Time
              _OptionItem(
                  icon: Icon(Icons.send_outlined,
                      color: Color.fromARGB(255, 155, 168, 184), size: 26),
                  name:
                      "Send At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.send)}",
                  onTap: () => {}),

              //Read Time
              _OptionItem(
                  icon: Icon(Icons.remove_red_eye,
                      color: Color.fromARGB(255, 155, 168, 184), size: 26),
                  name: widget.message.read.isEmpty
                      ? "Read At: Not seen yet"
                      : "Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}",
                  onTap: () => {}),
            ],
            // color: Colors.white10,
          );
        });
  }

  //for update message dialog box
   void _showMessageUpdateDialog(){
    String updatedmsg = widget.message.msg;
    String preMsg = widget.message.msg;
     _isEdit = false;
    showDialog(context: context, builder: (_)=>AlertDialog(
      backgroundColor: Color.fromARGB(255, 19, 25, 32),
      contentPadding: EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 24),
      //title
      title: Row(
        children: [
          Icon(Icons.message,size: 26,color: Color.fromARGB(255, 155, 168, 184), ),
          Text('  Updated Message',style: TextStyle(color: Colors.white,fontSize: 18)),
        ],
      ),
      //content
      content: TextFormField(
        maxLines: null,
        initialValue: updatedmsg,style: TextStyle(color: Colors.white),
        onChanged: (value)=> updatedmsg = value,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))
        ),
      ),
      //action
      actions: [
        MaterialButton(onPressed: (){
          //for hiding bottom sheet
          Navigator.pop(context);
        },
          child: Text('Cancel',style: TextStyle(color: Colors.white),),),
        MaterialButton(onPressed: (){
          //for hiding bottom sheet
          Navigator.pop(context);
          APIs.updateMessage(widget.message , updatedmsg);
          if(preMsg!=updatedmsg){
            _isEdit = true;
          }
        },
          child: Text('Submit',style: TextStyle(color: Colors.white),),)
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
            left: mq.width * .05,
            bottom: mq.height * .02,
            top: mq.height * .02),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              '    $name',
              style: TextStyle(
                  color: Colors.white, fontSize: 16, letterSpacing: 1),
            ))
          ],
        ),
      ),
    );
  }
}
