import 'package:messageboard/screens/auth/register.dart';
import 'package:messageboard/screens/auth/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:messageboard/screens/home/home.dart';

class Authenticate extends StatefulWidget {

  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  @override


  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference _firestore = FirebaseFirestore.instance.collection('users'); 

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register Or Login"),
        backgroundColor: Colors.indigo[400],
      ),
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children : <Widget>[
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text("Fan Page",
                style: TextStyle (
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                )  
              ) 
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
                child: ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EmailSignUp()),
                      );
                    },
                    child: Text('Sign Up'),
                  ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: ElevatedButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo)),
                    onPressed: () {
                      signInWithGoogle();
                    },
                    child: Text('Sign in with Google'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
                child: ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignIn()),
                      );
                    },
                    child: Text('Sign in with Email'),
                  ),
            ),
          ]),
      )
    );
  }
  //Future<UserCredential> 
  void signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    _auth.signInWithCredential(credential).then((result) {
      //check if user has data in firestore and if not create it
        _firestore.doc(_auth.currentUser!.uid).get()
          .then((DocumentSnapshot docSnapshot) {
            if(docSnapshot.exists) {
              print("User has data!");
              Navigator.pushReplacement (
                context,
                MaterialPageRoute(builder: (context) => Home(uid: result.user!.uid)),
              );
            } else {
              print("Creating user data");
              _firestore.doc(_auth.currentUser!.uid).set({
                'username' : _auth.currentUser!.displayName!.split(" ").first,
                'email' : _auth.currentUser!.email,
                'firstname' : _auth.currentUser!.displayName!.split(" ").first,
                'lastname' : _auth.currentUser!.displayName!.split(" ").last,
                'isAdmin': false, 
                'regDateTime' : DateTime.now(),
                'profile_pic' : _auth.currentUser!.photoURL,
              }).then((value) => Navigator.pushReplacement (
                context,
                MaterialPageRoute(builder: (context) => Home(uid: result.user!.uid)),
              ));
            }
          }
        );
      
    });
  }
}