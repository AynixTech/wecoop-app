import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wecoop_app/models/curriculum_cv.dart';
import 'package:wecoop_app/screens/cv/cv_editor_screen.dart';
import 'package:wecoop_app/screens/cv/i_miei_curriculum_screen.dart';
import 'package:wecoop_app/services/curricula_service.dart';

Map<String, dynamic> _cvJson(int id, {String stato = 'bozza', Map<String, dynamic>? dati, int? versione}) => {
  'id': id,
  'titolo': 'CV $id',
  'stato': stato,
  'origine': 'nuovo',
  'haFoto': false,
  'createdAt': '2026-10-20T10:00:00Z',
  'updatedAt': '2026-10-21T10:00:00Z',
  'ultimoPdf': versione == null ? null : {'versione': versione, 'createdAt': '2026-10-21T10:00:00Z', 'pagine': 1},
  'modificheNonGenerate': false,
  if (dati != null) 'dati': dati,
};

http.Response _json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json; charset=utf-8'});

void _phoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> _caricaFontReali() async {
  final dir = '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts';
  for (final famiglia in ['Roboto', 'Inter']) {
    final loader = FontLoader(famiglia);
    for (final peso in ['Regular', 'Medium', 'Bold']) {
      final file = File('$dir/Roboto-$peso.ttf');
      if (file.existsSync()) loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
    }
    await loader.load();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_caricaFontReali);

  group('CvDati', () {
    test('toJson / fromJson conserva tutti i campi', () {
      final dati = CvDati(
        nome: 'Ana',
        cognome: 'Pérez',
        email: 'ana@example.com',
        esperienze: [CvEsperienza(ruolo: 'Cameriera', periodo: CvPeriodo(inizio: '2021-03', inCorso: true))],
        altreLingue: [CvLingua(lingua: 'Italiano', livello: 'B2')],
        competenzeDigitali: ['Excel'],
        patenti: ['B'],
        includiFoto: true,
      );
      final copia = CvDati.fromJson(jsonDecode(jsonEncode(dati.toJson())) as Map<String, dynamic>);
      expect(copia.toJson(), dati.toJson());
      expect(copia.esperienze.first.periodo.etichetta, '03/2021 – in corso');
    });

    test('solo i dati essenziali bloccano il PDF', () {
      expect(CvDati().problemiPerPdf(), hasLength(3));
      final minimo = CvDati(nome: 'Mario', cognome: 'Rossi', telefono: '3331234567');
      expect(minimo.problemiPerPdf(), isEmpty);
      minimo.esperienze.add(CvEsperienza(ruolo: 'Autista', periodo: CvPeriodo(inizio: '2022-05', fine: '2021-01')));
      expect(minimo.problemiPerPdf().single, contains('fine'));
    });
  });

  group('I miei Curriculum', () {
    setUp(() => FlutterSecureStorage.setMockInitialValues({'jwt_token': 'test'}));

    testWidgets('senza CV propone «Crea il tuo primo CV»', (tester) async {
      _phoneSize(tester);
      final client = MockClient((req) async => _json({'ok': true, 'curricula': [], 'storico': []}));
      await http.runWithClient(() async {
        await tester.pumpWidget(const MaterialApp(home: IMieiCurriculumScreen()));
        await tester.pumpAndSettle();
      }, () => client);
      expect(find.text('Crea il tuo primo CV'), findsOneWidget);
    });

    testWidgets('con bozza e CV completato mostra ripresa ed elenco, e allinea la cache del servizio lavoro', (
      tester,
    ) async {
      _phoneSize(tester);
      final client = MockClient(
        (req) async => _json({
          'ok': true,
          'curricula': [_cvJson(1), _cvJson(2, stato: 'completato', versione: 2)],
          'storico': [
            {'id': 9, 'titolo': 'CV vecchio', 'createdAt': '2026-01-01T00:00:00Z', 'haPdf': true, 'importato': false},
          ],
        }),
      );
      await http.runWithClient(() async {
        await tester.pumpWidget(const MaterialApp(home: IMieiCurriculumScreen()));
        await tester.pumpAndSettle();
      }, () => client);
      expect(find.text('Riprendi compilazione'), findsOneWidget);
      expect(find.text('Inizia un nuovo CV'), findsOneWidget);
      expect(find.text('CV 2'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('CV vecchio'), 200);
      expect(find.text('Copia nel nuovo editor'), findsOneWidget);

      final cache = await const FlutterSecureStorage().read(key: CurriculaService.legacyCacheKey);
      final entries = (jsonDecode(cache!) as List).cast<Map>();
      expect(entries.single['cvId'], 'curricula-2');
      expect(entries.single['status'], 'generated');
    });

    testWidgets('modulo disattivato: messaggio chiaro, nessun vecchio wizard', (tester) async {
      _phoneSize(tester);
      final client = MockClient(
        (req) async => _json({
          'ok': false,
          'error': {'code': 'CV_MODULE_DISABLED', 'message': 'off'},
        }, 423),
      );
      await http.runWithClient(() async {
        await tester.pumpWidget(const MaterialApp(home: IMieiCurriculumScreen()));
        await tester.pumpAndSettle();
      }, () => client);
      expect(find.text('Servizio temporaneamente non disponibile'), findsOneWidget);
    });
  });

  group('Wizard CV', () {
    setUp(() => FlutterSecureStorage.setMockInitialValues({'jwt_token': 'test'}));

    for (final (larghezza, scala) in [(360.0, 1.0), (320.0, 1.3)]) {
      testWidgets('percorre gli 8 passaggi senza errori di layout (${larghezza.toInt()}px, testo x$scala)', (
        tester,
      ) async {
        tester.view.physicalSize = Size(larghezza * 3, 2340);
        tester.view.devicePixelRatio = 3;
        tester.platformDispatcher.textScaleFactorTestValue = scala;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final dati =
            CvDati(
              nome: 'Ștefania',
              cognome: 'Łukasiewicz',
              email: 'stefania@example.com',
              titoloProfilo: 'Responsabile di sala con una qualifica dal titolo molto lungo',
              esperienze: [
                CvEsperienza(
                  ruolo: 'Cameriera',
                  datore: 'Ristorante Ça Va',
                  periodo: CvPeriodo(inizio: '2019-03', inCorso: true),
                  descrizione: 'Gestione sala. ' * 20,
                ),
              ],
              altreLingue: [CvLingua(lingua: 'Italiano', livello: 'C1')],
              competenzeDigitali: ['Excel', 'Gestionali POS'],
            ).toJson();
        final client = MockClient((req) async => _json({'ok': true, 'cv': _cvJson(5, dati: dati)}));

        await http.runWithClient(() async {
          await tester.pumpWidget(const MaterialApp(home: CvEditorScreen(cvId: 5)));
          await tester.pumpAndSettle();
          expect(find.text('Passaggio 1 di 8'), findsOneWidget);
          for (var i = 2; i <= 8; i++) {
            await tester.ensureVisible(find.text('Avanti'));
            await tester.tap(find.text('Avanti'));
            await tester.pumpAndSettle();
            expect(find.text('Passaggio $i di 8'), findsOneWidget);
          }
          await tester.scrollUntilVisible(
          find.text('Genera PDF'),
          300,
          scrollable: find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down),
        );
        }, () => client);
        expect(find.text('Genera PDF'), findsOneWidget);
        expect(find.text('Avanti'), findsNothing);
      });
    }
  });
}
