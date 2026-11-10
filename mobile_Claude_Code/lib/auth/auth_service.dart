import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:mobile/auth/auth_token.dart';

import '../config/auth_config.dart';

// ----------
// Clase inicialmente generada, se cambia para guardar el token refresh después que se logea
// ----------
/*
class AuthService {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  Future<AuthorizationTokenResponse?> login() async {
    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          AuthConfig.clientId,
          AuthConfig.redirectUri,
          discoveryUrl: AuthConfig.discoveryUrl,
          scopes: AuthConfig.scopes,
        ),
      );

      return result;
    } on FlutterAppAuthUserCancelledException {
      return null;
    } catch (e) {
      throw Exception(
        'Error durante autenticación: $e',
      );
    }
  }
}
*/

class AuthService {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final TokenStorage _tokenStorage = TokenStorage();

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

      // Guarda el refresh token antes de devolver el resultado
      if (result.refreshToken != null) {
        await _tokenStorage.saveRefreshToken(result.refreshToken!);
      }

      return result;
    } on FlutterAppAuthUserCancelledException {
      return null;
    } on FlutterAppAuthPlatformException catch (e) {
      throw Exception('Error de AppAuth: ${e.platformErrorDetails}');
    } catch (e) {
      throw Exception('Error durante autenticación: $e');
    }
  }
}