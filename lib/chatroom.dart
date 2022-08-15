import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:patter_app/main.dart';
import 'package:patter_app/models/Chatroommodel.dart';
import 'package:patter_app/models/Messagemodel.dart';
import 'package:patter_app/models/UserModel.dart';



class ChatRoom extends StatefulWidget {
  final UserModel targetuser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoom(
      {Key? key,
      required this.targetuser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser})
      : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  TextEditingController messagecontroller = TextEditingController();
  void sendmessages() async {
    String msg = messagecontroller.text.trim();
    messagecontroller.clear();
    if (msg != null) {
      MessageModel newmessageModel = MessageModel(
        messageid: uuid.v1(),
        sender: widget.userModel.uid,
        text: msg,
        seen: false,
        createdon: DateTime.now(),
      );
      print("hiiii");
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newmessageModel.messageid)
          .set({
        "messageid": uuid.v1(),
        "sender": widget.userModel.uid,
        "text": msg,
        "seen": false,
        "createdon": DateTime.now(),
      });
      // widget.chatroom.lastmessage=msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set({
        "chatroomid": widget.chatroom.chatroomid,
        "participants": widget.chatroom.participants,
        "lastmessage": msg
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage:
                NetworkImage(widget.targetuser.profilepic.toString()),
          ),
          SizedBox(
            width: 10,
          ),
          Text(widget.targetuser.fullname.toString())
        ],
      )),
      body: SafeArea(
          child: Container(
        child: Column(
          children: [
            Expanded(
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: StreamBuilder(
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          if (snapshot.hasData) {
                            QuerySnapshot datasnpsht =
                                snapshot.data as QuerySnapshot;
                            return ListView.builder(
                              reverse: true,
                              itemBuilder: (context, index) {
                                // MessageModel currentMessage =
                                //     MessageModel.fromMap(datasnpsht.docs[index]
                                //         .data() as Map<String, dynamic>);
                                return Row(
                                  mainAxisAlignment: (snapshot.data!.docs[index]
                                              ["sender"] ==
                                          widget.userModel.uid)
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  children: [
                                    Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 2),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        decoration: BoxDecoration(
                                            color: (snapshot.data!.docs[index]
                                                        ["sender"] ==
                                                    widget.userModel.uid)
                                                ? Colors.grey
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Text(
                                          snapshot.data!.docs[index]["text"],
                                          style: TextStyle(color: Colors.white),
                                        )),
                                  ],
                                );
                              },
                              itemCount: datasnpsht.docs.length,
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                  "An Error Occurred! Please check your internet connection"),
                            );
                          } else {
                            return Center(
                              child: Text("Say HI! to your new freind"),
                            );
                          }
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                      stream: FirebaseFirestore.instance
                          .collection("chatrooms")
                          .doc(widget.chatroom.chatroomid)
                          .collection("messages")
                          .orderBy("createdon", descending: true)
                          .snapshots(),
                    ))),
            Container(
              color: Colors.blueGrey[100],
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: Row(
                children: [
                  Flexible(
                      child: TextField(
                    maxLines: null,
                    controller: messagecontroller,
                    decoration: InputDecoration(labelText: "Enter message"),
                  )),
                  IconButton(
                      onPressed: () {
                        sendmessages();
                      },
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.secondary,
                      ))
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}
