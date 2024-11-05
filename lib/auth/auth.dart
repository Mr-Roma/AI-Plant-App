import 'package:ai_plant_app/login/login_or_register.dart';
import 'package:ai_plant_app/pages/menu/bottom_navbar_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            //User is Login
            if (snapshot.hasData) {
              return const BottomNavbar();
            }
            //User is not Login
            else {
              return const LoginOrRegister();
            }
          }),
    );
  }
}
