import 'package:flutter/material.dart';

import 'quiz_carousel_screen.dart';

class StartQuestionsScreen extends StatelessWidget {
  final String topicId;

  const StartQuestionsScreen({super.key, required this.topicId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _ThreeDButton(
            text: 'PREGUNTAS',
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => QuizCarouselScreen(topicId: topicId),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ThreeDButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const _ThreeDButton({
    required this.text,
    required this.onPressed,
  });

  @override
  State<_ThreeDButton> createState() => _ThreeDButtonState();
}

class _ThreeDButtonState extends State<_ThreeDButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    // Tamaño del "bisel" (grosor 3D)
    const double depth = 10;

    // Colores base
    const Color topColor = Color(0xFFFFA726); // naranja claro
    const Color bottomColor = Color(0xFFF57C00); // naranja más oscuro
    const Color sideShadow = Color(0xFFB85A00); // base más oscura

    final Offset translate = _pressed ? const Offset(0, depth) : Offset.zero;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(translate.dx, translate.dy, 0),
        child: Stack(
          children: [
            // Base "profundidad" (la parte de abajo que se ve cuando NO está presionado)
            Positioned(
              top: depth,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 80),
                opacity: _pressed ? 0.0 : 1.0,
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: sideShadow,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),

            // Cara principal del botón
            Container(
              height: 70,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [topColor, bottomColor],
                ),
                boxShadow: [
                  // Sombra fuerte (abajo/derecha)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  // Borde sutil para “cortar” el botón
                  color: Colors.white.withOpacity(0.18),
                  width: 1.2,
                ),
              ),
              child: Stack(
                children: [
                  // Highlight superior izquierdo (efecto “brillo”)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.35),
                              Colors.transparent,
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.35, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Texto
                  Center(
                    child: Text(
                      widget.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}