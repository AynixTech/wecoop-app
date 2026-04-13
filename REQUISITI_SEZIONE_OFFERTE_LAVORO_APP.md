# Requisiti Sezione App: Offerte di Lavoro

## 1) Obiettivo
Creare in app una sezione "Lavoro" (accessibile dal menu principale) dedicata ad annunci e offerte di lavoro per la comunita latina in Italia, con candidatura rapida e orientamento operativo.

## 2) Target utenti
- Persone della comunita latina residenti in Italia.
- Utenti con livello digitale base (UX semplice e guidata).
- Utenti bilingue italiano/spagnolo.

## 3) Voci e categorie principali annunci
Categorie prioritarie da visualizzare e filtrare:
- Baby sitter
- Badante
- Colf
- OSS / OSA
- ASO
- Segreteria
- Manicure / Onicotecnica
- Dentista / Odontoiatria
- Massaggi / Benessere
- Fotografo / Fotografa
- DJ
- Animatori / Animatrici
- Pulizie / Limpieza

## 4) Requisiti funzionali app (menu "Lavoro")
- Al click su "Lavoro" aprire schermata "Offerte e Annunci".
- Mostrare feed annunci con card: titolo, azienda, citta, tipo contratto, categoria, stato attivo.
- Evidenziare annunci "In evidenza" in alto.
- Ricerca testuale per parola chiave.
- Filtri rapidi: categoria, citta, regione, tipo contratto, modalita (presenza/remoto/ibrido), lingua richiesta.
- Ordinamento default: in evidenza, poi piu recenti.
- Pagina dettaglio annuncio con: descrizione, requisiti, contatti, scadenza, pulsante candidatura.
- Candidatura rapida da app con campi minimi: nome, telefono, email (opzionale), citta, nota, consenso privacy obbligatorio.
- Messaggio di conferma candidatura con id richiesta.
- Stato empty intelligente: suggerire categorie piu richieste.
- Link rapido WhatsApp quando disponibile nell'annuncio.

## 5) Requisiti contenuto e tono
- Linguaggio chiaro, inclusivo, orientato all'azione.
- Microcopy IT + ES (prioritario), EN opzionale.
- No tecnicismi complessi nei testi utente.
- Evidenziare sempre: documenti utili, disponibilita oraria, zona geografica.

## 6) Requisiti non funzionali
- Tempo risposta API lista annunci: target <= 800ms (cache lato server consigliata).
- Pagina lista con paginazione server-side.
- Validazioni input severe su candidatura.
- Rate limit candidature (anti-spam).
- Log eventi minimi (creazione candidatura, errori API).
- Compatibilita WordPress REST standard.

## 7) Contratto API backend (implementato)
Base route: `/wp-json/wecoop/v1/lavoro`

Endpoint:
- `GET /offerte`
  - Query params: `page`, `per_page`, `search`, `categoria`, `city`, `region`, `contract_type`, `work_mode`, `language`
- `GET /offerte/{id}`
- `GET /categorie`
- `POST /candidature`
  - Body: `offer_id`, `name`, `phone`, `email`, `city`, `note`, `origin`, `consent_privacy`

## 8) KPI suggeriti
- Numero annunci visualizzati per sessione.
- CTR su dettaglio annuncio.
- Tasso candidatura per categoria.
- Tempo medio tra apertura annuncio e candidatura.
- Categorie piu richieste per citta/regione.

## 9) Backoffice operativo
- Creazione/modifica annunci da WP Admin.
- Campi strutturati annuncio: azienda, localita, contratto, lingue, contatti, scadenza, attivo/in evidenza.
- Gestione candidature in area admin dedicata.

## 10) Roadmap evolutiva (fase 2)
- Matching profilo candidato-annuncio.
- Notifiche push per nuove offerte compatibili.
- Preferenze utente (categorie e zone favorite).
- Tracciamento stato candidatura lato utente (ricevuta, in revisione, chiusa).
