/// WeCoop Design System — Status pill
///
/// Pill di stato/priorità. L'etichetta è localizzata in tutte le lingue
/// (it/en/es/ar/zh) tramite AppLocalizations.
library;

import 'package:flutter/material.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import '../../theme/theme.dart';

/// Stato di una richiesta/pratica.
enum RequestStatus {
  open,
  inProgress,
  resolved,
  closed,
  toPay,
  toSign,
  waitingAppointment,
  pending,
  completed,
}

/// Priorità di un ticket.
enum RequestPriority { high, medium, low }

class StatusPill extends StatelessWidget {
  const StatusPill.status(this.status, {super.key}) : priority = null;
  const StatusPill.priority(this.priority, {super.key}) : status = null;

  final RequestStatus? status;
  final RequestPriority? priority;

  Color get _color {
    if (priority != null) {
      return switch (priority!) {
        RequestPriority.high => AppColors.error,
        RequestPriority.medium => AppColors.warning,
        RequestPriority.low => AppColors.success,
      };
    }
    return switch (status!) {
      RequestStatus.open => AppColors.info,
      RequestStatus.inProgress => AppColors.warning,
      RequestStatus.resolved => AppColors.success,
      RequestStatus.completed => AppColors.success,
      RequestStatus.closed => AppColors.textMuted,
      RequestStatus.toPay => AppColors.error,
      RequestStatus.toSign => AppColors.primary,
      RequestStatus.waitingAppointment => AppColors.info,
      RequestStatus.pending => AppColors.textMuted,
    };
  }

  String _label(AppLocalizations l10n) {
    if (priority != null) {
      return switch (priority!) {
        RequestPriority.high => l10n.priorityHigh,
        RequestPriority.medium => l10n.priorityMedium,
        RequestPriority.low => l10n.priorityLow,
      };
    }
    return switch (status!) {
      RequestStatus.open => l10n.statusOpen,
      RequestStatus.inProgress => l10n.statusInProgress,
      RequestStatus.resolved => l10n.statusResolved,
      RequestStatus.closed => l10n.statusClosed,
      RequestStatus.toPay => l10n.statusToPay,
      RequestStatus.toSign => l10n.statusToSign,
      RequestStatus.waitingAppointment => l10n.statusWaitingAppointment,
      RequestStatus.pending => l10n.statusPending,
      RequestStatus.completed => l10n.statusCompleted,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.pillBr,
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Text(
        _label(l10n),
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: AppTypography.bold,
        ),
      ),
    );
  }
}
