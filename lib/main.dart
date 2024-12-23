import 'package:flutter/material.dart';
//import '../pages/speech_to_text.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/signin_screen.dart'; // Importă pagina de SignIn

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech to Text Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SigninScreen(), // Ecranul inițial este SignInScreen
    );
  }
}
