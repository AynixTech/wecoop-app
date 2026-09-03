/// WeCoop Design System — Campo indirizzo con autocompletamento
///
/// Usa [AddressAutocompleteService] (`/api/geo` se configurato, altrimenti
/// Nominatim) per suggerire indirizzi. Alla selezione, restituisce il
/// suggerimento completo così lo schermo può auto-compilare città/CAP/provincia.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import '../../services/address_autocomplete_service.dart';
import '../../theme/theme.dart';

class AddressAutocompleteField extends StatefulWidget {
  const AddressAutocompleteField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon = Icons.location_on_outlined,
    this.onSelected,
    this.languageCode,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;

  /// Callback con il suggerimento scelto (per autofill di città/CAP/provincia).
  final ValueChanged<AddressSuggestion>? onSelected;

  /// Forza la lingua dei risultati (altrimenti letta dallo storage).
  final String? languageCode;

  @override
  State<AddressAutocompleteField> createState() =>
      _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  Timer? _debounce;
  List<AddressSuggestion> _last = const [];
  String _lastQuery = '';

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<List<AddressSuggestion>> _fetch(String query) async {
    // Debounce: attende 350ms di inattività prima di chiamare il servizio.
    _debounce?.cancel();
    final completer = Completer<List<AddressSuggestion>>();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final res = await AddressAutocompleteService.search(
        query,
        languageCode: widget.languageCode,
      );
      _last = res;
      _lastQuery = query;
      if (!completer.isCompleted) completer.complete(res);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTypography.label),
        const SizedBox(height: AppSpacing.xs),
        RawAutocomplete<AddressSuggestion>(
          textEditingController: widget.controller,
          focusNode: FocusNode(),
          optionsBuilder: (TextEditingValue value) async {
            final q = value.text.trim();
            if (q.length < 3) return const Iterable<AddressSuggestion>.empty();
            if (q == _lastQuery && _last.isNotEmpty) return _last;
            return _fetch(q);
          },
          displayStringForOption: (o) =>
              o.street.isNotEmpty ? o.street : o.displayName,
          onSelected: (o) async {
            final resolved = await AddressAutocompleteService.resolve(o);
            if (resolved.street.isNotEmpty) {
              widget.controller.text = resolved.street;
            } else if (resolved.displayName.isNotEmpty) {
              widget.controller.text =
                  resolved.displayName.split(',').first.trim();
            }
            widget.onSelected?.call(resolved);
          },
          fieldViewBuilder:
              (context, textController, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: textController,
              focusNode: focusNode,
              style: AppTypography.bodyL,
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon: Icon(widget.icon, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.inputBr,
                  borderSide: const BorderSide(color: AppColors.borderInput),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.inputBr,
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: AppRadius.cardBr,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 260),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final o = options.elementAt(index);
                      return ListTile(
                        leading: const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        title: Text(
                          o.street.isNotEmpty ? o.street : o.displayName,
                          style: AppTypography.bodyM,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          [o.postcode, o.city, o.province]
                              .where((s) => s.isNotEmpty)
                              .join(' · '),
                          style: AppTypography.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => onSelected(o),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
