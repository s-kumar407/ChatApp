class ChatRoomModel {
  String? chatroomid;
  Map<String,dynamic>? participants;
  String? lastmessage;
  ChatRoomModel({this.lastmessage,this.chatroomid, this.participants});
  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatroomid = map["chatroomid"];
    participants = map["participants"];
    lastmessage=map["lastmessage"];
  }
  Map<String, dynamic> toMap() {
    return {"chatroomid": chatroomid, "participants": participants, "lastmessage":lastmessage};
  }
}
