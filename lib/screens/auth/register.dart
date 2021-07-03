import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messageboard/screens/home/home.dart';

class EmailSignUp extends StatefulWidget {

  @override
  _EmailSignUpState createState() => _EmailSignUpState();
}

class _EmailSignUpState extends State <EmailSignUp>  {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  CollectionReference _firestore = FirebaseFirestore.instance.collection('users');
  TextEditingController emailController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
        backgroundColor: Colors.indigo[400],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: "Enter First Name",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter Your First Name';
                  } 
                  return null;
                },
              )
            ),
             Padding(
              padding: EdgeInsets.all(20.0),
              child: TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: "Enter Last Name",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter Your Last Name';
                  } 
                  return null;
                },
              )
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Enter Email Address",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter Email Address';
                  } else if (!value.contains('@')) {
                    return 'Please enter a valid email address!';
                  }
                  return null;
                },
              )
            ),
            Padding(
                padding: EdgeInsets.all(20.0),
                child: TextFormField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Enter Password",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter Password';
                    } else if (value.length < 6) {
                      return 'Password must be atleast 6 characters!';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo)),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          isLoading = true;
                        });
                        sendToFB();
                      }
                    },
                    child: Text('Submit'),
                  ),
              )
          ],)
        )
      )
    );
  }
  void sendToFB() {
    _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
    ).then((result) { 
      _firestore
      .doc(_auth.currentUser!.uid).set({
        'username' : firstNameController.text,
        'email' : emailController.text,
        'firstname': firstNameController.text,
        'lastname': lastNameController.text,
        'isAdmin': false, 
        'regDateTime' : DateTime.now(),
        'profile_pic' : '',
      }).then((res) {
        isLoading = false;
        Navigator.pushReplacement (
          context,
          MaterialPageRoute(builder: (context) => Home(uid: result.user!.uid)),
        );
      });
    
    
    }).catchError((err) {
      showDialog(context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(err.message),
          actions: [
            TextButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ]
        );
      });
    });
  }
  @override 
  void dispose() {
    super.dispose();
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    passwordController.dispose();
  }
}