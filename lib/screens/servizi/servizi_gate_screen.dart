import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import '../../services/socio_service.dart';
import 'adesione_socio_screen.dart';
import '../login/login_screen.dart';

/// Middleware che verifica se l'utente è socio prima di accedere ai servizi
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
  final _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  bool _hasRichiestaInAttesa = false;
  bool _shouldShowLogin = false;

  @override
  void initState() {
    super.initState();
    _checkSocioStatus();
  }

  Future<void> _checkSocioStatus() async {
    // 1. Controlla se c'è una email salvata da una richiesta precedente
    final savedEmail = await _storage.read(key: 'pending_socio_email');

    // 2. Verifica se l'utente è già socio
    final isSocio = await SocioService.isSocio();

    // 3. Se non è socio ma ha una email salvata, controlla se è stato approvato
    if (!isSocio && savedEmail != null && savedEmail.isNotEmpty) {
      final hasRichiesta = await SocioService.hasRichiestaInAttesa();

      // Se non ha più richiesta in attesa, potrebbe essere stato approvato
      // Mostra il prompt per il login
      if (!hasRichiesta) {
        setState(() {
          _shouldShowLogin = true;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _hasRichiestaInAttesa = hasRichiesta;
        _isLoading = false;
      });
      return;
    }

    // 4. Controllo standard
    final hasRichiesta = await SocioService.hasRichiestaInAttesa();

    setState(() {
      _hasRichiestaInAttesa = hasRichiesta;
      _isLoading = false;
    });

    // Se è già socio, naviga direttamente al servizio
    if (isSocio && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => widget.destinationScreen),
      );
    }
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

    if (_hasRichiestaInAttesa) {
      return _buildRichiestaInAttesaScreen();
    }

    return _buildAdesioneRequiredScreen();
  }

  Widget _buildLoginPromptScreen() {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(widget.serviceName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.green.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                '${l10n.requestSent}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '${l10n.requestReceived}\n\n'
                '${l10n.loginToAccessServices}',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
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
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
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
                label: Text(l10n.goBack),
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

  Widget _buildRichiestaInAttesaScreen() {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(widget.serviceName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pending_actions,
                size: 80,
                color: Colors.orange.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                '${l10n.pending}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '${l10n.membershipPendingApproval}\n\n'
                '${l10n.confirmationWithin24to48Hours}\n\n'
                '${l10n.onceApprovedAccessAllServices}',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
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

  Widget _buildAdesioneRequiredScreen() {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(widget.serviceName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.card_membership,
                size: 80,
                color: Colors.amber.shade700,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.needLogin,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '${l10n.toAccessServicesBecomeMember.replaceAll('{serviceName}', widget.serviceName.toLowerCase())}\n\n'
                '${l10n.becomeMemberToAccess}\n'
                '• Assistenza dedicata\n'
                '• Consulenze gratuite\n'
                '• Eventi e networking\n'
                '• Supporto personalizzato',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdesioneSocioScreen(),
                    ),
                  ).then((_) {
                    // Ricontrolla lo stato quando torna
                    _checkSocioStatus();
                  });
                },
                icon: const Icon(Icons.how_to_reg),
                label: Text(l10n.becomeMember),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
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
