import 'package:flutter/material.dart';

import '../api.dart';
import '../models.dart';
import 'scenes_carousel_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final _api = ApiClient();
  String? _error;

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final topic = await _api.fetchTopic();
      final qs = await _api.fetchQuestions();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ScenesCarouselScreen(topic: topic, questions: qs.questions),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _error == null
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Error cargando datos:\n$_error', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _load, child: const Text('Reintentar')),
                  ],
                ),
              ),
      ),
    );
  }
}