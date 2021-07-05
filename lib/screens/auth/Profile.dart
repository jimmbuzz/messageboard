import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messageboard/screens/auth/settings.dart';
import 'package:messageboard/screens/home/home.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  var currentUser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          backgroundColor: Colors.indigo[400]
        ),
        body: FutureBuilder<DocumentSnapshot>(
            future: users.doc(currentUser!.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("Something went wrong");
              }

              if (snapshot.hasData && !snapshot.data!.exists) {
                return Text("Data does not exist");
              }
              if (snapshot.connectionState == ConnectionState.done) {
                Map<String, dynamic> data =
                    snapshot.data!.data() as Map<String, dynamic>;
                lNameController.text = data['lastname'];
                fNameController.text = data['firstname'];
                usernameController.text = data['username'];
                // return Text(
                //     "Full Name: ${data['full_name']} ${data['last_name']}");
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 200,
                        child: TextField(
                          controller: fNameController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Enter First Name'),
                        ),
                      ),
                      Container(
                        width: 200,
                        child: TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Enter Last Name'),
                          controller: lNameController,
                        ),
                      ),
                      Container(
                        width: 200,
                        child: TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Enter Username'),
                          controller: usernameController,
                        ),
                      ),
                      MaterialButton(
                        onPressed: () async {
                          String a = await updateUserInfo(data);
                          if (a.isNotEmpty) {
                            print("User values not changed");
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Error"),
                                    content: Text(a),
                                    actions: [
                                      ElevatedButton(
                                        child: Text("Ok"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  );
                                });
                          } else {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Success!"),
                                    content: Text('Profile Updated'),
                                    actions: [
                                      ElevatedButton(
                                        child: Text("Ok"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  );
                                });
                          }
                        },
                        child: Text('Save'),
                        color: Colors.blue[100],
                      )
                    ],
                  ),
                );
              }

              return Center(
                  child: CircularProgressIndicator(
                semanticsLabel: 'Loading...',
              ));
            }),
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
                  //Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Home()));
                },
              ),
              ListTile(
                title: Text('Profile'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Settings'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SettingsPage()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context, String message) {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          Container(margin: EdgeInsets.only(left: 5), child: Text(message)),
        ],
      ),
      actions: [okButton],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<String> updateUserInfo(Map<String, dynamic> data) async {
    return await users
        .doc(currentUser!.uid)
        .set({
          'email': data['email'],
          'isAdmin': data['isAdmin'],
          'regDateTime': DateTime.now(),
          'firstname': fNameController.text,
          'lastname': lNameController.text,
          'username': usernameController.text,
          'profile_pic': data['profile_pic']
        })
        .then((value) => '')
        .onError((error, stackTrace) => error.toString());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // Future<Map<String, dynamic>> getUserDetails() async {
  //   var currentUser = FirebaseAuth.instance.currentUser;
  //   var collection =
  //       FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);
  //   return await collection
  //       .get()
  //       .then((value) => {if (value.exists) {} else {}})
  //       .onError((error, stackTrace) => {});
  // }
}
