import 'package:flutter/material.dart';
import 'package:wecoop_app/services/app_localizations.dart';

class Compilazione730Screen extends StatefulWidget {
  const Compilazione730Screen({super.key});

  @override
  State<Compilazione730Screen> createState() => _Compilazione730ScreenState();
}

class _Compilazione730ScreenState extends State<Compilazione730Screen> {
  final TextEditingController famigliaController = TextEditingController();
  final TextEditingController redditoController = TextEditingController();
  final TextEditingController speseController = TextEditingController();

  bool _formValid = true;

  void _submitForm() {
    final l10n = AppLocalizations.of(context)!;
    final isValid =
        famigliaController.text.isNotEmpty &&
        redditoController.text.isNotEmpty &&
        speseController.text.isNotEmpty;

    setState(() {
      _formValid = isValid;
    });

    if (isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.data730SentSuccess)),
      );
      // TODO: invia i dati al backend o salva localmente
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.allFieldsRequired)),
      );

    }
  }

  @override
  void dispose() {
    famigliaController.dispose();
    redditoController.dispose();
    speseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.compilation730)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sezione Famiglia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: famigliaController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Dati Familiari',
                errorText:
                    !_formValid && famigliaController.text.isEmpty
                        ? l10n.fillAllFields
                        : null,
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Sezione Reddito',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: redditoController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.incomeData,
                errorText:
                    !_formValid && redditoController.text.isEmpty
                        ? l10n.fillAllFields
                        : null,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            const Text(
              'Sezione Spese',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: speseController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.deductions,
                errorText:
                    !_formValid && speseController.text.isEmpty
                        ? l10n.fillAllFields
                        : null,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            Center(
              child: ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.send),
                label: Text(l10n.send730),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
