import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:messageboard/screens/auth/authenticate.dart';

class Home extends StatelessWidget {

  Home({this.uid});
  final String? uid;

  @override
  Widget build(BuildContext context) {
    FirebaseAuth _auth = FirebaseAuth.instance;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.indigo[400],
        automaticallyImplyLeading: false,
        title: Text("Home"),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.amber,
            ),
            onPressed: () {
              showDialog(context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Text("Sign Out?"),
                  actions: [
                    TextButton(
                      child: Text("Proceed"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _auth.signOut().then((res) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => Authenticate()),
                          (Route<dynamic> route) => false);
                        });
                      },
                    ),
                    TextButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              });
            },
          )
        ]
      ),
      body: Container(
        //constraints: BoxConstraints.expand(),
        // decoration: BoxDecoration(
        //   shape: BoxShape.circle,
        //   image: DecorationImage(
        //     image: AssetImage("lib/images/IMG_8053.JPG"),
        //   )
        // ),
        child: Stack(
          children: [
            //adminMessages(),
          ],
        ),
      ),
      //floatingActionButton: adminButtom()
    );
  }
  // Widget adminMessages() {
  //   return StreamBuilder<QuerySnapshot>(
  //     stream: FirebaseFirestore
  //       .instance
  //       .collection('messages')
  //       .orderBy('timeStamp', descending: true)
  //       .snapshots(),
  //       builder: (context, snapshot) {
  //         if(!snapshot.hasData) {
  //           return Center (
  //             child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo)));
  //         } else {
  //           return ListView.builder(
  //             padding: EdgeInsets.all(10.0),
  //             itemBuilder: (context, index){
  //               DocumentSnapshot data = snapshot.data!.docs[index];
  //               return MessageBox(message: data.get('message'));
  //             },
  //             itemCount: snapshot.data!.docs.length,
  //             reverse: true,
  //           );
  //         }
  //       },
  //   );
  // }
  Future<bool> isAdmin() async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final DocumentSnapshot docSnap = await FirebaseFirestore.instance.collection('users').doc(currentUserUid).get();
    return docSnap.get('isAdmin');
  }
  // Widget adminButtom() {
  //   return FutureBuilder(
  //     future: isAdmin(),
  //       builder: (context, snapshot) {
  //         if(!snapshot.hasData) {
  //           return Center (
  //             child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo)));
  //         } else {
  //           if (snapshot.data != false) {
  //             return  FloatingActionButton(
  //               onPressed: () {
  //                 _displayTextInputDialog(context);
  //               },
  //               child: const Icon(Icons.add),
  //               backgroundColor: Colors.indigo,
  //             );
  //           } else {
  //             return Container();
  //           }
  //         }
  //       },
  //   );
  // }
}
TextEditingController _textFieldController = TextEditingController();

Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Message Your Fans'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "Enter a message..."),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CLOSE'),
              onPressed: () {
                Navigator.pop(context);
                _textFieldController.clear();
              },
            ),
            TextButton(
              child: Text('POST'),
              onPressed: () {
                FirebaseFirestore
                .instance
                .collection('messages')
                .doc().set({
                  'message' : _textFieldController.text,
                  'timeStamp' : DateTime.now(),
                });
                print(_textFieldController.text);
                Navigator.pop(context);
                _textFieldController.clear();
              },
            ),
          ],
        );
      },
    );
  }
//@override
class MessageBox extends StatelessWidget {
  final String message;

  MessageBox({required this.message});

  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 8,
        bottom: 8,
      ),
      
      alignment: Alignment.center,
      child: Text(message,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'OverpassRegular',
              fontWeight: FontWeight.w500
            )
      ),
    );
  }
}