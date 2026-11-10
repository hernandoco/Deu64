import 'package:flutter/material.dart';

import '../api.dart';
import '../models.dart';
import 'result_screen.dart';

class QuizCarouselScreen extends StatefulWidget {
  final String topicId;
  const QuizCarouselScreen({super.key, required this.topicId});

  @override
  State<QuizCarouselScreen> createState() => _QuizCarouselScreenState();
}

class _QuizCarouselScreenState extends State<QuizCarouselScreen> {
  final _pageCtrl = PageController();
  int _index = 0;

  bool _loading = true;
  String? _error;
  List<Question> _questions = [];

  // null = sin responder, 0/1/... = opción elegida
  List<int?> _selected = [];

  int get _score {
    int s = 0;
    for (int i = 0; i < _questions.length; i++) {
      final sel = _selected[i];
      if (sel == null) continue;
      if (_questions[i].options[sel].isCorrect) s++;
    }
    return s;
  }

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final api = ApiClient();
      final resp = await api.fetchQuestions(widget.topicId);

      setState(() {
        _questions = resp.questions;
        _selected = List<int?>.filled(_questions.length, null);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _prev() {
    if (_index <= 0) return;
    _pageCtrl.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  void _next() {
    if (_index < _questions.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(score: _score, total: _questions.length),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: Center(child: Text(_error!)),
      );
    }
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('No hay preguntas para este tema.')),
      );
    }

    final isFirst = _index == 0;
    final isLast = _index == _questions.length - 1;
//    final selectedCurrent = _selected[_index];// ya no se necesita porque se puede devolver

    return Scaffold(
      appBar: AppBar(
        title: Text('Pregunta ${_index + 1}/${_questions.length}'),
      ),
      body: PageView.builder(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _questions.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (_, i) {
          final q = _questions[i];
          final sel = _selected[i];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  q.question,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (q.recommendation.isNotEmpty)
                  Text(
                    q.recommendation,
                    style: const TextStyle(color: Colors.black54),
                  ),
                const SizedBox(height: 16),
                ...List.generate(q.options.length, (optIndex) {
                  final opt = q.options[optIndex];
                  return Card(
                    child: RadioListTile<int>(
                      value: optIndex,
                      groupValue: sel,
                      onChanged: (v) {
                        setState(() => _selected[i] = v);
                      },
                      title: Text(opt.text),
                    ),
                  );
                }),
                const Spacer(),

                // Botones Anterior / Siguiente
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isFirst ? null : _prev,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.red.shade200,
                          disabledForegroundColor: Colors.white70,
                        ),
                        child: const Text('Anterior'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        // Solo exigir selección para avanzar desde la pregunta actual //cambiado para devolver sin responder 
                        //onPressed: selectedCurrent == null ? null : _next,
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.orange.shade200,
                          disabledForegroundColor: Colors.white70,
                        ),
                        child: Text(isLast ? 'Finalizar' : 'Siguiente'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }
}