class Evento {
  final int id;
  final String titolo;
  final String slug;
  final String descrizione;
  final String dataInizio;
  final String? dataFine;
  final String? oraInizio;
  final String? oraFine;
  final bool online;
  final String? luogo;
  final String? indirizzo;
  final String? citta;
  final String? linkOnline;
  final int maxPartecipanti;
  final int partecipantiCount;
  final int postiDisponibili;
  final bool richiedeIscrizione;
  final double prezzo;
  final String prezzoFormattato;
  final String? organizzatore;
  final String? emailOrganizzatore;
  final String? telefonoOrganizzatore;
  final String stato;
  final String? immagineCopertina;
  final String? categoria;
  final List<GalleriaImmagine> galleria;
  final bool sonoIscritto;
  final String? programma;
  final String? dataPubblicazione;

  Evento({
    required this.id,
    required this.titolo,
    required this.slug,
    required this.descrizione,
    required this.dataInizio,
    this.dataFine,
    this.oraInizio,
    this.oraFine,
    required this.online,
    this.luogo,
    this.indirizzo,
    this.citta,
    this.linkOnline,
    required this.maxPartecipanti,
    required this.partecipantiCount,
    required this.postiDisponibili,
    required this.richiedeIscrizione,
    required this.prezzo,
    required this.prezzoFormattato,
    this.organizzatore,
    this.emailOrganizzatore,
    this.telefonoOrganizzatore,
    required this.stato,
    this.immagineCopertina,
    this.categoria,
    required this.galleria,
    this.sonoIscritto = false,
    this.programma,
    this.dataPubblicazione,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      if (value is int) return value != 0;
      return false;
    }

    return Evento(
      id: parseInt(json['id']),
      titolo: json['titolo'] ?? '',
      slug: json['slug'] ?? '',
      descrizione: json['descrizione'] ?? '',
      dataInizio: json['data_inizio'] ?? '',
      dataFine: json['data_fine'],
      oraInizio: json['ora_inizio'],
      oraFine: json['ora_fine'],
      online: parseBool(json['online']),
      luogo: json['luogo'],
      indirizzo: json['indirizzo'],
      citta: json['citta'],
      linkOnline: json['link_online'],
      maxPartecipanti: parseInt(json['max_partecipanti']),
      partecipantiCount: parseInt(json['partecipanti_count']),
      postiDisponibili: parseInt(json['posti_disponibili']),
      richiedeIscrizione: parseBool(json['richiede_iscrizione']),
      prezzo: (json['prezzo'] ?? 0.0).toDouble(),
      prezzoFormattato: json['prezzo_formattato'] ?? '€ 0,00',
      organizzatore: json['organizzatore'],
      emailOrganizzatore: json['email_organizzatore'],
      telefonoOrganizzatore: json['telefono_organizzatore'],
      stato: json['stato'] ?? '',
      immagineCopertina: json['immagine_copertina'],
      categoria: json['categoria'],
      galleria: (json['galleria'] as List<dynamic>?)
              ?.map((e) => GalleriaImmagine.fromJson(e))
              .toList() ??
          [],
      sonoIscritto: parseBool(json['sono_iscritto']),
      programma: json['programma'],
      dataPubblicazione: json['data_pubblicazione'],
    );
  }
}

class GalleriaImmagine {
  final int id;
  final String url;
  final String? thumbnail;
  final String? medium;
  final String? large;

  GalleriaImmagine({
    required this.id,
    required this.url,
    this.thumbnail,
    this.medium,
    this.large,
  });

  factory GalleriaImmagine.fromJson(Map<String, dynamic> json) {
    return GalleriaImmagine(
      id: json['id'] ?? 0,
      url: json['url'] ?? '',
      thumbnail: json['thumbnail'],
      medium: json['medium'],
      large: json['large'],
    );
  }
}
