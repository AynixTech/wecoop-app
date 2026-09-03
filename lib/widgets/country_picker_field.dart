import 'package:flutter/material.dart';
import 'package:wecoop_app/utils/countries.dart';

/// Campo form per selezionare una nazionalità da lista mondiale, con ricerca.
class CountryPickerField extends FormField<String> {
  CountryPickerField({
    super.key,
    super.initialValue,
    super.validator,
    required String labelText,
    String? helperText,
    ValueChanged<String?>? onChanged,
  }) : super(
          builder: (state) {
            final selected = Countries.byCode(state.value);
            return InkWell(
              onTap: () async {
                final code = await showCountryPickerSheet(
                  state.context,
                  selectedCode: state.value,
                );
                if (code == null) return;
                state.didChange(code);
                onChanged?.call(code);
              },
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                isEmpty: selected == null,
                decoration: InputDecoration(
                  labelText: labelText,
                  helperText: helperText,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.public),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  errorText: state.errorText,
                ),
                child: Text(
                  selected?.label ?? '',
                  style: Theme.of(state.context).textTheme.bodyLarge,
                ),
              ),
            );
          },
        );
}

Future<String?> showCountryPickerSheet(
  BuildContext context, {
  String? selectedCode,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => _CountryPickerSheet(selectedCode: selectedCode),
  );
}

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({this.selectedCode});

  final String? selectedCode;

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _query = TextEditingController();
  late List<Country> _results;

  @override
  void initState() {
    super.initState();
    _results = Countries.all;
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() {
      _results = Countries.search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.85;
    return SizedBox(
      height: height,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _query,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Cerca paese…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: _onQueryChanged,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final country = _results[index];
                final selected =
                    country.code == widget.selectedCode?.toUpperCase();
                return ListTile(
                  leading: Text(country.flag, style: const TextStyle(fontSize: 22)),
                  title: Text(country.name),
                  trailing: selected
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  selected: selected,
                  onTap: () => Navigator.pop(context, country.code),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
