import 'package:flutter/material.dart';

import '../../models/supporto_ticket_model.dart';
import '../../services/supporto_service.dart';
import '../../services/app_localizations.dart';
import '../../theme/theme.dart';
import '../../widgets/design_system/design_system.dart';

/// Schermata "Le mie richieste": elenca i ticket di supporto creati
/// dall'utente, con numero ticket, servizio, priorità, stato, data e
/// risposte ricevute dagli operatori.
class MieRichiesteScreen extends StatefulWidget {
  /// Se valorizzato (es. da push `support_reply`), apre il dettaglio ticket.
  final String? initialTicketId;

  const MieRichiesteScreen({super.key, this.initialTicketId});

  @override
  State<MieRichiesteScreen> createState() => _MieRichiesteScreenState();
}

class _MieRichiesteScreenState extends State<MieRichiesteScreen> {
  bool _loading = true;
  bool _error = false;
  String? _errorMessage;
  List<SupportoTicket> _tickets = [];
  bool _openedInitial = false;

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
      _maybeOpenInitialTicket();
    } else {
      setState(() {
        _error = true;
        _errorMessage = result['message'] as String?;
        _loading = false;
      });
    }
  }

  void _maybeOpenInitialTicket() {
    if (_openedInitial) return;
    final raw = widget.initialTicketId?.trim();
    if (raw == null || raw.isEmpty) return;
    final id = int.tryParse(raw);
    if (id == null) return;
    SupportoTicket? match;
    for (final t in _tickets) {
      if (t.id == id) {
        match = t;
        break;
      }
    }
    if (match == null) return;
    _openedInitial = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _openTicketDetail(match!);
    });
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

  Future<void> _openTicketDetail(SupportoTicket ticket) async {
    var risposte = ticket.risposte;
    // Fallback: se la lista non include risposte (backend vecchio), ricarica.
    if (risposte.isEmpty) {
      final result = await SupportoService.getMessaggi(ticket.id);
      if (result['success'] == true) {
        risposte = (result['data'] as List<SupportoMessaggio>?) ?? [];
      }
    }
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    ticket.serviceName,
                    style: AppTypography.bodyL.copyWith(
                      fontWeight: AppTypography.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ticket.numeroTicket,
                    style: AppTypography.caption.copyWith(
                      fontWeight: AppTypography.semiBold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      StatusPill.status(_mapStatus(ticket.status)),
                      StatusPill.priority(_mapPriority(ticket.priorita)),
                    ],
                  ),
                  if ((ticket.messaggio ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.supportYourRequest,
                      style: AppTypography.caption.copyWith(
                        fontWeight: AppTypography.semiBold,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      ticket.messaggio!.trim(),
                      style: AppTypography.bodyM,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.supportReplies,
                    style: AppTypography.caption.copyWith(
                      fontWeight: AppTypography.semiBold,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (risposte.isEmpty)
                    Text(
                      l10n.supportNoRepliesYet,
                      style: AppTypography.bodyM.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )
                  else
                    ...risposte.map((r) => _ReplyBubble(messaggio: r)),
                ],
              ),
            );
          },
        );
      },
    );
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
        final ultima = t.ultimaRisposta;

        return AppCard(
          onTap: () => _openTicketDetail(t),
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
                  if (t.hasRisposte)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.badge),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mark_email_unread_outlined,
                            size: 14,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${t.risposte.length}',
                            style: AppTypography.caption.copyWith(
                              fontWeight: AppTypography.semiBold,
                              color: AppColors.secondary,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (ultima != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.supportOperatorReply,
                        style: AppTypography.caption.copyWith(
                          fontWeight: AppTypography.semiBold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ultima.body.trim(),
                        style: AppTypography.bodyM,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
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

class _ReplyBubble extends StatelessWidget {
  final SupportoMessaggio messaggio;

  const _ReplyBubble({required this.messaggio});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.support_agent_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    (messaggio.authorName ?? '').trim().isEmpty
                        ? 'WeCoop'
                        : messaggio.authorName!,
                    style: AppTypography.caption.copyWith(
                      fontWeight: AppTypography.semiBold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (messaggio.dataFormattata.isNotEmpty)
                  Text(
                    messaggio.dataFormattata,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(messaggio.body.trim(), style: AppTypography.bodyM),
          ],
        ),
      ),
    );
  }
}
