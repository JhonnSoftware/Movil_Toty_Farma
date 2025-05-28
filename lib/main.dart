import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'splash_page.dart'; // Asegúrate de que este archivo está en la misma carpeta o ajusta el import
import 'login_page.dart';  

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializar Firebase

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
      home: SplashPage(), // Mostrar primero el SplashPage
    );
  }
}
