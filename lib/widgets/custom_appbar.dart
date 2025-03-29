import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight); // AppBar height

  Future<void> signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut(); // Google SignOut
    await FirebaseAuth.instance.signOut(); // Firebase SignOut
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.deepPurpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/logo.png', height: 50),
        ],
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.menu), // Hamburger Icon
        onPressed: () {
          showMenu(
            context: context,
            position:
                RelativeRect.fromLTRB(0, 50, 0, 0), // Positioning the menu
            items: [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text("Logout"),
                  onTap: () {
                    signOut();
                    Navigator.pop(context); // Close menu
                    Navigator.pushReplacementNamed(
                        context, '/login'); // Navigate to Login
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
