import 'package:flutter/material.dart';
import 'screens/loading_screen.dart';

void main() {
  runApp(const Deu64App());
}

class Deu64App extends StatelessWidget {
  const Deu64App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deu64',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const LoadingScreen(),
    );
  }
}