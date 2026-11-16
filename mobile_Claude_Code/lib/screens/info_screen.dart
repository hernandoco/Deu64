import 'package:flutter/material.dart';

import '../models.dart';
import '../theme/app_theme.dart';

/// Pantalla de contenido de las opciones del menú (Ayuda, Premios,
/// Donaciones, Enseñanzas y Ministerio): título, texto y lista de puntos,
/// tal como los manda el backend.
class InfoScreen extends StatefulWidget {
  /// Título de la barra superior.
  final String title;

  /// Pide el contenido (un método de ApiClient).
  final Future<InfoContent> Function() load;

  /// Icono de la tarjeta y de cada punto de la lista.
  final IconData icon;

  /// Color del icono y de los puntos.
  final Color color;

  /// Solo para las pestañas de la barra inferior, que no tienen a dónde
  /// volver: la flecha de la barra superior hace esto (ir al Home).
  final VoidCallback? onBack;

  const InfoScreen({
    super.key,
    required this.title,
    required this.load,
    required this.icon,
    required this.color,
    this.onBack,
  });

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  late Future<InfoContent> _future = widget.load();

  void _retry() => setState(() {
    _future = widget.load();
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        leading: widget.onBack == null
            ? null
            : BackButton(onPressed: widget.onBack),
      ),
      body: FutureBuilder<InfoContent>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || !snap.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'No se pudo cargar el contenido.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _retry,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }
          final info = snap.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF1E6FF), Color(0xFFFFF1DC)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: kCardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(widget.icon, color: widget.color, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            info.title,
                            style: sectionTitleStyle(widget.color),
                          ),
                        ),
                      ],
                    ),
                    if (info.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        info.subtitle,
                        style: text.titleMedium?.copyWith(
                          color: kOnSurfaceVariant,
                        ),
                      ),
                    ],
                    if (info.body.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        info.body,
                        style: text.bodyLarge?.copyWith(
                          fontSize: 18,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              for (final item in info.items) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: kCardShadow,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(widget.icon, color: widget.color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: text.bodyLarge?.copyWith(height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
