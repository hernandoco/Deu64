import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../api.dart';
import '../image_cache_manager.dart';
import '../models.dart';
import 'home_screen.dart';

import '../pages/login_page.dart';
import '../services/auth_service.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

class LoadingScreen extends StatefulWidget {
  /// Servicio de login que se le pasa a [LoginPage]. Si es null se usa el
  /// real (Cognito); los tests pasan uno propio.
  final AuthService? authService;

  /// Caché de las imágenes de escenas (precarga y Home). Si es null se usa
  /// [sceneImagesCacheManager]; los tests pasan una propia.
  final BaseCacheManager? imageCacheManager;

  const LoadingScreen({super.key, this.authService, this.imageCacheManager});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {  
  final _api = ApiClient();
  String? _error;
  // Antes era una variable global y quedaba con el texto de la carga anterior.
  String _status = L10n.t('loading.starting');
  // true si el usuario salió del login con "atrás": se muestra un botón para
  // volver a abrirlo (antes quedaba girando sin salida).
  bool _cancelled = false;

  BaseCacheManager get _imageCache =>
      widget.imageCacheManager ?? sceneImagesCacheManager;

  Future<void> _precacheTopicImages(TopicResponse topic) async {
    
    for (final scene in topic.scenes) {
    
      final url = scene.imageUrl;
      try {
        // Si ya está en caché no se vuelve a descargar
        final cached = await _imageCache.getFileFromCache(url);
  
 

        if (cached != null && await cached.file.exists()) continue;


        await _imageCache
            .downloadFile(url)
            .timeout(const Duration(seconds: 2));
      } catch ( e ) {
        // nunca bloquear
        debugPrint('IMG ERROR: $url -> ${e.runtimeType}: $e');
      }
    }
  }
  /* --------------------------------------------------
  Function: _load
  Description: Esta funion fue alterada para agregar el login
  sin embargo, aunque lo carga no regresa al carruserl
     --------------------------------------------------*/ 
     /*
  Future<void> _load() async {
    setState(() {
      _error = null;
      _status = L10n.t('loading.connecting');
    });

    try {
      // 1) Topic
      final topic = await _api.fetchTopic();

      setState(() {
        _status = L10n.t('loading.downloading');
      });

      // preguntas en background (recomendado)
      // ignore: unawaited_futures
      _api.fetchQuestions(topic.topicId);

      // imágenes en background
      // ignore: unawaited_futures
      _precacheTopicImages(topic);

      if (!mounted) return;

      setState(() {
        _status = L10n.t('loading.opening');
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ScenesCarouselScreen(topic: topic)),
      );

    if (!mounted) return;
    
    // ----------------------------------------------------------------------------------------------------
    // 23 sep 2026
    // Hernando Cortes
    // Llamado a la función de Login
    // ----------------------------------------------------------------------------------------------------
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
    );


    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }

  }
  */

  /* --------------------------------------------------
  Function: _load
  Description: Funcion generada por Claude para que haga login
  y despues si navegue
     --------------------------------------------------*/ 
  Future<void> _load() async {
/* Funciona bien para ller la ip
  debugPrint('=== PRUEBA RED INICIO ===');
  final uri = Uri.parse('http://192.168.2.9:8080/api/v1/leer_tema');
  final sw = Stopwatch()..start();
  try {
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    debugPrint('=== PRUEBA RED OK ${sw.elapsedMilliseconds} ms status=${res.statusCode} bytes=${res.bodyBytes.length} ===');
  } catch (e) {
    debugPrint('=== PRUEBA RED FALLO ${sw.elapsedMilliseconds} ms ${e.runtimeType}: $e ===');
  }
*/
    
    // Idioma guardado y textos de la interfaz, antes de mostrar nada.
    await L10n.init();
    if (!mounted) return;

    setState(() {
      _error = null;
      _cancelled = false;
      _status = L10n.t('loading.login');
    });

  try {
    // 0) Login primero
    final auth = await Navigator.of(context).push<AuthorizationTokenResponse>(
      MaterialPageRoute(
        builder: (_) => LoginPage(authService: widget.authService),
      ),
    );

    if (!mounted) return;

    if (auth == null) {
      setState(() {
        _status = L10n.t('loading.cancelled');
        _cancelled = true;
      });
      return;
    }

    // 1) cargar contenido Temas
    setState(() => _status = L10n.t('loading.connecting'));
    final topic = await _api.fetchTopic();
  
    setState(() {
      _status = L10n.t('loading.downloading');
    });

    // 2) preguntas en background (recomendado). Si fallan no importa: el
    // quiz las vuelve a pedir al abrirse. Sin .ignore() el fallo quedaba
    // como error sin manejar.
    _api.fetchQuestions(topic.topicId).ignore();

    // imágenes en background
    // ignore: unawaited_futures
    _precacheTopicImages(topic);

    if (!mounted) return;

    setState(() {
      _status = L10n.t('loading.opening');
    });


    if (!mounted) return;
    // Después del login entra la pantalla principal (HomeScreen).
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          topic: topic,
          imageCacheManager: widget.imageCacheManager,
        ),
      ),
    );

  } catch (e) {

    if (!mounted) return;
    setState(() => _error = e.toString());
  }
}

  @override
  void initState() {
    super.initState();
//    _load();
// para arreglar la pantalla negra despues del cambio de guardar el refresh token
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) _load();
  });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _error == null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cancelado: botón para volver al login. Con "atrás" aquí
                  // Android cierra la app, así que nunca queda atascada.
                  if (_cancelled)
                    ElevatedButton(
                      onPressed: _load,
                      child: Text(L10n.t('login.button')),
                    )
                  else
                    const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(
                    _status,
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      L10n.t('loading.error', {'error': _error}),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _load,
                      child: Text(L10n.t('common.retry')),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}