import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/config/auth_config.dart';
import 'package:mobile/pages/login_page.dart';
import 'package:mobile/services/auth_service.dart';

import '../helpers.dart';

FlutterAppAuthPlatformErrorDetails errorDetails() =>
    FlutterAppAuthPlatformErrorDetails(error: 'invalid_client');

/// Cliente de AppAuth falso para probar AuthService sin Cognito.
class FakeAppAuth extends Fake implements FlutterAppAuth {
  FakeAppAuth(this.onAuthorize);

  final Future<AuthorizationTokenResponse> Function(AuthorizationTokenRequest)
  onAuthorize;
  AuthorizationTokenRequest? lastRequest;

  @override
  Future<AuthorizationTokenResponse> authorizeAndExchangeCode(
    AuthorizationTokenRequest request,
  ) {
    lastRequest = request;
    return onAuthorize(request);
  }
}

/// Abre el login desde otra pantalla, como hace LoadingScreen, y guarda lo
/// que devuelve al cerrarse.
class _Host extends StatefulWidget {
  const _Host(this.auth);
  final AuthService auth;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  bool returned = false;
  AuthorizationTokenResponse? result;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final r = await Navigator.of(context).push<AuthorizationTokenResponse>(
        MaterialPageRoute(builder: (_) => LoginPage(authService: widget.auth)),
      );
      setState(() {
        returned = true;
        result = r;
      });
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('Origen'));
}

Future<_HostState> _openLogin(WidgetTester tester, AuthService auth) async {
  await pumpScreen(tester, _Host(auth));
  await tester.pumpAndSettle();
  return tester.state<_HostState>(
    // El origen queda oculto detrás del login.
    find.byType(_Host, skipOffstage: false),
  );
}

ElevatedButton loginButton(WidgetTester tester) =>
    tester.widget<ElevatedButton>(find.byType(ElevatedButton));

void main() {
  group('LoginPage', () {
    testWidgets('muestra la bienvenida y el botón de iniciar sesión', (
      tester,
    ) async {
      await pumpScreen(tester, LoginPage(authService: FakeAuthService()));

      expect(find.text('DEU64'), findsOneWidget);
      expect(find.text('Bienvenido'), findsOneWidget);
      expect(find.text('Iniciar sesión'), findsOneWidget);
      expect(loginButton(tester).onPressed, isNotNull);
    });

    testWidgets('mientras inicia sesión muestra carga y bloquea el botón', (
      tester,
    ) async {
      final auth = FakeAuthService();
      await pumpScreen(tester, LoginPage(authService: auth));

      await tester.tap(find.text('Iniciar sesión'));
      await tester.pump();

      expect(auth.calls, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Iniciar sesión'), findsNothing);
      expect(loginButton(tester).onPressed, isNull);

      auth.cancel();
      await tester.pumpAndSettle();
    });

    testWidgets('si el login funciona, se cierra y devuelve los tokens', (
      tester,
    ) async {
      final auth = FakeAuthService();
      final host = await _openLogin(tester, auth);

      await tester.tap(find.text('Iniciar sesión'));
      await tester.pump();
      final t = tokens();
      auth.succeed(t);
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsNothing);
      expect(host.returned, isTrue);
      expect(host.result, same(t));
    });

    testWidgets('si el usuario cancela, se queda y puede reintentar', (
      tester,
    ) async {
      final auth = FakeAuthService();
      final host = await _openLogin(tester, auth);

      await tester.tap(find.text('Iniciar sesión'));
      await tester.pump();
      auth.cancel();
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(host.returned, isFalse);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(loginButton(tester).onPressed, isNotNull);
    });

    testWidgets('si falla, muestra el error y el reintento lo borra', (
      tester,
    ) async {
      final auth = FakeAuthService();
      await _openLogin(tester, auth);

      await tester.tap(find.text('Iniciar sesión'));
      await tester.pump();
      auth.fail(Exception('Error de AppAuth: sin conexión'));
      await tester.pumpAndSettle();

      expect(
        find.text('Exception: Error de AppAuth: sin conexión'),
        findsOneWidget,
      );
      expect(loginButton(tester).onPressed, isNotNull);

      await tester.tap(find.text('Iniciar sesión'));
      await tester.pump();

      expect(find.textContaining('sin conexión'), findsNothing);
      expect(auth.calls, 2);

      auth.cancel();
      await tester.pumpAndSettle();
    });
  });

  group('AuthService', () {
    test('pide el login con la configuración de Cognito', () async {
      final appAuth = FakeAppAuth((_) async => tokens());

      await AuthService(appAuth: appAuth).login();

      final req = appAuth.lastRequest!;
      expect(req.clientId, AuthConfig.clientId);
      expect(req.redirectUrl, AuthConfig.redirectUri);
      expect(req.discoveryUrl, AuthConfig.discoveryUrl);
      expect(req.scopes, AuthConfig.scopes);
    });

    test('si Cognito responde, devuelve los tokens', () async {
      final t = tokens();

      final result = await AuthService(
        appAuth: FakeAppAuth((_) async => t),
      ).login();

      expect(result, same(t));
    });

    test('si el usuario cierra el navegador, devuelve null', () async {
      final service = AuthService(
        appAuth: FakeAppAuth(
          (_) => Future.error(
            FlutterAppAuthUserCancelledException(
              code: 'user_cancelled',
              platformErrorDetails: errorDetails(),
            ),
          ),
        ),
      );

      expect(await service.login(), isNull);
    });

    test('un error de AppAuth se informa como "Error de AppAuth"', () async {
      final service = AuthService(
        appAuth: FakeAppAuth(
          (_) => Future.error(
            FlutterAppAuthPlatformException(
              code: 'authorize_and_exchange_code_failed',
              platformErrorDetails: errorDetails(),
            ),
          ),
        ),
      );

      await expectLater(
        service.login(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'mensaje',
            contains('Error de AppAuth'),
          ),
        ),
      );
    });

    test(
      'cualquier otro error se informa como error de autenticación',
      () async {
        final service = AuthService(
          appAuth: FakeAppAuth((_) => Future.error(StateError('sin red'))),
        );

        await expectLater(
          service.login(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'mensaje',
              allOf(
                contains('Error durante autenticación'),
                contains('sin red'),
              ),
            ),
          ),
        );
      },
    );
  });
}
