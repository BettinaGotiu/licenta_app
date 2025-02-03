import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../reusable_widgets/reusable_widget.dart';
import 'home_screen.dart';
import '../utils/color_utils.dart';
import 'signin_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Initial common words and their counts
  final Map<String, int> initialCommonWords = {
    'actually': 0,
    'basically': 0,
    'like': 0,
    'literally': 0,
    'you know': 0,
  };

  // Metoda pentru a crea un user nou in Firebase Authentication
  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailTextController.text.trim(),
          password: _passwordTextController.text,
        );

        // Update the user's display name with the username
        await userCredential.user!.updateDisplayName(
          _userNameTextController.text.trim(),
        );

        // Crearea colectiei in Cloud Firestore pentru user unde se vor salva sesiunile
        await FirebaseFirestore.instance
            .collection('user_data')
            .doc(userCredential.user!.uid)
            .set({
          'email': _emailTextController.text.trim(),
          'username': _userNameTextController.text.trim(),
          'commonWordCounts': initialCommonWords, // Salvam cuvintele comune
        }); // Userul are un UID unic si legam UID-ul pentru user_data

        // Navigate to HomeScreen upon successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'email-already-in-use') {
          message = 'This email is already in use.';
        } else if (e.code == 'invalid-email') {
          message = 'The email address is invalid.';
        } else if (e.code == 'weak-password') {
          message = 'The password is too weak.';
        } else {
          message = 'Registration failed. Please try again.';
        }
        _showErrorDialog(message);
      } catch (e) {
        _showErrorDialog('An unexpected error occurred. Please try again.');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Up Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove the back arrow
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF3539AC), // Darker blue
              Color(0xFF11BDE3), // Lighter blue
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(20, 60, 20, 0), // Adjusted padding
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  // Stylish Text above the logo
                  Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 28, // Adjusted font size
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      fontFamily: 'Roboto', // Use a modern font
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black45,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 10, // Reduced space between text and logo
                  ),
                  // Logo image
                  Image.asset(
                    "assets/images/cleartalk.png",
                    height: 250, // Adjust the height as needed
                    width: 250, // Adjust the width as needed
                  ),
                  const SizedBox(
                    height: 10, // Reduced space between logo and motto
                  ),
                  // Stylish Text below the logo
                  Text(
                    'Speak more confidently in public',
                    style: TextStyle(
                      fontSize: 20, // Adjusted font size
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      fontFamily: 'Roboto', // Use a modern font
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black45,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20), // Reduced space between elements
                  reusableTextField(
                    "Enter UserName",
                    Icons.person_outline,
                    false,
                    _userNameTextController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15), // Reduced space between elements
                  reusableTextField(
                    "Enter Email Id",
                    Icons.email_outlined,
                    false,
                    _emailTextController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[^@]+@[^@]+\.[^@]+',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15), // Reduced space between elements
                  reusableTextField(
                    "Enter Password",
                    Icons.lock_outlined,
                    true,
                    _passwordTextController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15), // Reduced space between elements
                  firebaseUIButton(context, "Sign Up", _signUp),
                  const SizedBox(height: 15), // Reduced space between elements
                  // Sign In option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.white70),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SigninScreen()),
                          );
                        },
                        child: const Text(
                          " Sign In",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
