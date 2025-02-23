import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chat_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

import '../models/chat_user.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for accessing cloud firestore database
  static FirebaseStorage storage = FirebaseStorage.instance;

  //for getting self info
  static late ChatUser me;

  //declare variable for user details
  static User get user => auth.currentUser!;

  // for accessing firebase message notification (push notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  //for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();
    fMessaging.getToken().then((token) {
      if (token != null) {
        me.pushToken = token;
        log('Push Token: $token');
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }

  //for sending push notification
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        'to': chatUser.pushToken,
        'notification': {
          'title': me.name,
          'body': msg,
          'android_channel_id': 'chats',
        },
        "data": {
          "some_data": "User ID: ${me.id}",
        },
      };

      var response =
          await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader:
                    'key=AAAAnfKw29E:APA91bEqGqHgX1JeyeeAyRZ676IDWi9xFXSJiFUEzUlFdePlCWn8DbhDT5zLaRGCkT1eUqsjmRe-D_H4pbfrb6fWIiZplaqnngfDhnuChxRxEluHMx8vL84DdkH_u2s3Ynei8mMKDEWQ'
              },
              body: jsonEncode(body));
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  //for Checking user exists or not if user exists
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    log('data:::::::  ${data.docs}');
    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //user exists
      log('user exists:::::: ${data.docs.first.data()}');
      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      return false;
    }
  }

  //for adding a chat user for our conversation
  static Future<bool> userExists() async {
    return (await firestore
            .collection('users')
            // .doc(auth.currentUser!.uid)
            .doc(user.uid)
            .get())
        .exists;
  }

  //for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore
        .collection('users')
        // .doc(auth.currentUser!.uid)
        .doc(user.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();

        //for setting user status to active
        APIs.updateActiveStatus(true);
        log('My Data:  ${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  //fro creating a new user if not exists
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      image: user.photoURL.toString(),
      about: "Hey! I'm using ChatKaro",
      createdAt: time,
      lastActive: time,
      isOnline: false,
      email: user.email.toString(),
      pushToken: '',
    );

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  //for getting all user from firebase
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser(
      List<String> userIds) {
    log('\nUser Ids: $userIds');
    return APIs.firestore
        .collection('users')
        .where('id', whereIn: userIds)
        .snapshots();
  }

  //for getting ID's of knows users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return APIs.firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  //send first message
  //for adding a user to my user when first msg is send
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  //for updating user info
  static Future<void> updatingUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  //update profile picture of user
  static Future<void> updateProfilePicture(File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    //storage file ref with path
    final ref = storage.ref().child('profile_picture/${user.uid}.$ext');

    //for uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transfer: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  //for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  //update active status
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  //Chat screen related APIs----------------------------///

  // chat(collection) -->conversation_id (doc) --> message (collection) --> message (doc)

  //useful for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  //for getting all messages of specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('send', descending: true)
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
        msg: msg,
        toId: chatUser.id,
        read: '',
        type: type,
        fromId: user.uid,
        send: time);
    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.send)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //for getting only one and last messages of specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('send', descending: true)
        .limit(1)
        .snapshots();
  }

  //send image in chat
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //for uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transfer: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  //Delete Message
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.send)
        .delete();

    if (message.type == Type.image)
      await storage.refFromURL(message.msg).delete();
  }

  //Update Message
  static Future<void> updateMessage(Message message, String updatedmsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.send)
        .update({'msg': updatedmsg});
  }
}
