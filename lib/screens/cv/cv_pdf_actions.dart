import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/curriculum_cv.dart';
import '../../services/curricula_service.dart';
import '../../utils/share_helper.dart';

String nomeFilePdf(String titolo, int? versione) {
  final base = titolo
      .replaceAll(RegExp(r'[^\w\- ]', unicode: true), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), '_');
  final safe = base.isEmpty ? 'Curriculum' : base;
  return versione == null ? '$safe.pdf' : '${safe}_v$versione.pdf';
}

String formatData(DateTime? d) {
  if (d == null) return '';
  final l = d.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(l.day)}/${two(l.month)}/${l.year} ${two(l.hour)}:${two(l.minute)}';
}

void mostraMessaggio(BuildContext context, String testo) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(testo)));
}

/// Scarica un PDF del nuovo generatore mostrando un indicatore di attesa.
Future<File?> scaricaPdfCv(
  BuildContext context,
  CurriculumCv cv, {
  int? versione,
}) async {
  final v = versione ?? cv.ultimoPdf?.versione;
  if (v == null) {
    mostraMessaggio(context, 'Genera prima il PDF dalla schermata di anteprima.');
    return null;
  }
  final res = await _conAttesa(
    context,
    CurriculaService.scaricaPdf(cv.id, versione: v, nomeFile: nomeFilePdf(cv.titolo, v)),
  );
  if (res == null) return null;
  if (!res.ok) {
    if (context.mounted) mostraMessaggio(context, res.errore!);
    return null;
  }
  return res.data;
}

Future<File?> scaricaPdfStorico(BuildContext context, CurriculumStorico s) async {
  final res = await _conAttesa(
    context,
    CurriculaService.scaricaPdfStorico(s.id, nomeFilePdf(s.titolo, null)),
  );
  if (res == null) return null;
  if (!res.ok) {
    if (context.mounted) mostraMessaggio(context, res.errore!);
    return null;
  }
  return res.data;
}

Future<T?> _conAttesa<T>(BuildContext context, Future<T> future) async {
  if (!context.mounted) return null;
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PopScope(
      canPop: false,
      child: Center(child: CircularProgressIndicator()),
    ),
  );
  try {
    return await future;
  } finally {
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
  }
}

/// Foglio di condivisione di sistema: da qui l'utente può salvare il file,
/// inviarlo o stamparlo con le funzioni offerte dal dispositivo.
Future<void> condividiPdf(BuildContext context, File file, {String? titolo}) async {
  if (!context.mounted) return;
  try {
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: titolo ?? 'Curriculum Vitae',
      sharePositionOrigin: sharePositionOrigin(context),
    );
  } catch (_) {
    if (context.mounted) mostraMessaggio(context, 'Condivisione non disponibile su questo dispositivo.');
  }
}

Future<void> apriPdf(BuildContext context, File file, {required String titolo}) async {
  if (!context.mounted) return;
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (ctx) => Scaffold(
        appBar: AppBar(
          title: Text(titolo, overflow: TextOverflow.ellipsis),
          actions: [
            Builder(
              builder: (btnCtx) => IconButton(
                tooltip: 'Scarica, condividi o stampa',
                icon: const Icon(Icons.ios_share),
                onPressed: () => condividiPdf(btnCtx, file, titolo: titolo),
              ),
            ),
          ],
        ),
        body: PDFView(
          filePath: file.path,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageSnap: false,
        ),
      ),
    ),
  );
}

Future<void> mostraGuidaStampa(BuildContext context, File file, String titolo) async {
  final conferma = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Stampa il curriculum'),
      content: const Text(
        'Si aprirà il menu di condivisione del telefono. Scegli «Stampa» '
        '(su iPhone) oppure un\'app di stampa o di visualizzazione PDF '
        '(su Android) per inviarlo alla stampante.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annulla')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Continua')),
      ],
    ),
  );
  if (conferma == true && context.mounted) {
    await condividiPdf(context, file, titolo: titolo);
  }
}

/// Elenco delle versioni PDF generate (nessuna viene sovrascritta).
Future<void> mostraVersioniPdf(BuildContext context, CurriculumCv cv) async {
  final res = await _conAttesa(context, CurriculaService.versioni(cv.id));
  if (res == null || !context.mounted) return;
  if (!res.ok) {
    mostraMessaggio(context, res.errore!);
    return;
  }
  final versioni = res.data!;
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetCtx) => SafeArea(
      child: versioni.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Non hai ancora generato un PDF per questo curriculum.'),
            )
          : ListView(
              shrinkWrap: true,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    'Versioni PDF',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    'Ogni generazione crea una nuova versione: le precedenti restano disponibili.',
                  ),
                ),
                for (final v in versioni)
                  ListTile(
                    leading: const Icon(Icons.picture_as_pdf_outlined),
                    title: Text('Versione ${v.versione}'),
                    subtitle: Text([
                      formatData(v.createdAt),
                      if (v.pagine != null) '${v.pagine} ${v.pagine == 1 ? 'pagina' : 'pagine'}',
                    ].where((e) => e.isNotEmpty).join(' · ')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      Navigator.pop(sheetCtx);
                      final file = await scaricaPdfCv(context, cv, versione: v.versione);
                      if (file != null && context.mounted) {
                        await apriPdf(context, file, titolo: '${cv.titolo} · v${v.versione}');
                      }
                    },
                  ),
              ],
            ),
    ),
  );
}
