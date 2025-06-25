import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // para kIsWeb
import 'splash_page.dart'; 
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDnEIgcrjpT2yt42rFH_laBIstpZBI0jfw",
        authDomain: "boticas-toty-farma.firebaseapp.com",
        projectId: "boticas-toty-farma",
        storageBucket: "boticas-toty-farma.firebasestorage.app",
        messagingSenderId: "325469832093",
        appId: "1:325469832093:web:854a854c9ded3e2549a574",
      ),
    );
  } else {
    await Firebase.initializeApp(); // Para Android/iOS si luego lo necesitas
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Boticas Toty Farma',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: SplashPage(),
    );
  }
}
