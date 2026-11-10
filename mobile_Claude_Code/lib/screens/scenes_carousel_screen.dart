import 'package:flutter/material.dart';

import '../models.dart';
import 'start_questions_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../image_cache_manager.dart';



class ScenesCarouselScreen extends StatefulWidget {
  final TopicResponse topic;

  const ScenesCarouselScreen({super.key, required this.topic});

  @override
  State<ScenesCarouselScreen> createState() => _ScenesCarouselScreenState();
}

class _ScenesCarouselScreenState extends State<ScenesCarouselScreen> {
  final _controller = PageController();
  int _index = 0;

  bool _navigated = false;

/* version sin pantalla de boton
  void _goToQuestions() {
    if (_navigated) return;
    _navigated = true;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizCarouselScreen(topicId: widget.topic.topicId),
      ),
    );
  }
*/

  void _goToQuestions() {
    if (_navigated) return;
    _navigated = true;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => StartQuestionsScreen(topicId: widget.topic.topicId),
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
          /*Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                // Mantengo tu lógica, pero ojo: en muchos Android no hay overscroll real.
                if (notification is ScrollEndNotification) {
                  final m = notification.metrics;
                  final atLastPage = _index == lastIndex;

                  // Intento detectar "empujón" hacia adelante en la última página.
                  // En algunos dispositivos m.pixels nunca supera maxScrollExtent,
                  // por eso también dejamos un botón explícito abajo.
                  final attemptedForwardPastEnd = m.pixels >= m.maxScrollExtent + 8;

                  if (atLastPage && attemptedForwardPastEnd) {
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
                  final isLast = i == lastIndex;

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
                                  'assets/images/placeholder.jpg',
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
                        const SizedBox(height: 12),

                        // UX más confiable: botón explícito al final del tema
/*                        if (isLast) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Cuando estés listo, comienza las preguntas.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _goToQuestions,
                              child: const Text('Comenzar preguntas'),
                            ),
                          ),
                        ],*/
                      ],
                    ),
                  );
                },
              ),
            ),
          ),*/

          Expanded(
            child: Listener(
              onPointerMove: (event) {
                final scenes = widget.topic.scenes;
                final lastIndex = scenes.length - 1;

                // En la última página, si el usuario arrastra hacia la izquierda
                // (delta.dx negativo) significa que quiere "avanzar".
                final atLastPage = _index == lastIndex;
                final draggingForward = event.delta.dx < -6;

                if (atLastPage && draggingForward) {
                  _goToQuestions();
                }
              },
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.topic.scenes.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final s = widget.topic.scenes[i];
                  final isLast = i == widget.topic.scenes.length - 1;

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
                            child: CachedNetworkImage(
                              cacheManager: sceneImagesCacheManager,
                              imageUrl: s.imageUrl,
                              fit: BoxFit.contain,
                              progressIndicatorBuilder: (_, __, ___) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (_, __, ___) => Image.asset(
                                'assets/images/placeholder.jpg',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          s.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),

                        if (isLast) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Desliza una vez más para ir a preguntas',
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}