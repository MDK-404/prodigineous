import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:prodigenious/view/dashboard_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  Future<void> signOut(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userEmail = currentUser?.email ?? 'unknown';

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
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(
            Icons.menu,
            color: Colors.white,
          ),
          onPressed: () {
            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(10, 50, 0, 0),
              items: [
                PopupMenuItem(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.person, color: Colors.white),
                          title: Text("Edit Profile",
                              style: TextStyle(color: Colors.white)),
                          onTap: () {
                            Navigator.pop(context); // Close menu
                            Navigator.pushNamed(context, '/profile');
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.dashboard, color: Colors.white),
                          title: Text("Dashboard",
                              style: TextStyle(color: Colors.white)),
                          onTap: () {
                            Navigator.pop(context); // Close menu
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TaskDashboardScreen(userEmail: userEmail),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.insights, color: Colors.white),
                          title: Text("Insights",
                              style: TextStyle(color: Colors.white)),
                          onTap: () {
                            Navigator.pop(context); // Close menu
                            Navigator.pushNamed(
                                context, '/productivity_screen');
                          },
                        ),
                        Divider(color: Colors.white54),
                        ListTile(
                          leading: Icon(Icons.logout, color: Colors.white),
                          title: Text("Logout",
                              style: TextStyle(color: Colors.white)),
                          onTap: () {
                            signOut(context);
                            Navigator.pop(context);
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
