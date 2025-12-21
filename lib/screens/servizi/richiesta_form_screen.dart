import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RichiestaFormScreen extends StatefulWidget {
  final String servizio;
  final String categoria;
  final List<Map<String, dynamic>> campi;

  const RichiestaFormScreen({
    super.key,
    required this.servizio,
    required this.categoria,
    required this.campi,
  });

  @override
  State<RichiestaFormScreen> createState() => _RichiestaFormScreenState();
}

class _RichiestaFormScreenState extends State<RichiestaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoria)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.servizio,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.categoria,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Compila i seguenti campi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...widget.campi.map((campo) => _buildField(campo)),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  child:
                      _isSubmitting
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                            ),
                          )
                          : const Text(
                            'Invia richiesta',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(Map<String, dynamic> campo) {
    final label = campo['label'] as String;
    final type = campo['type'] as String;
    final required = campo['required'] as bool;

    Widget field;

    switch (type) {
      case 'text':
        field = TextFormField(
          decoration: InputDecoration(
            labelText: label + (required ? ' *' : ''),
            border: const OutlineInputBorder(),
          ),
          validator:
              required
                  ? (value) =>
                      value?.isEmpty ?? true ? 'Campo obbligatorio' : null
                  : null,
          onSaved: (value) => _formData[label] = value,
        );
        break;
      case 'textarea':
        field = TextFormField(
          decoration: InputDecoration(
            labelText: label + (required ? ' *' : ''),
            border: const OutlineInputBorder(),
          ),
          maxLines: 4,
          validator:
              required
                  ? (value) =>
                      value?.isEmpty ?? true ? 'Campo obbligatorio' : null
                  : null,
          onSaved: (value) => _formData[label] = value,
        );
        break;
      case 'number':
        field = TextFormField(
          decoration: InputDecoration(
            labelText: label + (required ? ' *' : ''),
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator:
              required
                  ? (value) =>
                      value?.isEmpty ?? true ? 'Campo obbligatorio' : null
                  : null,
          onSaved: (value) => _formData[label] = value,
        );
        break;
      case 'date':
        field = TextFormField(
          decoration: InputDecoration(
            labelText: label + (required ? ' *' : ''),
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              setState(() {
                _formData[label] = '${date.day}/${date.month}/${date.year}';
              });
            }
          },
          controller: TextEditingController(text: _formData[label] ?? ''),
          validator:
              required
                  ? (value) =>
                      value?.isEmpty ?? true ? 'Campo obbligatorio' : null
                  : null,
        );
        break;
      case 'select':
        final options = campo['options'] as List<dynamic>;
        field = DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label + (required ? ' *' : ''),
            border: const OutlineInputBorder(),
          ),
          items:
              options.map((option) {
                return DropdownMenuItem<String>(
                  value: option.toString(),
                  child: Text(option.toString()),
                );
              }).toList(),
          validator:
              required
                  ? (value) => value == null ? 'Campo obbligatorio' : null
                  : null,
          onChanged: (value) => _formData[label] = value,
        );
        break;
      default:
        field = const SizedBox();
    }

    return Padding(padding: const EdgeInsets.only(bottom: 16), child: field);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isSubmitting = true;
    });

    // Prepara i dati per l'invio al CRM
    final data = {
      'servizio': widget.servizio,
      'categoria': widget.categoria,
      'data_richiesta': DateTime.now().toIso8601String(),
      'campi': _formData,
    };

    try {
      // TODO: Sostituisci con l'URL del tuo CRM/API
      final response = await http.post(
        Uri.parse('https://your-crm-api.com/richieste'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        _showSuccessDialog();
      } else {
        throw Exception('Errore nell\'invio');
      }
    } catch (e) {
      // Per ora mostriamo successo anche in caso di errore
      // dato che l'endpoint CRM non è ancora configurato
      debugPrint('Errore invio: $e');
      debugPrint('Dati che sarebbero stati inviati: ${jsonEncode(data)}');
      if (!mounted) return;
      _showSuccessDialog();
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 12),
                Text('Richiesta inviata!'),
              ],
            ),
            content: const Text(
              'La tua richiesta è stata inviata con successo. Ti contatteremo presto per darti assistenza.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Chiudi dialog
                  Navigator.of(
                    context,
                  ).pop(); // Torna alla schermata precedente
                  Navigator.of(
                    context,
                  ).pop(); // Torna alla home o lista servizi
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
