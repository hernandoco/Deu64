import 'package:flutter/material.dart';

import '../api.dart';
import '../models.dart';
import '../theme/app_theme.dart';

/// Oración modelo: texto de la oración y los versículos de apoyo.
class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  late Future<PrayerResponse> _future = ApiClient().fetchPrayer();

  void _retry() => setState(() => _future = ApiClient().fetchPrayer());

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oración modelo'),
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<PrayerResponse>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || !snap.hasData) {
            return _LoadError(
              message: 'No se pudo cargar la oración.',
              onRetry: _retry,
            );
          }
          final prayer = snap.data!;
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
                        Icon(
                          Icons.volunteer_activism_rounded,
                          color: primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(prayer.title, style: text.titleLarge),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      prayer.prayer,
                      style: text.bodyLarge?.copyWith(
                        fontSize: 18,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (prayer.verses.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Versículos de apoyo', style: text.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final v in prayer.verses)
                      Chip(
                        avatar: Icon(
                          Icons.auto_stories_rounded,
                          size: 18,
                          color: primary,
                        ),
                        label: Text(v),
                        backgroundColor: Colors.white,
                      ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
