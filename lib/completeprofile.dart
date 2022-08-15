import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patter_app/HomePage.dart';
import 'package:patter_app/UIhelper.dart';
import 'package:patter_app/models/UserModel.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const CompleteProfile(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  File? imagefile;
  TextEditingController fullnamecontroller = TextEditingController();
  void SelectImage(ImageSource source) async {
    XFile? pickedfile = await ImagePicker().pickImage(source: source);

    if (pickedfile != null) {
      setState(() {
        File? file = File(pickedfile.path);
        imagefile = file;
      });
    }
  }

  void ShowPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Upload Profile Photo"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    SelectImage(ImageSource.gallery);
                  },
                  title: Text("Select From Gallery"),
                  leading: Icon(Icons.photo_album),
                ),
                ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      SelectImage(ImageSource.camera);
                    },
                    title: Text("Take a Photo"),
                    leading: Icon(Icons.camera_alt))
              ],
            ),
          );
        });
  }

  void checkvalues() {
    String fullname = fullnamecontroller.text.trim();
    if (fullname == "" || imagefile == null) {
      UIhelper.showalertdialog("Incomplete Data",context,"please fill all the fields and upload profile picture");
      log("message1");

      print("Please fill all the fields first");
    } else {
      Uploaddata();
    }
  }

  void Uploaddata() async {
   UIhelper.showloadingdialog(context, "Uploading image...");

    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.userModel.uid.toString())
        .putFile(imagefile!);
    TaskSnapshot snapshot = await uploadTask;
    String ImageUrl = await snapshot.ref.getDownloadURL();
    String fullname = fullnamecontroller.text.trim();
    widget.userModel.fullname = fullname;
    widget.userModel.profilepic = ImageUrl;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) => () {
              log("message2");
              print("data uploaded");
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return HomePage(
                    userModel: widget.userModel,
                    firebaseUser: widget.firebaseUser);
              }));
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Profile"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Center(
          child: ListView(
            children: [
              SizedBox(
                height: 10,
              ),
              CupertinoButton(
                  child: CircleAvatar(
                      backgroundImage:
                          (imagefile != null) ? FileImage(imagefile!) : null,
                      radius: 50,
                      child: (imagefile == null)
                          ? Icon(
                              Icons.person,
                              size: 50,
                            )
                          : null),
                  onPressed: () {
                    ShowPhotoOptions();
                  }),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: fullnamecontroller,
                decoration: InputDecoration(labelText: "Full Name"),
              ),
              SizedBox(height: 10),
              CupertinoButton(
                  child: Text("Submit"),
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: () {
                    checkvalues();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return HomePage(
                        userModel: widget.userModel,
                        firebaseUser: widget.firebaseUser,
                      );
                    }));
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
