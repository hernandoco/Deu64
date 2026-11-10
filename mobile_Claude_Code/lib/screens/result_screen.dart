import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;

  const ResultScreen({super.key, required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado'), centerTitle: true),
      body: Center(
        child: Text('Puntos: $score/$total', style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}