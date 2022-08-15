import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:patter_app/main.dart';
import 'package:patter_app/models/Chatroommodel.dart';

import 'models/UserModel.dart';
import 'chatroom.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseuser;

  const SearchPage(
      {Key? key, required this.userModel, required this.firebaseuser})
      : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController emailsearch = new TextEditingController();
  Future<ChatRoomModel?> getchatroomModel(UserModel targetuser) async {
    ChatRoomModel? chatroomMDL;
    QuerySnapshot snpsht = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetuser.uid}", isEqualTo: true)
        .get();
    if (snpsht.docs.length > 0) {
      var docuData = snpsht.docs[0].data();
      ChatRoomModel existingchatroom =
          ChatRoomModel.fromMap(docuData as Map<String, dynamic>);
      chatroomMDL = existingchatroom;
    } else {
      ChatRoomModel newChatroomModel = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastmessage: "",
        participants: {
          widget.userModel.uid.toString(): true,
          targetuser.uid.toString(): true
        },
      );
      chatroomMDL = newChatroomModel;
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroomModel.chatroomid)
          .set(newChatroomModel.toMap());
      log("New Chatroom created");
    }
    return chatroomMDL;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search")),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailsearch,
              decoration: InputDecoration(labelText: "Email address"),
            ),
            SizedBox(
              height: 20,
            ),
            CupertinoButton(
                child: Text("Search"),
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () {
                  setState(() {});
                }),
            SizedBox(
              height: 20,
            ),
            StreamBuilder(
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot datasnpsht = snapshot.data as QuerySnapshot;
                    if (datasnpsht.docs.length > 0) {
                      Map<String, dynamic> userMap =
                          datasnpsht.docs[0].data() as Map<String, dynamic>;
                      UserModel searchedUser = UserModel.fromMap(userMap);
                      return ListTile(
                        onTap: () async {
                          ChatRoomModel? chatROOMmodeL =
                              await getchatroomModel(searchedUser);
                          if (chatROOMmodeL != null) {
                            Navigator.pop(context);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ChatRoom(
                                userModel: widget.userModel,
                                firebaseUser: widget.firebaseuser,
                                targetuser: searchedUser,
                                chatroom: chatROOMmodeL,
                              );
                            }));
                          }
                        },
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(searchedUser.profilepic!),
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        title: Text(searchedUser.fullname!),
                        subtitle: Text(searchedUser.email!),
                      );
                    } else {
                      return Text("No Result Found");
                    }
                  } else {
                    if (snapshot.hasError) {
                      return Text("An Error Occured");
                    } else {
                      return Text("No Result Found");
                    }
                  }
                } else {
                  return Text("");
                }
              },
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .where("email", isEqualTo: emailsearch.text)
                  .where("email", isNotEqualTo: widget.userModel.email)
                  .snapshots(),
            )
          ],
        ),
      )),
    );
  }
}
