import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:patter_app/HomePage.dart';
import 'package:patter_app/UIhelper.dart';
import 'signup.dart';
import 'main.dart';
import 'package:patter_app/models/UserModel.dart';

class loginpage extends StatefulWidget {
  loginpage({Key? key}) : super(key: key);

  @override
  State<loginpage> createState() => _loginpageState();
}

class _loginpageState extends State<loginpage> {
  TextEditingController emailcontroller = new TextEditingController();
  TextEditingController passwordcontroller = new TextEditingController();
  void checkvalues() {
    String email = emailcontroller.text.trim();
    String password = passwordcontroller.text.trim();
    if (email == "" || password == "") {
      UIhelper.showalertdialog(
          "Incomplete Data", context, "Please fill all the fields");
    } else {
      login(email, password);
    }
  }

  void login(String email, String password) async {
    UserCredential? credential;
    UIhelper.showloadingdialog(context, "Logging In...");
    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
        
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      UIhelper.showalertdialog("An Error Occured!", context, e.code.toString());
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      print(uid);
      DocumentSnapshot UserData =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();
      print(UserData);
      UserModel userModel =
          UserModel.fromMap(UserData.data() as Map<String, dynamic>);
      print("LogIn successfull");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return HomePage(userModel: userModel, firebaseUser: credential!.user!);
      }));
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
                Text(
                  "Chat App",
                ),
                TextField(
                    controller: emailcontroller,
                    decoration: InputDecoration(labelText: "Email Address")),
                TextField(
                    controller: passwordcontroller,
                    decoration: InputDecoration(labelText: "Password")),
                SizedBox(height: 10),
                CupertinoButton(
                    child: Text("Log In"),
                    color: Theme.of(context).colorScheme.secondary,
                    onPressed: () {
                      checkvalues();
                    }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(" Don't have an account?"),
                    CupertinoButton(
                        child: Text("Sign Up"),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return signuppage();
                          }));
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
