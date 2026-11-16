import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import '../config/auth_config.dart';

// -----------------
// 23 sep 2026 : Hernando Cortes
// Clase generada por ChatGPR para AppAuth
// -----------------
/*
class AuthService {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  Future<AuthorizationTokenResponse?> login() async {
    try {
      final AuthorizationTokenResponse result =
          await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          AuthConfig.clientId,
          AuthConfig.redirectUri,
          discoveryUrl: AuthConfig.discoveryUrl,
          scopes: AuthConfig.scopes,
        ),
      );

      return result;
    } on FlutterAppAuthUserCancelledException {
      // El usuario cerró/canceló el login.
      return null;
    } on FlutterAppAuthPlatformException catch (e) {
      throw Exception(
        'Error de AppAuth: ${e.platformErrorDetails}',
      );
    } catch (e) {
      throw Exception(
        'Error durante autenticación: $e',
      );
    }
  }
}

origina 7 oct 2026 */



class AuthService {
  /// Cliente de AppAuth. Si es null se usa el real; los tests pasan uno
  /// propio para no abrir el login de Cognito.
  AuthService({FlutterAppAuth? appAuth})
    : _appAuth = appAuth ?? const FlutterAppAuth();

  final FlutterAppAuth _appAuth;

  Future<AuthorizationTokenResponse?> login() async {
    try {

  debugPrint('=== ANTES DE APPAUTH ===');

      final AuthorizationTokenResponse result =
          await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          AuthConfig.clientId,
          AuthConfig.redirectUri,
          discoveryUrl: AuthConfig.discoveryUrl,
          scopes: AuthConfig.scopes,
        ),
      );

  debugPrint('=== APPAUTH TERMINÓ ===');
  //print('accessToken: ${result.accessToken}');
  //print('idToken: ${result.idToken}');
  //print('refreshToken: ${result.refreshToken}');
  
      return result;
    } on FlutterAppAuthUserCancelledException {
      // El usuario cerró/canceló el login.
      return null;
    } on FlutterAppAuthPlatformException catch (e, stack) {

        debugPrint('=== ERROR APPAUTH ===');
        debugPrint('$e');
        debugPrint('$stack');
        debugPrint('=== ERROR APPAUTH ===');


      throw Exception(
        'Error de AppAuth: ${e.platformErrorDetails}',
      );
    } catch (e, stack) {

      debugPrint('$e');
      debugPrint('$stack');


      throw Exception(
        'Error durante autenticación: $e',
      );
    }
  }
}
