import 'package:flutter/material.dart';
import '../l10n/l10n.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;

  const ResultScreen({super.key, required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(L10n.t('result.title')), centerTitle: true),
      body: Center(
        child: Text(L10n.t('result.score', {'score': score, 'total': total}), style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}