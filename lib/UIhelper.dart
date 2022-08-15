import 'package:flutter/material.dart';

class UIhelper {
  static void showloadingdialog(BuildContext context, String title) {
    AlertDialog loadingdialog = AlertDialog(
      content: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(
              height: 30,
            ),
            Text(title),
          ],
        ),
      ),
    );
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return loadingdialog;
        });
  }

  static void showalertdialog(String titile, BuildContext context, content) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(titile),
      content: Text(content),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("OK"))
      ],
    );
  }
}
