import 'package:flutter/material.dart';

import '../models.dart';
import 'result_screen.dart';

class QuizCarouselScreen extends StatefulWidget {
  final List<Question> questions;
  const QuizCarouselScreen({super.key, required this.questions});

  @override
  State<QuizCarouselScreen> createState() => _QuizCarouselScreenState();
}

class _QuizCarouselScreenState extends State<QuizCarouselScreen> {
  int _index = 0;

  // null = sin responder, 0/1 = opción elegida
  late final List<int?> _selected = List<int?>.filled(widget.questions.length, null);

  int get _score {
    int s = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      final sel = _selected[i];
      if (sel == null) continue;
      if (widget.questions[i].options[sel].isCorrect) s++;
    }
    return s;
  }

  Future<void> _showFeedbackDialog(bool correct) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(correct ? 'Correcto' : 'Incorrecto'),
        content: const Text('Toca OK para continuar.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _selectOption(int qIndex, int optIndex) async {
    setState(() {
      _selected[qIndex] = optIndex; // permite re-responder si vuelve atrás
    });

    final correct = widget.questions[qIndex].options[optIndex].isCorrect;
    await _showFeedbackDialog(correct);

    // (24 = B) si respondió la última pregunta, termina
    if (!mounted) return;
    if (qIndex == widget.questions.length - 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ResultScreen(score: _score, total: widget.questions.length)),
      );
    }
  }

  void _onPageChanged(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final qs = widget.questions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preguntas'),
        centerTitle: true,
        actions: [Padding(padding: const EdgeInsets.only(right: 12), child: Center(child: Text('Puntos: $_score')))],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: qs.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, i) {
                final q = qs[i];
                final selectedOpt = _selected[i];

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(q.question, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                        q.recommendation,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(2, (optIdx) {
                        final opt = q.options[optIdx];
                        final isSelected = selectedOpt == optIdx;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FilledButton.tonal(
                            onPressed: () => _selectOption(i, optIdx),
                            style: FilledButton.styleFrom(
                              side: isSelected ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2) : null,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Text(opt.text),
                            ),
                          ),
                        );
                      }),
                      const Spacer(),
                      const Text('Desliza para cambiar de pregunta', textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              },
            ),
          ),
          _Dots(current: _index, total: qs.length),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int current;
  final int total;
  const _Dots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final selected = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: selected ? 10 : 8,
          height: selected ? 10 : 8,
          decoration: BoxDecoration(
            color: selected ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}