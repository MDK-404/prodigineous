import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        checkUserLoginStatus();
      }
    });
  }

  void checkUserLoginStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3D0087),
              Color(0xFFB45DE7),
              Color(0xFFDC9FFF),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 150,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'rodi',
                        style: GoogleFonts.kenia(
                            fontSize: 64, color: Colors.white),
                      ),
                      TextSpan(
                        text: 'genius',
                        style: GoogleFonts.kenia(
                            fontSize: 64, color: Color(0xFFF6D360)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'AI Task Manager',
              style: GoogleFonts.jockeyOne(fontSize: 64, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              'Welcome to Prodogenius!',
              style: GoogleFonts.jockeyOne(fontSize: 32, color: Colors.white),
            ),
            SizedBox(height: 20),
            Image.asset('assets/robot.png', height: 100),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFFA16DE0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Prioritize tasks, meet deadlines, and \nachieve more with AI-powered scheduling!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jockeyOne(
                    fontWeight: FontWeight.w400,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Start Managing your Tasks Now!',
              style:
                  GoogleFonts.jockeyOne(fontSize: 32, color: Color(0xFFBB62FF)),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFB45DE7),
                    Color(0xFFDC9FFF),
                  ],
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    Navigator.pushReplacementNamed(context, '/home');
                  } else {
                    Navigator.pushNamed(context, '/signup');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Next',
                  style:
                      GoogleFonts.jockeyOne(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
