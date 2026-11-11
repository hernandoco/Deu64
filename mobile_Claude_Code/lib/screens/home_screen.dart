import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../image_cache_manager.dart';
import '../models.dart';
import '../theme/app_theme.dart';
import 'scenes_carousel_screen.dart';

/// Pantalla principal: se muestra después del login y de cargar el tema.
class HomeScreen extends StatefulWidget {
  final TopicResponse topic;

  const HomeScreen({super.key, required this.topic});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          _HomeTab(topic: widget.topic),
          const _ComingSoon(title: 'Enseñanzas'),
          const _ComingSoon(title: 'Perfil'),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: kCardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: NavigationBar(
              selectedIndex: _tab,
              onDestinationSelected: (i) => setState(() => _tab = i),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_rounded, color: kOnSurfaceVariant),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.school_rounded, color: kOnSurfaceVariant),
                  selectedIcon: Icon(Icons.school_rounded),
                  label: 'Enseñanzas',
                ),
                NavigationDestination(
                  icon: Icon(Icons.face_rounded, color: kOnSurfaceVariant),
                  selectedIcon: Icon(Icons.face_rounded),
                  label: 'Perfil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  final TopicResponse topic;

  const _HomeTab({required this.topic});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  // TODO: conectar con un reproductor real (p. ej. just_audio) cuando exista
  // la fuente del mensaje de voz.
  bool _playing = false;

  void _openDevocional() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ScenesCarouselScreen(topic: widget.topic),
      ),
    );
  }

  void _openComingSoon(String title) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _ComingSoon(title: title, showBack: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    // Marco del pastor: +20 % respecto al tamaño anterior (0.48 -> 0.576).
    final headerHeight = height * 0.576;
    const overlap = 40.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1) Marco del niño pastor con mensaje (fondo blanco)
          Container(
            height: headerHeight,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              boxShadow: kCardShadow,
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                // espacio inferior para la tarjeta superpuesta
                padding: const EdgeInsets.fromLTRB(24, 16, 24, overlap + 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Mitad izquierda: título en varias líneas
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cita bíblica llamativa sobre el título
                          Text(
                            'Deu 6:4',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                          ),
                          const SizedBox(height: 4),
                          // Título largo: letra más pequeña y Flexible para
                          // que no desborde la mitad izquierda del encabezado.
                          Flexible(
                            child: Text(
                              'Oye papi: El Señor nuestro Dios, Jehová es... '
                              'estas palabras... me las repetirás.',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontSize: 20, height: 1.25),
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Mitad derecha: imagen del pastor
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/pastor.jpg',
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          semanticLabel: 'Niño pastor con sus ovejas',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 2) Tarjeta de iconos, superpuesta a la imagen
          Transform.translate(
            offset: const Offset(0, -overlap),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: kCardShadow,
                ),
                child: Row(
                  children: [
                    _MenuItem(
                      icon: Icons.menu_book_rounded,
                      label: 'Devocional',
                      color: kMenuDevocional,
                      onTap: _openDevocional,
                    ),
                    _MenuItem(
                      icon: Icons.help_rounded,
                      label: 'Ayuda',
                      color: kMenuAyuda,
                      onTap: () => _openComingSoon('Ayuda'),
                    ),
                    _MenuItem(
                      icon: Icons.emoji_events_rounded,
                      label: 'Premios',
                      color: kMenuPremios,
                      onTap: () => _openComingSoon('Premios'),
                    ),
                    _MenuItem(
                      icon: Icons.volunteer_activism_rounded,
                      label: 'Donación',
                      color: kMenuDonacion,
                      onTap: () => _openComingSoon('Donación'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Lo que sigue compensa el desplazamiento de -overlap.
          Transform.translate(
            offset: const Offset(0, -overlap),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  _VoiceCard(
                    playing: _playing,
                    onToggle: () => setState(() => _playing = !_playing),
                  ),
                  const SizedBox(height: 16),
                  const _VerseCard(
                    label: 'Versículo del día:',
                    verse: 'Jesús es mi pastor',
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Devocional de hoy',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _TopicCard(topic: widget.topic, onTap: _openDevocional),
                  const SizedBox(height: overlap),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Semantics(
          button: true,
          label: label,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono con color propio, sin círculo ni borde (fondo transparente)
              SizedBox(
                width: 64,
                height: 64,
                child: Icon(icon, size: 48, color: color),
              ),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoiceCard extends StatelessWidget {
  final bool playing;
  final VoidCallback onToggle;

  const _VoiceCard({required this.playing, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: kBrandGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: kCardShadow,
      ),
      child: Row(
        children: [
          IconButton.filled(
            onPressed: onToggle,
            tooltip: playing ? 'Pausar mensaje' : 'Escuchar mensaje',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primary,
              fixedSize: const Size(56, 56),
            ),
            icon: Icon(
              playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mensaje de hoy',
                  style: text.titleMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  'Toca para escuchar',
                  style: text.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const LinearProgressIndicator(
                    value: 0,
                    minHeight: 6,
                    color: Colors.white,
                    backgroundColor: Color(0x55FFFFFF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerseCard extends StatelessWidget {
  final String label;
  final String verse;

  const _VerseCard({required this.label, required this.verse});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: kCardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: kTileDevocional,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_stories_rounded, color: primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: text.labelLarge?.copyWith(color: primary)),
                const SizedBox(height: 2),
                Text(verse, style: text.titleLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final TopicResponse topic;
  final VoidCallback onTap;

  const _TopicCard({required this.topic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final thumb = topic.scenes.isNotEmpty ? topic.scenes.first.imageUrl : null;
    final placeholder = Image.asset(
      'assets/images/placeholder.jpg',
      fit: BoxFit.cover,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: kCardShadow,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: thumb == null
                      ? placeholder
                      : CachedNetworkImage(
                          imageUrl: thumb,
                          cacheManager: sceneImagesCacheManager,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => placeholder,
                          errorWidget: (_, _, _) => placeholder,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${topic.scenes.length} escenas',
                      style: text.bodyMedium?.copyWith(color: kOnSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: onTap,
                tooltip: 'Abrir devocional',
                style: IconButton.styleFrom(
                  backgroundColor: scheme.primary,
                  fixedSize: const Size(56, 56),
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  final String title;
  final bool showBack;

  const _ComingSoon({required this.title, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showBack
          ? AppBar(
              title: Text(title),
              backgroundColor: Colors.transparent,
            )
          : null,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Próximamente',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: kOnSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
