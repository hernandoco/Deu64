import 'package:flutter/material.dart';

import '../models.dart';
import 'quiz_carousel_screen.dart';

class ScenesCarouselScreen extends StatefulWidget {
  final TopicResponse topic;
  final List<Question> questions;

  const ScenesCarouselScreen({super.key, required this.topic, required this.questions});

  @override
  State<ScenesCarouselScreen> createState() => _ScenesCarouselScreenState();
}

class _ScenesCarouselScreenState extends State<ScenesCarouselScreen> {
  final _controller = PageController();
  int _index = 0;

  bool _navigated = false;

  void _goToQuestions() {
    if (_navigated) return;
    _navigated = true;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizCarouselScreen(questions: widget.questions),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scenes = widget.topic.scenes;
    final lastIndex = scenes.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                // Solo nos interesa el "fin" de un scroll/arrastre
                if (notification is ScrollEndNotification) {
                  // Si estamos en la última escena y el usuario intenta seguir hacia adelante,
                  // iOS/Android suelen permitir overscroll/bounce y el pixels puede superar maxScrollExtent.
                  final m = notification.metrics;
                  final atLastPage = _index == lastIndex;
                  final attemptedForwardPastEnd = m.pixels > m.maxScrollExtent;

                  if (atLastPage && attemptedForwardPastEnd) {
                    // Pasa a preguntas en el siguiente frame para evitar conflictos con el scroll
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      _goToQuestions();
                    });
                  }
                }
                return false;
              },
              child: PageView.builder(
                controller: _controller,
                itemCount: scenes.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final s = scenes[i];
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          s.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Center(
                            child: Image.network(
                              s.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) {
                                return Image.asset(
                                  'assets/images/placeholder.png',
                                  fit: BoxFit.contain,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          s.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),

                        // Mensaje opcional para guiar al usuario en la última escena:
                        if (i == lastIndex) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Desliza una vez más para comenzar las preguntas',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          _DotsIndicator(current: _index, total: scenes.length),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int current;
  final int total;

  const _DotsIndicator({required this.current, required this.total});

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