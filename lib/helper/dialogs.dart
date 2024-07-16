import 'package:flutter/material.dart' ;
class Dialogs{
  //for warning popup when user not connected with internet
  static void showSnackBar(BuildContext context, String msg){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg),
          backgroundColor: Colors.blue.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
        )
    );
  }

  //for showing progressbar (loading)
  static void showProgressBar(BuildContext context){
    showDialog(context: context,
        builder: (_) =>const Center(
          child: CircularProgressIndicator(),
        ));
  }
}