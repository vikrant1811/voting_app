import 'package:app_voting/screens/info_screen.dart';
import 'package:app_voting/screens/login_screen.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Create an Account',
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30.0),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                  onChanged: (val) {
                    setState(() => email = val);
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Password',labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val!.length < 6 ? 'Enter a password 6+ chars long' : null,
                  obscureText: true,
                  onChanged: (val) {
                    setState(() => password = val);
                  },
                ),
                const SizedBox(height: 30.0),
                ElevatedButton(

                  style: ElevatedButton.styleFrom(

                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    backgroundColor: Colors.blueGrey.shade300,
                  ),
                  child: const Text('Sign Up', style: TextStyle(fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black

                  )),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      dynamic result = await _auth.registerWithEmailAndPassword(email, password);
                      if (result == null) {
                        setState(() => error = 'Please supply a valid email');
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const InfoScreen()),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    const Text("Already have account ??",style: TextStyle(
                        fontSize: 15,fontWeight: FontWeight.bold
                    ),),
                    TextButton.icon(
                      icon: const Icon(Icons.person, color: Colors.black),
                      label: const Text('Login here', style: TextStyle(
                          fontSize: 16,
                          color: Colors.black)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                    ),
                  ],
                ),
                Text(
                  error,
                  style: const TextStyle(color: Colors.red, fontSize: 14.0),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
