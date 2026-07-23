import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'package:wecoop_app/services/app_update_policy_service.dart';

/// Impedisce l'uso dell'app iOS quando App Store pubblica una versione piu'
/// recente. Si riattiva quando l'utente torna dall'App Store.
class MandatoryUpdateGate extends StatefulWidget {
  const MandatoryUpdateGate({super.key, required this.child});

  final Widget child;

  @override
  State<MandatoryUpdateGate> createState() => _MandatoryUpdateGateState();
}

class _MandatoryUpdateGateState extends State<MandatoryUpdateGate>
    with WidgetsBindingObserver {
  AppUpdateRequirement? _requirement;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPolicy();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkPolicy();
  }

  Future<void> _checkPolicy() async {
    final requirement = await AppUpdatePolicyService.checkForMandatoryUpdate();
    if (mounted) setState(() => _requirement = requirement);
  }

  Future<void> _openStore() async {
    final storeUrl = _requirement?.storeUrl;
    if (storeUrl == null || storeUrl.isEmpty) return;
    await launchUrl(Uri.parse(storeUrl), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final requirement = _requirement;
    if (requirement == null) return _CheckingUpdateScreen();
    if (!requirement.isRequired) return widget.child;

    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.system_update_rounded,
                      size: 72,
                      color: Color(0xFF1282A8),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      l10n.translate('mandatoryUpdateTitle'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n
                          .translate('mandatoryUpdateMessage')
                          .replaceAll('{version}', requirement.requiredVersion),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF52606D),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: _openStore,
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: Text(l10n.translate('mandatoryUpdateAction')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckingUpdateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
