import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:patter_app/chatroom.dart';
import 'package:patter_app/login.dart';
import 'package:patter_app/models/Chatroommodel.dart';
import 'package:patter_app/models/UserModel.dart';
import 'package:patter_app/models/firebaseHelper.dart';
import 'package:patter_app/saerchpage.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomePage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat App"),
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return loginpage();
                }));
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: SafeArea(
          child: Container(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("chatrooms")
                      .where("participants.${widget.userModel.uid}",
                          isEqualTo: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot chatroomssnapshots =
                            snapshot.data as QuerySnapshot;
                        return ListView.builder(
                            itemCount: chatroomssnapshots.docs.length,
                            itemBuilder: (context, index) {
                              ChatRoomModel chatRoomModel =
                                  ChatRoomModel.fromMap(
                                      chatroomssnapshots.docs[index].data()
                                          as Map<String, dynamic>);
                              Map<String, dynamic> participants =
                                  chatRoomModel.participants!;
                              List<String> participantkeys =
                                  participants.keys.toList();
                              participantkeys.remove(widget.userModel.uid);
                              return FutureBuilder(
                                  future: FirebaseHelper.getUserModelbyID(
                                      participantkeys[0]),
                                  builder: (context, userdata) {
                                    if (userdata.connectionState ==
                                        ConnectionState.done) {
                                      if (userdata.data != null) {
                                        UserModel targetuser =
                                            userdata.data as UserModel;
                                        return ListTile(
                                          onTap: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return ChatRoom(
                                                  targetuser: targetuser,
                                                  chatroom: chatRoomModel,
                                                  userModel: widget.userModel,
                                                  firebaseUser:
                                                      widget.firebaseUser);
                                            }));
                                          },
                                          leading: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                targetuser.profilepic
                                                    .toString()),
                                          ),
                                          title: Text(
                                              targetuser.fullname.toString()),
                                          subtitle: (chatRoomModel.lastmessage
                                                      .toString() !=
                                                  null)
                                              ? Text(chatRoomModel.lastmessage
                                                  .toString())
                                              : Text(
                                                  "Say hi! to your new freind",
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                  ),
                                                ),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    } else {
                                      return Container();
                                    }
                                  });
                            });
                      } else if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      } else {
                        return Text("No Chats!");
                      }
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchPage(
                userModel: widget.userModel, firebaseuser: widget.firebaseUser);
          }));
        },
        child: Icon(Icons.search),
      ),
    );
  }
}
