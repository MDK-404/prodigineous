import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prodigenious/services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _retypePasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureRetypePassword = true;
  bool _loading = false;

  String email = '';
  String username = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  _fetchUserData() async {
    setState(() {
      _loading = true;
    });

    final userData = await UserService().fetchUserData();
    setState(() {
      email = userData['email']!;
      username = userData['username']!;
      _usernameController.text = username;
      _loading = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _changePassword() async {
    String currentPassword = _currentPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String retypePassword = _retypePasswordController.text.trim();

    if (newPassword.isEmpty ||
        retypePassword.isEmpty ||
        currentPassword.isEmpty) {
      _showErrorDialog("All fields are required.");
      return;
    }
    if (currentPassword == newPassword) {
      _showErrorDialog("You can't use Your old password.");
      return;
    }

    if (newPassword != retypePassword) {
      _showErrorDialog("Passwords doesn't match.");
      return;
    }

    try {
      await UserService().changePassword(currentPassword, newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password changed successfully")),
      );
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _retypePasswordController.clear();

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void _updateUsername() async {
    String newUsername = _usernameController.text.trim();

    if (newUsername.isEmpty) {
      _showErrorDialog("Username cannot be empty.");
      return;
    }

    try {
      await UserService().updateUsername(newUsername);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Username updated successfully")),
      );

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile",
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.deepPurpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: TextEditingController(text: email),
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: "Username",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateUsername,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple),
                      child:
                          Text("Save", style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Change Password",
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrentPassword,
                      decoration: InputDecoration(
                        labelText: "Current Password",
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureCurrentPassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _obscureCurrentPassword =
                                  !_obscureCurrentPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      decoration: InputDecoration(
                        labelText: "New Password",
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _retypePasswordController,
                      obscureText: _obscureRetypePassword,
                      decoration: InputDecoration(
                        labelText: "Retype New Password",
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureRetypePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _obscureRetypePassword = !_obscureRetypePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _changePassword,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple),
                      child: Text("Change Password",
                          style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot_password');
                      },
                      child: Text("Forgot Password?"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
