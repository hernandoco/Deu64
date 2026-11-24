import 'package:flutter/material.dart';
import '../l10n/l10n.dart';

import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  /// Servicio de login. Si es null se usa el real (Cognito); los tests pasan
  /// uno propio.
  final AuthService? authService;

  const LoginPage({super.key, this.authService});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AuthService _authService = widget.authService ?? AuthService();

  bool _loading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.login();

      if (!mounted) return;

      if (result == null) {
        // El usuario canceló
        setState(() {
          _loading = false;
        });
        return;
      }

      //debugPrint('Access Token: ${result.accessToken}');
      //debugPrint('ID Token: ${result.idToken}');
      //debugPrint('Refresh Token: ${result.refreshToken}');

      //setState(() {
      //  _loading = false;
      //});


      //if (!mounted) return;
      /* Hernando 9 oct 2026 se reemplaza por la siguiente
        Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );*/
      // Posteriormente navegaremos a HomePage.
      Navigator.of(context).pop(result); // null si canceló


    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.t('login.title')),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                L10n.t('login.welcome'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : Text(L10n.t('login.button')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}