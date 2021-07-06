import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messageboard/screens/home/home.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[400],
        elevation: 0.0,
        title: Text('Sign in'),
      ),
      body: 
      Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(children: <Widget> [
            Padding(
              padding: EdgeInsets.all(20),
              child: TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Enter Email Address",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if(value!.isEmpty) {
                    return 'Enter Email Address';
                  } else if (!value.contains('@')) {
                    return 'Enter a valid Email Address';
                  }
                  return null;
                },
              )
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: TextFormField(
                obscureText: true,
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Enter Password",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if(value!.isEmpty) {
                    return 'Enter Password';
                  } else if (value.length < 6) {
                    return 'Password must be 6 characters or more!';
                  }
                  return null;
                },
              )
            ),
            Padding (
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
                      loginFB();
                    }
                  },
                  child: Text('Submit'),
                )
            )
          ]
          )
        )
      ),
     
    );
  }

  @override
    void initState() {
      emailController.text = '';
      passwordController.text = '';
      super.initState();
    }

  void loginFB() {
    _auth.signInWithEmailAndPassword(
      email: emailController.text, 
      password: passwordController.text
    ).then((result) {
      isLoading = false;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home(uid: result.user!.uid)),
      );
    }).catchError((err) {
      print(err.message);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(err.message),
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
    });
  }
}