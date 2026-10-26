/// Generatore CV V1.0 — modello dati (schema_version 1, speculare al backend
/// `/api/curricula`). Classi mutabili: il wizard le modifica direttamente.
library;

String _s(dynamic v) => v == null ? '' : v.toString();

List<String> _tags(dynamic v) =>
    v is List ? v.map(_s).where((e) => e.trim().isNotEmpty).toList() : <String>[];

List<Map<String, dynamic>> _maps(dynamic v) => v is List
    ? v
        .whereType<Map>()
        .map((e) => e.map((k, val) => MapEntry(k.toString(), val)))
        .toList()
    : <Map<String, dynamic>>[];

Map<String, dynamic> _map(dynamic v) => v is Map
    ? v.map((k, val) => MapEntry(k.toString(), val))
    : <String, dynamic>{};

int _idSeq = 0;
String nuovoIdVoce() =>
    'v${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}${_idSeq++}';

const livelliQcer = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

const descrizioneQcer = {
  'A1': 'A1 · Base',
  'A2': 'A2 · Elementare',
  'B1': 'B1 · Intermedio',
  'B2': 'B2 · Intermedio superiore',
  'C1': 'C1 · Avanzato',
  'C2': 'C2 · Padronanza',
};

/// Periodo in formato 'YYYY-MM' / 'YYYY' (stringa vuota = non indicato).
class CvPeriodo {
  String inizio;
  String fine;
  bool inCorso;

  CvPeriodo({this.inizio = '', this.fine = '', this.inCorso = false});

  static String _fmt(String s) {
    if (s.isEmpty) return '';
    final parts = s.split('-');
    return parts.length > 1 ? '${parts[1]}/${parts[0]}' : parts[0];
  }

  String get etichetta {
    final a = _fmt(inizio);
    final b = inCorso ? 'in corso' : _fmt(fine);
    if (a.isNotEmpty && b.isNotEmpty) return '$a – $b';
    if (a.isNotEmpty) return 'dal $a';
    if (b.isNotEmpty) return inCorso ? 'In corso' : 'fino al $b';
    return '';
  }

  bool get fineInvalida =>
      inizio.isNotEmpty && fine.isNotEmpty && !inCorso && fine.compareTo(inizio) < 0;
}

class CvEsperienza {
  String id;
  String ruolo;
  String datore;
  String localita;
  CvPeriodo periodo;
  String descrizione;

  CvEsperienza({
    String? id,
    this.ruolo = '',
    this.datore = '',
    this.localita = '',
    CvPeriodo? periodo,
    this.descrizione = '',
  })  : id = id ?? nuovoIdVoce(),
        periodo = periodo ?? CvPeriodo();

  factory CvEsperienza.fromJson(Map<String, dynamic> j) => CvEsperienza(
        id: _s(j['id']).isEmpty ? null : _s(j['id']),
        ruolo: _s(j['ruolo']),
        datore: _s(j['datore']),
        localita: _s(j['localita']),
        periodo: CvPeriodo(
          inizio: _s(j['inizio']),
          fine: _s(j['fine']),
          inCorso: j['inCorso'] == true,
        ),
        descrizione: _s(j['descrizione']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ruolo': ruolo,
        'datore': datore,
        'localita': localita,
        'inizio': periodo.inizio,
        'fine': periodo.inCorso ? '' : periodo.fine,
        'inCorso': periodo.inCorso,
        'descrizione': descrizione,
      };

  CvEsperienza copia() => CvEsperienza.fromJson(toJson());
}

class CvIstruzione {
  String id;
  String titolo;
  String istituto;
  String localita;
  CvPeriodo periodo;
  String descrizione;

  CvIstruzione({
    String? id,
    this.titolo = '',
    this.istituto = '',
    this.localita = '',
    CvPeriodo? periodo,
    this.descrizione = '',
  })  : id = id ?? nuovoIdVoce(),
        periodo = periodo ?? CvPeriodo();

  factory CvIstruzione.fromJson(Map<String, dynamic> j) => CvIstruzione(
        id: _s(j['id']).isEmpty ? null : _s(j['id']),
        titolo: _s(j['titolo']),
        istituto: _s(j['istituto']),
        localita: _s(j['localita']),
        periodo: CvPeriodo(
          inizio: _s(j['inizio']),
          fine: _s(j['fine']),
          inCorso: j['inCorso'] == true,
        ),
        descrizione: _s(j['descrizione']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'titolo': titolo,
        'istituto': istituto,
        'localita': localita,
        'inizio': periodo.inizio,
        'fine': periodo.inCorso ? '' : periodo.fine,
        'inCorso': periodo.inCorso,
        'descrizione': descrizione,
      };

  CvIstruzione copia() => CvIstruzione.fromJson(toJson());
}

class CvLingua {
  String id;
  String lingua;
  String livello;
  String note;

  CvLingua({String? id, this.lingua = '', this.livello = '', this.note = ''})
      : id = id ?? nuovoIdVoce();

  factory CvLingua.fromJson(Map<String, dynamic> j) => CvLingua(
        id: _s(j['id']).isEmpty ? null : _s(j['id']),
        lingua: _s(j['lingua']),
        livello: _s(j['livello']),
        note: _s(j['note']),
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'lingua': lingua, 'livello': livello, 'note': note};

  CvLingua copia() => CvLingua.fromJson(toJson());
}

class CvCertificazione {
  String id;
  String titolo;
  String ente;
  String anno;

  CvCertificazione({String? id, this.titolo = '', this.ente = '', this.anno = ''})
      : id = id ?? nuovoIdVoce();

  factory CvCertificazione.fromJson(Map<String, dynamic> j) => CvCertificazione(
        id: _s(j['id']).isEmpty ? null : _s(j['id']),
        titolo: _s(j['titolo']),
        ente: _s(j['ente']),
        anno: _s(j['anno']),
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'titolo': titolo, 'ente': ente, 'anno': anno};

  CvCertificazione copia() => CvCertificazione.fromJson(toJson());
}

class CvProgetto {
  String id;
  String titolo;
  String descrizione;

  CvProgetto({String? id, this.titolo = '', this.descrizione = ''})
      : id = id ?? nuovoIdVoce();

  factory CvProgetto.fromJson(Map<String, dynamic> j) => CvProgetto(
        id: _s(j['id']).isEmpty ? null : _s(j['id']),
        titolo: _s(j['titolo']),
        descrizione: _s(j['descrizione']),
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'titolo': titolo, 'descrizione': descrizione};

  CvProgetto copia() => CvProgetto.fromJson(toJson());
}

class CvVolontariato {
  String id;
  String ruolo;
  String organizzazione;
  CvPeriodo periodo;
  String descrizione;

  CvVolontariato({
    String? id,
    this.ruolo = '',
    this.organizzazione = '',
    CvPeriodo? periodo,
    this.descrizione = '',
  })  : id = id ?? nuovoIdVoce(),
        periodo = periodo ?? CvPeriodo();

  factory CvVolontariato.fromJson(Map<String, dynamic> j) => CvVolontariato(
        id: _s(j['id']).isEmpty ? null : _s(j['id']),
        ruolo: _s(j['ruolo']),
        organizzazione: _s(j['organizzazione']),
        periodo: CvPeriodo(
          inizio: _s(j['inizio']),
          fine: _s(j['fine']),
          inCorso: j['inCorso'] == true,
        ),
        descrizione: _s(j['descrizione']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ruolo': ruolo,
        'organizzazione': organizzazione,
        'inizio': periodo.inizio,
        'fine': periodo.inCorso ? '' : periodo.fine,
        'inCorso': periodo.inCorso,
        'descrizione': descrizione,
      };

  CvVolontariato copia() => CvVolontariato.fromJson(toJson());
}

class CvLink {
  String id;
  String etichetta;
  String url;

  CvLink({String? id, this.etichetta = '', this.url = ''}) : id = id ?? nuovoIdVoce();

  factory CvLink.fromJson(Map<String, dynamic> j) => CvLink(
        id: _s(j['id']).isEmpty ? null : _s(j['id']),
        etichetta: _s(j['etichetta']),
        url: _s(j['url']),
      );

  Map<String, dynamic> toJson() => {'id': id, 'etichetta': etichetta, 'url': url};
}

class CvDati {
  String nome;
  String cognome;
  String email;
  String telefono;
  String citta;
  List<CvLink> links;
  String titoloProfilo;
  String presentazione;
  List<CvEsperienza> esperienze;
  List<CvIstruzione> istruzione;
  List<String> madrelingua;
  List<CvLingua> altreLingue;
  List<String> competenzeDigitali;
  List<String> competenzeProfessionali;
  List<String> competenzeOrganizzative;
  List<String> competenzeRelazionali;
  List<CvCertificazione> certificazioni;
  List<CvProgetto> progetti;
  List<CvVolontariato> volontariato;
  List<String> patenti;
  String altro;
  bool includiFoto;

  CvDati({
    this.nome = '',
    this.cognome = '',
    this.email = '',
    this.telefono = '',
    this.citta = '',
    List<CvLink>? links,
    this.titoloProfilo = '',
    this.presentazione = '',
    List<CvEsperienza>? esperienze,
    List<CvIstruzione>? istruzione,
    List<String>? madrelingua,
    List<CvLingua>? altreLingue,
    List<String>? competenzeDigitali,
    List<String>? competenzeProfessionali,
    List<String>? competenzeOrganizzative,
    List<String>? competenzeRelazionali,
    List<CvCertificazione>? certificazioni,
    List<CvProgetto>? progetti,
    List<CvVolontariato>? volontariato,
    List<String>? patenti,
    this.altro = '',
    this.includiFoto = false,
  })  : links = links ?? [],
        esperienze = esperienze ?? [],
        istruzione = istruzione ?? [],
        madrelingua = madrelingua ?? [],
        altreLingue = altreLingue ?? [],
        competenzeDigitali = competenzeDigitali ?? [],
        competenzeProfessionali = competenzeProfessionali ?? [],
        competenzeOrganizzative = competenzeOrganizzative ?? [],
        competenzeRelazionali = competenzeRelazionali ?? [],
        certificazioni = certificazioni ?? [],
        progetti = progetti ?? [],
        volontariato = volontariato ?? [],
        patenti = patenti ?? [];

  factory CvDati.fromJson(Map<String, dynamic> j) {
    final p = _map(j['personali']);
    final prof = _map(j['profilo']);
    final lingue = _map(j['lingue']);
    final comp = _map(j['competenze']);
    final agg = _map(j['aggiuntive']);
    final imp = _map(j['impostazioni']);
    return CvDati(
      nome: _s(p['nome']),
      cognome: _s(p['cognome']),
      email: _s(p['email']),
      telefono: _s(p['telefono']),
      citta: _s(p['citta']),
      links: _maps(p['links']).map(CvLink.fromJson).toList(),
      titoloProfilo: _s(prof['titolo']),
      presentazione: _s(prof['presentazione']),
      esperienze: _maps(j['esperienze']).map(CvEsperienza.fromJson).toList(),
      istruzione: _maps(j['istruzione']).map(CvIstruzione.fromJson).toList(),
      madrelingua: _tags(lingue['madrelingua']),
      altreLingue: _maps(lingue['altre']).map(CvLingua.fromJson).toList(),
      competenzeDigitali: _tags(comp['digitali']),
      competenzeProfessionali: _tags(comp['professionali']),
      competenzeOrganizzative: _tags(comp['organizzative']),
      competenzeRelazionali: _tags(comp['relazionali']),
      certificazioni: _maps(agg['certificazioni']).map(CvCertificazione.fromJson).toList(),
      progetti: _maps(agg['progetti']).map(CvProgetto.fromJson).toList(),
      volontariato: _maps(agg['volontariato']).map(CvVolontariato.fromJson).toList(),
      patenti: _tags(agg['patenti']),
      altro: _s(agg['altro']),
      includiFoto: imp['includiFoto'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'personali': {
          'nome': nome,
          'cognome': cognome,
          'email': email,
          'telefono': telefono,
          'citta': citta,
          'links': links.map((e) => e.toJson()).toList(),
        },
        'profilo': {'titolo': titoloProfilo, 'presentazione': presentazione},
        'esperienze': esperienze.map((e) => e.toJson()).toList(),
        'istruzione': istruzione.map((e) => e.toJson()).toList(),
        'lingue': {
          'madrelingua': madrelingua,
          'altre': altreLingue.map((e) => e.toJson()).toList(),
        },
        'competenze': {
          'digitali': competenzeDigitali,
          'professionali': competenzeProfessionali,
          'organizzative': competenzeOrganizzative,
          'relazionali': competenzeRelazionali,
        },
        'aggiuntive': {
          'certificazioni': certificazioni.map((e) => e.toJson()).toList(),
          'progetti': progetti.map((e) => e.toJson()).toList(),
          'volontariato': volontariato.map((e) => e.toJson()).toList(),
          'patenti': patenti,
          'altro': altro,
        },
        'impostazioni': {'includiFoto': includiFoto},
      };

  static final _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  /// Specchio di `validateForPdf` del backend: solo i dati essenziali.
  List<String> problemiPerPdf() {
    final out = <String>[];
    if (nome.trim().isEmpty) out.add('Inserisci il nome (Dati personali).');
    if (cognome.trim().isEmpty) out.add('Inserisci il cognome (Dati personali).');
    if (email.trim().isEmpty && telefono.trim().isEmpty) {
      out.add('Inserisci almeno un recapito: email o telefono (Dati personali).');
    }
    if (email.trim().isNotEmpty && !_emailRe.hasMatch(email.trim())) {
      out.add("L'indirizzo email non è valido (Dati personali).");
    }
    if (telefono.trim().isNotEmpty &&
        telefono.replaceAll(RegExp(r'\D'), '').length < 6) {
      out.add('Il numero di telefono non è valido (Dati personali).');
    }
    for (var i = 0; i < esperienze.length; i++) {
      if (esperienze[i].ruolo.trim().isEmpty) {
        out.add('Esperienza ${i + 1}: indica il ruolo.');
      }
      if (esperienze[i].periodo.fineInvalida) {
        out.add('Esperienza ${i + 1}: la data di fine è precedente all\'inizio.');
      }
    }
    for (var i = 0; i < istruzione.length; i++) {
      if (istruzione[i].titolo.trim().isEmpty) {
        out.add('Istruzione ${i + 1}: indica il titolo.');
      }
      if (istruzione[i].periodo.fineInvalida) {
        out.add('Istruzione ${i + 1}: la data di fine è precedente all\'inizio.');
      }
    }
    return out;
  }
}

class CvPdfInfo {
  final int versione;
  final DateTime? createdAt;
  final int? pagine;

  const CvPdfInfo({required this.versione, this.createdAt, this.pagine});

  factory CvPdfInfo.fromJson(Map<String, dynamic> j) => CvPdfInfo(
        versione: (j['versione'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.tryParse(_s(j['createdAt'])),
        pagine: (j['pagine'] as num?)?.toInt(),
      );
}

class CurriculumCv {
  final int id;
  String titolo;
  String stato; // 'bozza' | 'completato'
  final String origine;
  bool haFoto;
  final DateTime? createdAt;
  DateTime? updatedAt;
  CvPdfInfo? ultimoPdf;
  bool modificheNonGenerate;
  CvDati? dati;

  CurriculumCv({
    required this.id,
    required this.titolo,
    required this.stato,
    required this.origine,
    required this.haFoto,
    this.createdAt,
    this.updatedAt,
    this.ultimoPdf,
    this.modificheNonGenerate = false,
    this.dati,
  });

  bool get isBozza => stato != 'completato';

  factory CurriculumCv.fromJson(Map<String, dynamic> j) => CurriculumCv(
        id: (j['id'] as num).toInt(),
        titolo: _s(j['titolo']),
        stato: _s(j['stato']),
        origine: _s(j['origine']),
        haFoto: j['haFoto'] == true,
        createdAt: DateTime.tryParse(_s(j['createdAt'])),
        updatedAt: DateTime.tryParse(_s(j['updatedAt'])),
        ultimoPdf: j['ultimoPdf'] is Map ? CvPdfInfo.fromJson(_map(j['ultimoPdf'])) : null,
        modificheNonGenerate: j['modificheNonGenerate'] == true,
        dati: j['dati'] is Map ? CvDati.fromJson(_map(j['dati'])) : null,
      );
}

/// CV creato con il vecchio generatore (cv_documents): sola lettura.
class CurriculumStorico {
  final int id;
  final String titolo;
  final DateTime? createdAt;
  final bool haPdf;
  final bool importato;

  const CurriculumStorico({
    required this.id,
    required this.titolo,
    this.createdAt,
    required this.haPdf,
    required this.importato,
  });

  factory CurriculumStorico.fromJson(Map<String, dynamic> j) => CurriculumStorico(
        id: (j['id'] as num).toInt(),
        titolo: _s(j['titolo']),
        createdAt: DateTime.tryParse(_s(j['createdAt'])),
        haPdf: j['haPdf'] == true,
        importato: j['importato'] == true,
      );
}
