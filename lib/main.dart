import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:patter_app/HomePage.dart';
import 'package:patter_app/login.dart';
import 'package:patter_app/models/UserModel.dart';
import 'package:patter_app/models/firebaseHelper.dart';
import 'package:uuid/uuid.dart';
var uuid=Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  User? currentuser = FirebaseAuth.instance.currentUser;

 
  if (currentuser != null) {
    UserModel? thisUserModel =
        await FirebaseHelper.getUserModelbyID(currentuser.uid);
    if (thisUserModel != null) {
      runApp(
          MyAppLoggedIn(userModel: thisUserModel, firebaseuser: currentuser));
    } else {
      runApp(const MyApp());
    }
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: loginpage());
  }
}

class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseuser;

  const MyAppLoggedIn(
      {Key? key, required this.userModel, required this.firebaseuser})
      : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(
          userModel: userModel,
          firebaseUser: firebaseuser,
        ));
  }
}
