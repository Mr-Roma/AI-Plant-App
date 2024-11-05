import 'package:ai_plant_app/widgets/login/button.dart';
import 'package:ai_plant_app/widgets/login/textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;

  const RegisterPage({Key? key, required this.onTap}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void register() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    try {
      if (confirmPasswordController.text == passwordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);
        Navigator.pop(context); // Close loading dialog
        // Optionally, you can navigate to another screen upon successful registration
      } else {
        // Show error message
        showErrorMessage('password-mismatch');
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close loading dialog
      // Display error message
      showErrorMessage(e.code);
    }
  }

  void showErrorMessage(String errorCode) {
    String errorMessage;
    switch (errorCode) {
      case 'email-already-in-use':
        errorMessage = 'Email is already in use. Please use a different email.';
        break;
      case 'invalid-email':
        errorMessage = 'Invalid email address. Please enter a valid email.';
        break;
      case 'weak-password':
        errorMessage = 'Password is too weak. Please use a stronger password.';
        break;
      case 'password-mismatch':
        errorMessage =
            'Passwords do not match. Please enter matching passwords.';
        break;
      default:
        errorMessage = 'An unexpected error occurred. Please try again later.';
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.black),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                // Logo
                const Icon(
                  Icons.lock,
                  size: 100,
                  color: Color.fromRGBO(98, 193, 114, 5),
                ),

                const SizedBox(
                  height: 50,
                ),

                // Welcome message
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w900,
                    ),
                    children: [
                      TextSpan(text: 'W E L C O M E  T O'),
                      TextSpan(
                        text: '  -  G R E E N  A P P',
                        style: TextStyle(
                          color: Color.fromRGBO(98, 193, 114, 5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                // Username TextField
                MyTextField(
                  controller: emailController,
                  hintText: 'Username',
                  obscureText: false,
                ),
                const SizedBox(
                  height: 10,
                ),

                // Password TextField
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(
                  height: 10,
                ),

                // Confirm Password
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),

                const SizedBox(
                  height: 20,
                ),

                // Register Button
                MyButton(
                  text: 'Register',
                  onTap: register,
                ),

                const SizedBox(
                  height: 20,
                ),
                Text(
                  'Already have an account?',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(
                  height: 10,
                ),

                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[600],
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Log In now',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[600],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
