import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../api.dart';
import '../audio_cache_manager.dart';
import '../image_cache_manager.dart';
import '../models.dart';
import '../theme/app_theme.dart';
import '../widgets/menu_illustrations.dart';
import 'challenge_screen.dart';
import 'prayer_screen.dart';
import 'quiz_carousel_screen.dart';
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
  final _api = ApiClient();

  // Versículo del día (backend). Null mientras carga o si falla sin caché.
  VerseResponse? _verse;

  // Mensaje de hoy en audio.
  AudioMessageResponse? _audio;
  Future<void>? _audioFetch; // petición en curso de los datos del audio
  AudioPlayer? _player; // se crea la primera vez que se pulsa play
  bool _audioReady = false;
  bool _audioLoading = false;
  bool _playing = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadDailyContent();
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _loadDailyContent() async {
    _api
        .fetchVerse()
        .then((v) {
          if (mounted) setState(() => _verse = v);
        })
        .catchError((_) {});
    _audioFetch = _api
        .fetchAudioMessage()
        .then((a) {
          if (mounted) setState(() => _audio = a);
          // Descarga el audio en segundo plano para que ya esté guardado
          // (y suene sin esperar ni sin red) cuando el usuario pulse play.
          if (a.audioUrl.isNotEmpty) getAudioFile(a.audioUrl).ignore();
        })
        .catchError((_) {});
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _togglePlay() async {
    if (_audioLoading) return; // ya hay una carga en curso
    // Si el usuario pulsa play antes de que lleguen los datos del audio (sin
    // red tardan hasta que vence el timeout y se usa la copia guardada), se
    // espera a esa petición en vez de decir que no está disponible.
    if (_audio == null && _audioFetch != null) {
      setState(() => _audioLoading = true);
      await _audioFetch;
      if (!mounted) return;
      setState(() => _audioLoading = false);
    }
    final audio = _audio;
    if (audio == null || audio.audioUrl.isEmpty) {
      _showSnack('El mensaje de hoy aún no está disponible.');
      return;
    }

    try {
      var player = _player;
      if (player == null) {
        player = AudioPlayer();
        _player = player;
        player.playerStateStream.listen((st) {
          if (st.processingState == ProcessingState.completed) {
            player!.pause();
            player.seek(Duration.zero);
          }
          if (mounted) {
            setState(() {
              _playing =
                  st.playing && st.processingState != ProcessingState.completed;
            });
          }
        });
        player.positionStream.listen((p) {
          if (mounted) setState(() => _position = p);
        });
        player.durationStream.listen((d) {
          if (mounted) setState(() => _duration = d ?? Duration.zero);
        });
      }

      if (!_audioReady) {
        setState(() => _audioLoading = true);
        // Se reproduce desde el archivo guardado; si no hay copia local ni se
        // pudo descargar, se transmite directamente desde el backend.
        final file = await getAudioFile(audio.audioUrl);
        if (file != null) {
          await player.setFilePath(file.path);
        } else {
          await player.setUrl(audio.audioUrl);
        }
        _audioReady = true;
        if (mounted) setState(() => _audioLoading = false);
      }

      if (player.playing) {
        await player.pause();
      } else {
        await player.play();
      }
    } catch (_) {
      if (mounted) setState(() => _audioLoading = false);
      _showSnack('No se pudo reproducir el mensaje. Revisa tu conexión.');
    }
  }

  // Devocional: solo la historia (escenas). Se abre con push para poder
  // volver al Home con la flecha atrás.
  void _openDevocional() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScenesCarouselScreen(topic: widget.topic),
      ),
    );
  }

  // Preguntas del devocional: frame aparte, independiente de la historia.
  void _openPreguntas() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizCarouselScreen(topicId: widget.topic.topicId),
      ),
    );
  }

  void _openOracion() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PrayerScreen()));
  }

  void _openReto() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ChallengeScreen()));
  }

  void _openComingSoon(String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ComingSoon(title: title, showBack: true),
      ),
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
                // Tarjeta de color + imagen del pastor unidas en un solo
                // bloque; la tarjeta se desvanece sobre el borde de la foto.
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFF1E6FF), Color(0xFFFFF1DC)],
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(14, 14, 6, 12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Text.rich(
                                    const TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'GochiHand',
                                        fontSize: 22.5,
                                        height: 1.3,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF4A2C8F),
                                      ),
                                      children: [
                                        TextSpan(text: 'Y estas '),
                                        TextSpan(
                                          text: 'palabras ',
                                          style: TextStyle(
                                            color: Color(0xFFE8590C),
                                          ),
                                        ),
                                        TextSpan(text: 'que te mando hoy, '),
                                        TextSpan(
                                          text: 'estarán ',
                                          style: TextStyle(
                                            color: Color(0xFF0B8A7A),
                                          ),
                                        ),
                                        TextSpan(text: 'sobre tu '),
                                        TextSpan(
                                          text: 'corazón',
                                          style: TextStyle(
                                            color: Color(0xFFD6336C),
                                          ),
                                        ),
                                        TextSpan(text: '; y las '),
                                        TextSpan(
                                          text: 'repetirás ',
                                          style: TextStyle(
                                            color: Color(0xFFE8590C),
                                          ),
                                        ),
                                        TextSpan(text: 'a tus '),
                                        TextSpan(
                                          text: 'hijos',
                                          style: TextStyle(
                                            color: Color(0xFF0B8A7A),
                                          ),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // Cita al final del título, alineada a la derecha
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Deu 6:4',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: const Color(0xFF6A3FD0),
                                          fontFamily: 'GochiHand',
                                          fontSize: 18.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Mitad derecha: pastor animado (PNG sin fondo)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                            child: Image.asset(
                              'assets/images/pastor_infantil.png',
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              semanticLabel: 'Pastor animado con su ovejita',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                      illustration: const BookIllustration(),
                      label: 'Devocional',
                      background: kMenuDevocional,
                      onTap: _openDevocional,
                    ),
                    _MenuItem(
                      illustration: const HelpIllustration(),
                      label: 'Ayuda',
                      background: kMenuAyuda,
                      onTap: () => _openComingSoon('Ayuda'),
                    ),
                    _MenuItem(
                      illustration: const TrophyIllustration(),
                      label: 'Premios',
                      background: kMenuPremios,
                      onTap: () => _openComingSoon('Premios'),
                    ),
                    _MenuItem(
                      illustration: const PiggyIllustration(),
                      label: 'Donación',
                      background: kMenuDonacion,
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
                    loading: _audioLoading,
                    title: _audio?.title,
                    progress: _duration.inMilliseconds > 0
                        ? (_position.inMilliseconds / _duration.inMilliseconds)
                              .clamp(0.0, 1.0)
                        : 0,
                    onToggle: _togglePlay,
                  ),
                  const SizedBox(height: 16),
                  _VerseCard(
                    label: 'Versículo del día:',
                    verse: _verse?.verse ?? '...',
                    description: _verse?.description,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Devocional de hoy',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _TopicCard(topic: widget.topic, onTap: _openDevocional),
                  const SizedBox(height: 24),
                  Text(
                    'Preguntas del devocional',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _TopicCard(
                    topic: widget.topic,
                    onTap: _openPreguntas,
                    subtitle: 'Responde y gana puntos',
                    tooltip: 'Abrir preguntas',
                    icon: Icons.quiz_rounded,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Oración modelo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _TopicCard(
                    topic: widget.topic,
                    onTap: _openOracion,
                    subtitle: 'Ora junto con el pastor',
                    tooltip: 'Abrir oración modelo',
                    icon: Icons.volunteer_activism_rounded,
                    iconColors: const [Color(0xFFF48FB1), Color(0xFFD6336C)],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Reto del día',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _TopicCard(
                    topic: widget.topic,
                    onTap: _openReto,
                    subtitle: 'Un pequeño desafío para hoy',
                    tooltip: 'Abrir reto del día',
                    icon: Icons.flag_rounded,
                    iconColors: const [Color(0xFF4DB6AC), Color(0xFF00897B)],
                  ),
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
  final CustomPainter illustration;
  final String label;
  final Color background;
  final VoidCallback onTap;

  const _MenuItem({
    required this.illustration,
    required this.label,
    required this.background,
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
              // Ilustración 3D a todo color sobre cuadro pastel redondeado,
              // con degradado suave y borde blanco (como el modelo).
              Container(
                width: 76,
                height: 76,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.lerp(background, Colors.white, 0.6)!,
                      background,
                    ],
                  ),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Color.lerp(
                        background,
                        Colors.black,
                        0.25,
                      )!.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CustomPaint(
                  size: const Size.square(60),
                  painter: illustration,
                ),
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
  final bool loading;
  final String? title;
  final double progress;
  final VoidCallback onToggle;

  const _VoiceCard({
    required this.playing,
    required this.loading,
    required this.title,
    required this.progress,
    required this.onToggle,
  });

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
            icon: loading
                ? const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : Icon(
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
                  title ?? 'Toca para escuchar',
                  style: text.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    color: Colors.white,
                    backgroundColor: const Color(0x55FFFFFF),
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
  final String? description;

  const _VerseCard({
    required this.label,
    required this.verse,
    this.description,
  });

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
                if (description != null && description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    description!,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium?.copyWith(color: kOnSurfaceVariant),
                  ),
                ],
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
  final String? subtitle;
  final String tooltip;

  /// Si se indica, reemplaza la miniatura por un icono sobre fondo de color.
  final IconData? icon;

  /// Degradado del icono (solo aplica cuando [icon] no es nulo).
  final List<Color> iconColors;

  const _TopicCard({
    required this.topic,
    required this.onTap,
    this.subtitle,
    this.tooltip = 'Abrir devocional',
    this.icon,
    this.iconColors = const [Color(0xFFFFB74D), Color(0xFFF57C00)],
  });

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
                  child: icon != null
                      ? DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: iconColors,
                            ),
                          ),
                          child: Icon(icon, size: 48, color: Colors.white),
                        )
                      : thumb == null
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
                      subtitle ?? '${topic.scenes.length} escenas',
                      style: text.bodyMedium?.copyWith(
                        color: kOnSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: onTap,
                tooltip: tooltip,
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
          ? AppBar(title: Text(title), backgroundColor: Colors.transparent)
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
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: kOnSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
