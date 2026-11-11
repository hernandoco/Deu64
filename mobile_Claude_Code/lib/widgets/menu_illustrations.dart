import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Ilustraciones a todo color para el menú principal, en estilo 3D "inflado"
/// como el modelo (`Modelo home screem.pdf`): cada pieza tiene degradado de
/// claro (arriba) a oscuro (abajo), un borde inferior más oscuro que le da
/// volumen y un brillo blanco.
/// Se dibujan en un lienzo de 100×100 que se escala al tamaño pedido, así no
/// hacen falta PNG/SVG ni dependencias nuevas.

Paint _fill(Color c) => Paint()
  ..color = c
  ..isAntiAlias = true;

Paint _stroke(Color c, double w) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round
  ..isAntiAlias = true;

/// Pieza con volumen: canto inferior oscuro + cara con degradado vertical.
void _puffy(Canvas c, Path path, Color top, Color bottom,
    {double depth = 4, Color? edge}) {
  c.drawPath(path.shift(Offset(0, depth)),
      _fill(edge ?? Color.lerp(bottom, Colors.black, 0.22)!));
  c.drawPath(
    path,
    Paint()
      ..isAntiAlias = true
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [top, bottom],
      ).createShader(path.getBounds()),
  );
}

/// Brillo blanco que se desvanece hacia abajo.
void _gloss(Canvas c, Rect r, {double opacity = 0.75}) {
  c.drawOval(
    r,
    Paint()
      ..isAntiAlias = true
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: opacity),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(r),
  );
}

void _shadow(Canvas c, Rect r) => c.drawOval(
      r,
      Paint()
        ..color = const Color(0x2E2B2350)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

Path _heart(Offset c, double s) => Path()
  ..moveTo(c.dx, c.dy + 0.35 * s)
  ..cubicTo(c.dx - 0.6 * s, c.dy - 0.05 * s, c.dx - 0.25 * s, c.dy - 0.55 * s,
      c.dx, c.dy - 0.2 * s)
  ..cubicTo(c.dx + 0.25 * s, c.dy - 0.55 * s, c.dx + 0.6 * s, c.dy - 0.05 * s,
      c.dx, c.dy + 0.35 * s)
  ..close();

/// Destello de cuatro puntas.
Path _sparkle(Offset c, double r) => Path()
  ..moveTo(c.dx, c.dy - r)
  ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
  ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
  ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
  ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
  ..close();

Path _star(Offset c, double r) {
  final path = Path();
  for (var i = 0; i < 10; i++) {
    final radius = i.isEven ? r : r * 0.5;
    final a = -math.pi / 2 + i * math.pi / 5;
    final p = Offset(c.dx + radius * math.cos(a), c.dy + radius * math.sin(a));
    i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
  }
  return path..close();
}

abstract class _Illustration extends CustomPainter {
  const _Illustration();

  void draw(Canvas canvas);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    draw(canvas);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Devocional: Biblia abierta morada con cruz dorada y cinta roja.
class BookIllustration extends _Illustration {
  const BookIllustration();

  @override
  void draw(Canvas canvas) {
    _shadow(canvas, const Rect.fromLTWH(12, 86, 76, 10));
    // Tapa
    final cover = Path()
      ..moveTo(6, 28)
      ..quadraticBezierTo(28, 18, 50, 28)
      ..quadraticBezierTo(72, 18, 94, 28)
      ..lineTo(94, 80)
      ..quadraticBezierTo(72, 72, 50, 82)
      ..quadraticBezierTo(28, 72, 6, 80)
      ..close();
    _puffy(canvas, cover, const Color(0xFF9C84FF), const Color(0xFF6A4BE6),
        depth: 5);
    // Páginas
    final left = Path()
      ..moveTo(11, 22)
      ..quadraticBezierTo(31, 12, 49, 22)
      ..lineTo(49, 75)
      ..quadraticBezierTo(31, 66, 11, 74)
      ..close();
    final right = Path()
      ..moveTo(89, 22)
      ..quadraticBezierTo(69, 12, 51, 22)
      ..lineTo(51, 75)
      ..quadraticBezierTo(69, 66, 89, 74)
      ..close();
    _puffy(canvas, left, Colors.white, const Color(0xFFE4DCFF),
        depth: 3, edge: const Color(0xFFC9BCF8));
    _puffy(canvas, right, Colors.white, const Color(0xFFE4DCFF),
        depth: 3, edge: const Color(0xFFC9BCF8));
    // Renglones
    for (final y in [34.0, 43.0, 52.0, 61.0]) {
      canvas.drawPath(
        Path()
          ..moveTo(57, y)
          ..quadraticBezierTo(70, y - 4, 83, y),
        _stroke(const Color(0xFFCABEFA), 3),
      );
    }
    // Cruz dorada
    final cross = Path()
      ..addRRect(RRect.fromLTRBR(26, 29, 34, 63, const Radius.circular(3)))
      ..addRRect(RRect.fromLTRBR(18, 37, 42, 45, const Radius.circular(3)));
    _puffy(canvas, cross, const Color(0xFFFFE27A), const Color(0xFFFFB300),
        depth: 2.5, edge: const Color(0xFFD98A00));
    // Cinta separadora
    final ribbon = Path()
      ..moveTo(62, 17)
      ..lineTo(71, 17)
      ..lineTo(71, 95)
      ..lineTo(66.5, 89)
      ..lineTo(62, 95)
      ..close();
    _puffy(canvas, ribbon, const Color(0xFFFF7A93), const Color(0xFFE8385A),
        depth: 2);
    _gloss(canvas, const Rect.fromLTWH(14, 20, 22, 7));
  }
}

/// Ayuda: globo de diálogo turquesa con signo de pregunta y destellos.
class HelpIllustration extends _Illustration {
  const HelpIllustration();

  @override
  void draw(Canvas canvas) {
    _shadow(canvas, const Rect.fromLTWH(16, 88, 68, 9));
    final bubble = Path.combine(
      PathOperation.union,
      Path()
        ..addRRect(RRect.fromLTRBR(6, 8, 94, 72, const Radius.circular(26))),
      Path()
        ..moveTo(24, 64)
        ..lineTo(16, 90)
        ..lineTo(48, 68)
        ..close(),
    );
    _puffy(canvas, bubble, const Color(0xFF6BE3D0), const Color(0xFF14A592),
        depth: 5);
    _gloss(canvas, const Rect.fromLTWH(16, 12, 40, 14));
    // Signo de pregunta con sombra
    TextPainter q(Color color) => TextPainter(
          text: TextSpan(
            text: '?',
            style: TextStyle(
              fontSize: 54,
              fontWeight: FontWeight.w900,
              color: color,
              height: 1,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
    final shade = q(const Color(0xFF0E7F70));
    final front = q(Colors.white);
    final pos = Offset(50 - front.width / 2, 41 - front.height / 2);
    shade.paint(canvas, pos + const Offset(0, 3));
    front.paint(canvas, pos);
    _puffy(canvas, _sparkle(const Offset(88, 8), 10), const Color(0xFFFFE680),
        const Color(0xFFFFB300), depth: 1.5);
    _puffy(canvas, _sparkle(const Offset(7, 82), 7), const Color(0xFFFFA3D6),
        const Color(0xFFFF5CB0), depth: 1.5);
  }
}

/// Premios: copa dorada con estrella roja sobre base morada.
class TrophyIllustration extends _Illustration {
  const TrophyIllustration();

  @override
  void draw(Canvas canvas) {
    _shadow(canvas, const Rect.fromLTWH(20, 89, 60, 9));
    // Asas (con canto oscuro debajo)
    for (final (dy, color) in [
      (3.0, const Color(0xFFD98A00)),
      (0.0, const Color(0xFFFFC21A)),
    ]) {
      final s = _stroke(color, 8);
      canvas.drawArc(Rect.fromLTWH(10, 20 + dy, 28, 28), math.pi / 2, math.pi,
          false, s);
      canvas.drawArc(Rect.fromLTWH(62, 20 + dy, 28, 28), -math.pi / 2,
          math.pi, false, s);
    }
    // Pie y base
    _puffy(canvas, Path()..addRect(const Rect.fromLTWH(44, 60, 12, 12)),
        const Color(0xFFFFC21A), const Color(0xFFE59400), depth: 0);
    _puffy(
        canvas,
        Path()
          ..addRRect(
              RRect.fromLTRBR(34, 68, 66, 76, const Radius.circular(3))),
        const Color(0xFF8E73FF),
        const Color(0xFF6A4BE6),
        depth: 2);
    _puffy(
        canvas,
        Path()
          ..addRRect(
              RRect.fromLTRBR(24, 75, 76, 89, const Radius.circular(5))),
        const Color(0xFF9C84FF),
        const Color(0xFF6A4BE6),
        depth: 4);
    // Copa
    final cup = Path()
      ..moveTo(22, 12)
      ..lineTo(78, 12)
      ..lineTo(78, 32)
      ..cubicTo(78, 56, 64, 64, 50, 64)
      ..cubicTo(36, 64, 22, 56, 22, 32)
      ..close();
    _puffy(canvas, cup, const Color(0xFFFFEA80), const Color(0xFFFFA800),
        depth: 4, edge: const Color(0xFFD98A00));
    _gloss(canvas, const Rect.fromLTWH(28, 16, 12, 30), opacity: 0.8);
    _puffy(canvas, _star(const Offset(52, 35), 13), const Color(0xFFFF7A93),
        const Color(0xFFE8385A),
        depth: 2.5);
    _puffy(canvas, _sparkle(const Offset(90, 8), 9), const Color(0xFFFFE680),
        const Color(0xFFFFB300), depth: 1.5);
    _puffy(canvas, _sparkle(const Offset(8, 66), 6), const Color(0xFF6BE3D0),
        const Color(0xFF14A592), depth: 1.5);
  }
}

/// Donación: alcancía de cerdito con moneda dorada de corazón.
class PiggyIllustration extends _Illustration {
  const PiggyIllustration();

  @override
  void draw(Canvas canvas) {
    _shadow(canvas, const Rect.fromLTWH(14, 88, 72, 9));
    const pinkTop = Color(0xFFFFB3CB);
    const pinkBottom = Color(0xFFFF6F9C);
    const pinkEdge = Color(0xFFD94C79);
    // Patas
    for (final x in [24.0, 60.0]) {
      _puffy(
          canvas,
          Path()
            ..addRRect(
                RRect.fromLTRBR(x, 68, x + 13, 88, const Radius.circular(5))),
          const Color(0xFFFF8FB1),
          const Color(0xFFF0558A),
          depth: 2,
          edge: pinkEdge);
    }
    // Cola
    canvas.drawPath(
      Path()
        ..moveTo(12, 54)
        ..quadraticBezierTo(0, 52, 4, 43)
        ..quadraticBezierTo(9, 37, 9, 47),
      _stroke(pinkEdge, 4),
    );
    // Oreja
    _puffy(
        canvas,
        Path()
          ..moveTo(30, 38)
          ..lineTo(34, 18)
          ..lineTo(48, 32)
          ..close(),
        const Color(0xFFFF8FB1),
        const Color(0xFFF0558A),
        depth: 2,
        edge: pinkEdge);
    // Cuerpo
    _puffy(canvas, Path()..addOval(const Rect.fromLTWH(10, 28, 78, 54)),
        pinkTop, pinkBottom,
        depth: 4, edge: pinkEdge);
    _gloss(canvas, const Rect.fromLTWH(22, 33, 30, 12), opacity: 0.8);
    // Hocico
    _puffy(canvas, Path()..addOval(const Rect.fromLTWH(78, 44, 18, 22)),
        const Color(0xFFFF8FB1), const Color(0xFFF0558A),
        depth: 2, edge: pinkEdge);
    canvas.drawOval(const Rect.fromLTWH(82.5, 50, 3.5, 7), _fill(const Color(0xFFB0164E)));
    canvas.drawOval(const Rect.fromLTWH(89, 50, 3.5, 7), _fill(const Color(0xFFB0164E)));
    // Ojo y mejilla
    canvas.drawCircle(const Offset(66, 45), 4.5, _fill(const Color(0xFF2B2350)));
    canvas.drawCircle(const Offset(67.5, 43.5), 1.6, _fill(Colors.white));
    canvas.drawCircle(const Offset(69, 58), 5.5, _fill(const Color(0x80FF4D7E)));
    // Ranura
    canvas.drawRRect(RRect.fromLTRBR(39, 29, 57, 34, const Radius.circular(2.5)),
        _fill(const Color(0xFFB0164E)));
    // Moneda con corazón
    _puffy(canvas, Path()..addOval(Rect.fromCircle(center: const Offset(48, 14), radius: 13)),
        const Color(0xFFFFEA80), const Color(0xFFFFB300),
        depth: 3, edge: const Color(0xFFD98A00));
    _puffy(canvas, _heart(const Offset(48, 15.5), 14), const Color(0xFFFF7A93),
        const Color(0xFFE8385A),
        depth: 1.5);
    _puffy(canvas, _sparkle(const Offset(88, 16), 8), const Color(0xFFFFE680),
        const Color(0xFFFFB300), depth: 1.5);
  }
}
