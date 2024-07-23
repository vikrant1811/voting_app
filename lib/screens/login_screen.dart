import 'package:app_voting/screens/info_screen.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
                  'Sign In',
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
                    border: OutlineInputBorder(
                    ),
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
                    border: OutlineInputBorder(
                    ),
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
                    backgroundColor: Colors.blueGrey.shade300
                  ),
                  child: const Text('Sign In', style: TextStyle(fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                      if (result == null) {
                        setState(() => error = 'Could not sign in with those credentials');
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
                    const Text("Don't have account ??     ",style: TextStyle(
                      fontSize: 16,fontWeight: FontWeight.bold
                    ),),
                    TextButton.icon(
                      icon: const Icon(Icons.person, color: Colors.black),
                      label: const Text('Register', style: TextStyle(
                        fontSize: 17,
                          color: Colors.black)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpScreen()),
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
