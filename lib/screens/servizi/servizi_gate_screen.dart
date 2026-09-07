import 'package:flutter/material.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import '../../services/auth_helper.dart';
import '../login/login_screen.dart';

/// Gate di accesso ai servizi: richiede solo login.
///
/// Diventare socio avviene alla firma del documento unico (backend),
/// non qui: qualsiasi utente autenticato può aprire e inviare richieste.
class ServiziGateScreen extends StatefulWidget {
  final Widget destinationScreen;
  final String serviceName;

  const ServiziGateScreen({
    super.key,
    required this.destinationScreen,
    required this.serviceName,
  });

  @override
  State<ServiziGateScreen> createState() => _ServiziGateScreenState();
}

class _ServiziGateScreenState extends State<ServiziGateScreen> {
  bool _isLoading = true;
  bool _shouldShowLogin = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final loggedIn = await AuthHelper.isLoggedIn();
    if (!mounted) return;

    if (!loggedIn) {
      setState(() {
        _shouldShowLogin = true;
        _isLoading = false;
      });
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => widget.destinationScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.serviceName)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_shouldShowLogin) {
      return _buildLoginPromptScreen();
    }

    // In attesa del pushReplacement verso la destinazione.
    return Scaffold(
      appBar: AppBar(title: Text(widget.serviceName)),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildLoginPromptScreen() {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(widget.serviceName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 80, color: scheme.primary),
              const SizedBox(height: 24),
              Text(
                l10n.goToLogin,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.loginToAccessServices,
                style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.login),
                label: Text(l10n.goToLogin),
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: Text(l10n.backToHome),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
