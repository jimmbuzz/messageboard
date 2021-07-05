import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:messageboard/screens/auth/Profile.dart';
import 'package:messageboard/screens/auth/settings.dart';
import 'package:messageboard/screens/chat/chat.dart';

class Home extends StatelessWidget {
  Home({this.uid});
  final String? uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.indigo[400],
        title: Text("Message Boards"),
      ),
      body: Container(
          child: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.article, size: 48.0),
            title: Text('General'),
            subtitle: Text('On-topic discussions'),
            onTap: () {
              print('General');
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Chat(
                            convId: 'general',
                            convName: 'General',
                          )));
            },
          ),
          ListTile(
            leading: Icon(Icons.announcement, size: 48.0),
            title: Text('Annoucements'),
            subtitle: Text('Important updates'),
            onTap: () {
              print('Annoucements');
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Chat(
                            convId: 'annoucements',
                            convName: 'Annoucements',
                          )));
            },
          ),
          ListTile(
            leading: Icon(Icons.assignment, size: 48.0),
            title: Text('Homework'),
            subtitle: Text('Homework help'),
            onTap: () {
              print('Homework');
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Chat(
                            convId: 'homework',
                            convName: 'Homework',
                          )));
            },
          ),
          ListTile(
            leading: Icon(Icons.textsms, size: 48.0),
            title: Text('Off-Topic'),
            subtitle: Text('For everything else'),
            onTap: () {
              print('Off-Topic');
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Chat(
                            convId: 'off-topic',
                            convName: 'Off-Topic',
                          )));
            },
          ),
        ],
      )),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo[400],
              ),
              child: Text('Message Board App'),
            ),
            ListTile(
              title: Text('Message Boards'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfilePage()));
              },
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsPage()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> isAdmin() async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final DocumentSnapshot docSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .get();
    return docSnap.get('isAdmin');
  }
}
