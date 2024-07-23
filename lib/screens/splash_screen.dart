import 'dart:async';

import 'package:app_voting/screens/login_screen.dart';
import 'package:flutter/material.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTimer()
  {
    Timer(const Duration(seconds: 3), () async {
      //send user to authGate
      Navigator.push(context, MaterialPageRoute(builder: (c) =>  LoginScreen()));

    });
  }
  @override
  void initState() {
    super.initState();
    startTimer();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/every-vote-counts-button.png"),
              const Text("vote for right!!",style: TextStyle(fontSize:35,
                  fontWeight:FontWeight.w700),),
            ],
          ),

        ),
      ),
    );
  }
}
