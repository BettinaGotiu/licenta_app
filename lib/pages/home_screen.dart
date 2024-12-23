import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'signin_screen.dart';
import '../reusable_widgets/reusable_widget.dart';
import 'speech_to_text.dart'; // Importă pagina SpeechToTextPage

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logout Button - Signs out the user
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  print("Signed Out Successfully");
                  // Navigate to SignInScreen after successful sign out
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SigninScreen(),
                    ),
                    (route) => false, // Clear navigation stack
                  );
                } catch (e) {
                  // Handle sign-out error
                  print("Error signing out: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to sign out: $e")),
                  );
                }
              },
              child: const Text(
                "Logout",
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            // Button to navigate to SpeechToTextPage
            firebaseUIButton(context, "Go to Speech to Text", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SpeechToTextPage(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
