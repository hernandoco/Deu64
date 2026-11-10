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
  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  Future<AuthorizationTokenResponse?> login() async {
    try {

  print('=== ANTES DE APPAUTH ===');

      final AuthorizationTokenResponse result =
          await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          AuthConfig.clientId,
          AuthConfig.redirectUri,
          discoveryUrl: AuthConfig.discoveryUrl,
          scopes: AuthConfig.scopes,
        ),
      );

  print('=== APPAUTH TERMINÓ ===');
  //print('accessToken: ${result.accessToken}');
  //print('idToken: ${result.idToken}');
  //print('refreshToken: ${result.refreshToken}');
  
      return result;
    } on FlutterAppAuthUserCancelledException {
      // El usuario cerró/canceló el login.
      return null;
    } on FlutterAppAuthPlatformException catch (e, stack) {

        print('=== ERROR APPAUTH ===');
        print(e);
        print(stack);
        print('=== ERROR APPAUTH ===');


      throw Exception(
        'Error de AppAuth: ${e.platformErrorDetails}',
      );
    } catch (e, stack) {

      print(e);
      print(stack);


      throw Exception(
        'Error durante autenticación: $e',
      );
    }
  }
}
