import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:prodigenious/services/notificaiton_service.dart';
import 'package:prodigenious/view/forgot_password_screen.dart';
import 'package:prodigenious/view/home_screen.dart';
import 'package:prodigenious/view/notification_scree.dart';
import 'package:prodigenious/viewmodel/auth_view_model.dart';
import 'package:provider/provider.dart';
import 'view/splash_screen.dart'; // Import SplashScreen
import 'view/signup_screen.dart';
import 'view/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await requestExactAlarmPermission();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/', // SplashScreen ko initial route banaya
        routes: {
          '/': (context) => SplashScreen(), // Pehle Splash Screen aayegi
          '/signup': (context) => SignupScreen(),
          '/login': (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),
          '/forgot_password': (context) => ForgotPasswordScreen(),
          '/notifications': (context) => NotificationsScreen(),
        },
      ),
    );
  }
}
