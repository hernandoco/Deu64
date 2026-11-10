import 'package:flutter/material.dart';

import '../api.dart';
import '../image_cache_manager.dart';
import '../models.dart';
import 'home_screen.dart';

import '../pages/login_page.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import 'package:http/http.dart' as http;

String _status = 'Iniciando...';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {  
  final _api = ApiClient();
  String? _error;

  Future<void> _precacheTopicImages(TopicResponse topic) async {
    
    for (final scene in topic.scenes) {
    
      final url = scene.imageUrl;
      try {
        //final cached = await sceneImagesCacheManager.getFileFromCache(url);
  
        final cached = await sceneImagesCacheManager.downloadFile(url);
  
 

        if (cached != null && await cached.file.exists()) continue;


        await sceneImagesCacheManager
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
      _status = 'Conectando al servidor...';
    });

    try {
      // 1) Topic
      final topic = await _api.fetchTopic();

      setState(() {
        _status = 'Descargando recursos...';
      });

      // preguntas en background (recomendado)
      // ignore: unawaited_futures
      _api.fetchQuestions(topic.topicId);

      // imágenes en background
      // ignore: unawaited_futures
      _precacheTopicImages(topic);

      if (!mounted) return;

      setState(() {
        _status = 'Abriendo contenido...';
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
    
    setState(() {
      _error = null;
      _status = 'Iniciando sesión...';
    });

  try {
    // 0) Login primero
    final auth = await Navigator.of(context).push<AuthorizationTokenResponse>(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );

    if (!mounted) return;

    if (auth == null) {
      setState(() => _status = 'Inicio de sesión cancelado');
      return;
    }

    // 1) cargar contenido Temas
    setState(() => _status = 'Conectando al servidor...');
    final topic = await _api.fetchTopic();
  
    setState(() {
      _status = 'Descargando recursos...';
    });

    // 2) preguntas en background (recomendado)
    // ignore: unawaited_futures
    _api.fetchQuestions(topic.topicId);

    // imágenes en background
    // ignore: unawaited_futures
    _precacheTopicImages(topic);

    if (!mounted) return;

    setState(() {
      _status = 'Abriendo contenido...';
    });


    if (!mounted) return;
    // Después del login entra la pantalla principal (HomeScreen).
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen(topic: topic)),
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
                      'Error cargando datos:\n$_error',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _load,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}