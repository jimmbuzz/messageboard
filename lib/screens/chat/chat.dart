import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//import 'package:chat_app/screens/search/add_user.dart';

class Chat extends StatefulWidget {
  final String convId;
  final String convName;
  Chat({required this.convId, required this.convName});

  @override
  _ChatState createState() => _ChatState(convId: convId, convName: convName);
}

class _ChatState extends State<Chat> {
  final String convId;
  final String convName;

  TextEditingController messageEditingController = new TextEditingController();
  ScrollController _scrollController = new ScrollController();

  _ChatState({required this.convId, required this.convName});

  Widget chatMessages(){
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore
        .instance
        .collection('messages')
        .where('conversation_id', isEqualTo: convId)
        .orderBy('datetime')
        .snapshots(),
      builder: (context, messagesnapshot){
        return messagesnapshot.hasData ? ListView.builder(
          padding: const EdgeInsets.only(bottom: 60),          
          itemCount: messagesnapshot.data!.docs.length,
          controller: _scrollController,
          itemBuilder: (context, index){
            return MessageTile(
              message: messagesnapshot.data!.docs[index].get('content'),
              messageSender: senderDisplayName(messagesnapshot.data!.docs[index].get('from_id')),
              sendByMe: FirebaseAuth.instance.currentUser!.uid == messagesnapshot.data!.docs[index].get('from_id'),
              time: messagesnapshot.data!.docs[index].get('datetime')
            );
          },
        )  : Container();
      },
    );
  }
  Future<String> senderDisplayName(String uid) async {
    final DocumentSnapshot docSnap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return docSnap.get('username');
  }
  addMessage() async {
    if (messageEditingController.text.isNotEmpty) {
      CollectionReference messages = FirebaseFirestore.instance.collection('messages');
      messages.add({
        'conversation_id' : convId,
        'content' : messageEditingController.text,
        'datetime' : DateTime.now(),
        'from_id' : FirebaseAuth.instance.currentUser!.uid,
        'type' : 'text'
      }).then((value) => 
        FirebaseFirestore
        .instance
        .collection('boards')
        .doc(convId)
        .update({'last_message' : value.id})
      );
      setState(() {
        messageEditingController.text = "";
        Timer(Duration(milliseconds: 200), () =>
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent));
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[400],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(convName),
            // IconButton(
            //   onPressed: () => addUser(context),
            //   icon: Icon(Icons.add, size: 30)
            // )
          ]
        )
      ),
      body: Container(
        child: Stack(
          children: [
            chatMessages(),
            Container(alignment: Alignment.bottomCenter,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                color: Colors.indigo[200],
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                          controller: messageEditingController,
                          decoration: InputDecoration(
                              hintText: "Message ...",
                              hintStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              border: InputBorder.none
                          ),
                        )),
                    SizedBox(width: 16,),
                    GestureDetector(
                      onTap: () {
                        addMessage();
                      },
                      child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    const Color(0x36FFFFFF),
                                    const Color(0x0FFFFFFF)
                                  ],
                                  begin: FractionalOffset.topLeft,
                                  end: FractionalOffset.bottomRight
                              ),
                              borderRadius: BorderRadius.circular(40)
                          ),
                          padding: EdgeInsets.all(12),
                          child: Image.asset("assets/images/send.png",
                            height: 25, width: 25,)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class MessageTile extends StatelessWidget {
  final String message;
  final Future<String> messageSender;
  final bool sendByMe;
  final Timestamp time;

  MessageTile({required this.message, required this.messageSender, required this.sendByMe, required this.time});

  @override
  Widget build(BuildContext context) {
    return Column (children: <Widget>[
      Container( child: FutureBuilder(
        future: messageSender,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text('noname');
          } else {
            return Container (
              alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(snapshot.data.toString()),
              padding: EdgeInsets.only(
                top: 4,
                bottom: 4,
                left: sendByMe ? 0 : 24,
                right: sendByMe ? 24 : 0),
            );
          }
        },
      )),
      Container(
        padding: EdgeInsets.only(
            top: 8,
            bottom: 8,
            left: sendByMe ? 0 : 24,
            right: sendByMe ? 24 : 0),
        alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: sendByMe
              ? EdgeInsets.only(left: 30)
              : EdgeInsets.only(right: 30),
          padding: EdgeInsets.only(
              top: 17, bottom: 17, left: 20, right: 20),
          decoration: BoxDecoration(
              borderRadius: sendByMe ? BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomLeft: Radius.circular(23)
              ) :
              BorderRadius.only(
          topLeft: Radius.circular(23),
            topRight: Radius.circular(23),
            bottomRight: Radius.circular(23)),
              gradient: LinearGradient(
                colors: sendByMe ? [
                  const Color(0xff007EF4),
                  const Color(0xff2A75BC)
                ] : [
                  const Color(0x5f555555),
                  const Color(0x5f555555)
                ],
              )
          ),
          child: Text(message,
              textAlign: TextAlign.start,
              style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'OverpassRegular',
              fontWeight: FontWeight.w300)),
        ),
      ),
      Container(
        alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                time.toDate().toString().substring(0,time.toDate().toString().length-4), 
                style: TextStyle(
                  color: Colors.grey
                ),
              ),
              padding: EdgeInsets.only(
                top: 4,
                bottom: 4,
                left: sendByMe ? 0 : 24,
                right: sendByMe ? 24 : 0),
      )
    ]);
  }
}