import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:patter_app/UIhelper.dart';
import 'package:patter_app/completeprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:patter_app/models/UserModel.dart';

class signuppage extends StatefulWidget {
  signuppage({Key? key}) : super(key: key);

  @override
  State<signuppage> createState() => _signuppageState();
}

class _signuppageState extends State<signuppage> {
  TextEditingController emailcontroller = new TextEditingController();
  TextEditingController passwordcontrolller = new TextEditingController();
  TextEditingController cpasswordcontroller = new TextEditingController();
  void checkvalues() {
    String email = emailcontroller.text.trim();
    String password = passwordcontrolller.text.trim();
    String cpassword = cpasswordcontroller.text.trim();
    if (email == "" || password == "" || cpassword == "") {
      UIhelper.showalertdialog(
          "Incomplete Data", context, "Please fill all the fields");
    } else {
      if (password != cpassword) {
        UIhelper.showalertdialog("Password Mismatch", context,
            "The Passwords you entered do not match");
      } else {
        signup(email, password);
      }
    }
  }

  void signup(String email, String password) async {
    UserCredential? credential;
    UIhelper.showloadingdialog(context, "Creating New Account...");
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      UIhelper.showalertdialog("An Error Occured!", context, e.code.toString());
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newuser =
          new UserModel(uid: uid, email: email, fullname: "", profilepic: "");
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newuser.toMap())
          .then((value) {
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return CompleteProfile(
            userModel: newuser,
            firebaseUser: credential!.user!,
          );
        }));
        print("new user created");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: emailcontroller,
                    decoration: InputDecoration(labelText: "Email Address")),
                TextField(
                    controller: passwordcontrolller,
                    decoration: InputDecoration(labelText: "Password")),
                TextField(
                    controller: cpasswordcontroller,
                    decoration: InputDecoration(labelText: "Confirm Password")),
                SizedBox(height: 10),
                CupertinoButton(
                    child: Text("Sign Up"),
                    color: Theme.of(context).colorScheme.secondary,
                    onPressed: () {
                      checkvalues();
                    }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?"),
                    CupertinoButton(
                        child: Text("Log In"),
                        onPressed: () {
                          Navigator.pop(context);
                        })
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
