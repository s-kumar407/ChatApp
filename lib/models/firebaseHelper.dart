import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:patter_app/models/UserModel.dart';

class FirebaseHelper{

static Future<UserModel?>getUserModelbyID(String uid)async{
  UserModel? usermodel;
  DocumentSnapshot docsnp=await FirebaseFirestore.instance.collection("users").doc(uid).get();
  if(docsnp.data()!=null){
usermodel=UserModel.fromMap(docsnp.data() as Map<String,dynamic>);
  }
  return usermodel;

}}
// return LoginResponse.fromJson(response.data);