import 'package:flutter/material.dart';
import 'screens/loading_screen.dart';
import 'theme/app_theme.dart';

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
      theme: buildKidsTheme(),
      home: const LoadingScreen(),
    );
  }
}