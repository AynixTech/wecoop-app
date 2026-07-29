import 'package:flutter/material.dart';

import '../../models/supporto_ticket_model.dart';
import '../../services/supporto_service.dart';
import '../../services/app_localizations.dart';
import '../../theme/theme.dart';
import '../../widgets/design_system/design_system.dart';

/// Schermata "Le mie richieste": elenca i ticket di supporto creati
/// dall'utente, con numero ticket, servizio, priorità, stato e data
/// (come la lista "Richieste Supporto" del back-office).
class MieRichiesteScreen extends StatefulWidget {
  const MieRichiesteScreen({super.key});

  @override
  State<MieRichiesteScreen> createState() => _MieRichiesteScreenState();
}

class _MieRichiesteScreenState extends State<MieRichiesteScreen> {
  bool _loading = true;
  bool _error = false;
  String? _errorMessage;
  List<SupportoTicket> _tickets = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
      _errorMessage = null;
    });

    final result = await SupportoService.getMieRichieste();
    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _tickets = (result['data'] as List<SupportoTicket>?) ?? [];
        _loading = false;
      });
    } else {
      setState(() {
        _error = true;
        _errorMessage = result['message'] as String?;
        _loading = false;
      });
    }
  }

  RequestStatus _mapStatus(String status) {
    switch (status) {
      case 'aperta':
        return RequestStatus.open;
      case 'in_lavorazione':
        return RequestStatus.inProgress;
      case 'risolta':
        return RequestStatus.resolved;
      case 'chiusa':
        return RequestStatus.closed;
      default:
        return RequestStatus.pending;
    }
  }

  RequestPriority _mapPriority(String priorita) {
    switch (priorita) {
      case 'alta':
        return RequestPriority.high;
      case 'bassa':
        return RequestPriority.low;
      case 'media':
      default:
        return RequestPriority.medium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myRequests)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(l10n),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          ErrorState(
            message: _errorMessage ?? l10n.loadRequestsError,
            retryLabel: l10n.retry,
            onRetry: _load,
          ),
        ],
      );
    }

    if (_tickets.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          EmptyState(
            icon: Icons.sms_outlined,
            title: l10n.noSupportRequests,
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _tickets.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final t = _tickets[index];

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.smd),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppRadius.input),
                    ),
                    child: const Icon(
                      Icons.confirmation_number_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.serviceName,
                          style: AppTypography.bodyL.copyWith(
                            fontWeight: AppTypography.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.numeroTicket,
                          style: AppTypography.caption.copyWith(
                            fontWeight: AppTypography.semiBold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if ((t.messaggio ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  t.messaggio!.trim(),
                  style: AppTypography.bodyM.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusPill.status(_mapStatus(t.status)),
                  StatusPill.priority(_mapPriority(t.priorita)),
                  if (t.dataFormattata.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Text(
                          t.dataFormattata,
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
