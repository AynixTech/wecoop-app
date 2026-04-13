# WECOOP - Handoff WordPress

## Obiettivo

Portare su WordPress la sezione **Progetti e Opportunità** in modo che i contenuti siano gestiti dal team operativo, senza dover rilasciare una nuova versione dell'app per ogni aggiornamento.

La logica editoriale deve essere:

- categorie principali per **obiettivo**
- contenuti concreti e azionabili
- tag come filtri secondari
- una CTA chiara per ogni card

## Nome sezione

**Progetti e Opportunità**

Sottotitolo suggerito:

> Contenuti operativi, opportunità concrete e aggiornamenti brevi curati dal team WECOOP.

## Struttura corretta

### Livello 1: categorie principali

Le categorie non devono essere per target tipo "giovani", "donne", "migranti".

Le categorie devono essere per obiettivo:

1. Formazione
2. Lavoro
3. Imprenditorialità
4. Inclusione sociale

### Livello 2: contenuti reali dentro ogni categoria

#### Formazione

- Corso digital marketing
- Corso lingua italiana
- Formazione professionale

#### Lavoro

- Programma inserimento lavorativo
- Collaborazione con agenzie
- Stage / tirocini

#### Imprenditorialità

- Microcredito WECOOP
- Supporto apertura attività
- Mentorship

#### Inclusione sociale

- Supporto donne
- Integrazione migranti
- Attività comunitarie

## Dove mettere Giovani, Donne, Migranti

Non come sezione principale.

Devono essere **tag/filtro**.

Esempi:

- Corso lingua italiana -> tag: migranti
- Programma lavoro -> tag: giovani
- Microcredito WECOOP -> tag: donne

Tag consigliati iniziali:

- Giovani
- Donne
- Migranti
- Famiglie
- Studenti
- Imprenditori

## Struttura editoriale dei contenuti

Ogni contenuto deve essere una **card azionabile**.

Formato minimo:

- titolo breve
- descrizione breve di 3-4 righe massimo
- una sola azione chiara
- categoria principale
- uno o più tag
- tipo contenuto
- CTA finale

### Esempi corretti

- Nuova procedura permesso di soggiorno 2026 -> CTA: Richiedi assistenza
- Aziende cercano operai a Milano -> CTA: Candidati
- Nuove opportunità di microcredito -> CTA: Scopri se puoi accedere
- Corso gratuito digital marketing -> CTA: Partecipa

## Tipi di contenuto

Ogni contenuto deve avere anche una classificazione editoriale.

Tipi consigliati:

1. Operativo
2. Opportunità
3. Educativo breve

### Mix editoriale ideale

Frequenza consigliata: **3 contenuti a settimana**

Distribuzione:

1. 1 contenuto operativo
2. 1 contenuto opportunità
3. 1 contenuto educativo breve

### Descrizione dei tipi

#### Operativo

Contenuti ad alto valore pratico:

- novità su documenti
- cambi normativi
- procedure

#### Opportunità

Contenuti che generano azione:

- lavoro
- corsi
- bandi
- microcredito

#### Educativo breve

Contenuti che costruiscono fiducia:

- Come fare...
- Attenzione a...

## Modello WordPress consigliato

### Opzione consigliata

Usare un **Custom Post Type** dedicato.

Nome suggerito:

- `opportunita_wecoop`

### Tassonomie

#### Tassonomia 1: categoria principale

Taxonomy suggerita:

- `categoria_opportunita`

Valori:

- Formazione
- Lavoro
- Imprenditorialità
- Inclusione sociale

#### Tassonomia 2: tag/filtro

Taxonomy suggerita:

- `tag_opportunita`

Valori iniziali:

- Giovani
- Donne
- Migranti
- Famiglie
- Studenti
- Imprenditori

#### Tassonomia 3: tipo contenuto

Taxonomy suggerita:

- `tipo_contenuto_opportunita`

Valori:

- Operativo
- Opportunità
- Educativo breve

## Campi consigliati

Usare ACF o campi custom equivalenti.

Campi suggeriti:

- `card_title`
- `card_excerpt`
- `cta_label`
- `cta_url`
- `cta_type`
- `priority_order`
- `is_featured`
- `publish_in_app`
- `language`
- `cover_image`
- `icon_name`

### Significato dei campi

#### `card_title`

Titolo breve da mostrare in card.

#### `card_excerpt`

Testo breve da mostrare in card. Ideale: 160-220 caratteri.

#### `cta_label`

Etichetta pulsante. Esempi:

- Richiedi assistenza
- Candidati
- Partecipa
- Scopri se puoi accedere

#### `cta_url`

Destinazione della CTA:

- pagina WordPress
- form
- link esterno
- deep link app

#### `cta_type`

Valori suggeriti:

- `internal_page`
- `external_url`
- `form`
- `app_deeplink`

#### `priority_order`

Intero numerico per ordinamento manuale.

#### `is_featured`

Booleano per evidenziare alcune opportunità in alto.

#### `publish_in_app`

Booleano per decidere se il contenuto deve essere visibile nell'app.

#### `language`

Se gestite contenuti multilingua, indicare:

- `it`
- `en`
- `es`

#### `cover_image`

Immagine principale card/dettaglio.

#### `icon_name`

Nome icona da mappare lato app se serve una resa grafica coerente.

## API / output richiesto per app

L'app ha bisogno di questi dati minimi per ogni contenuto:

- `id`
- `title`
- `excerpt`
- `category`
- `tags`
- `content_type`
- `cta_label`
- `cta_url`
- `image`
- `is_featured`
- `priority_order`
- `published_at`

## Ordinamento consigliato

Ordine di visualizzazione:

1. contenuti con `is_featured = true`
2. `priority_order` crescente
3. data pubblicazione decrescente

## Regole UX

Ogni card deve avere:

- titolo breve
- testo sintetico
- una sola CTA
- categoria principale leggibile
- eventuali tag come filtro secondario

Regole importanti:

- non usare testi lunghi in card
- non mettere più di una CTA primaria
- evitare categorie per target come primo livello
- privilegiare contenuti ad alta utilità pratica

## Governance contenuti

Questa sezione deve essere gestita da una persona operativa WECOOP, non generata automaticamente.

Workflow suggerito:

1. il team operativo inserisce o aggiorna il contenuto da WordPress
2. il contenuto viene classificato con categoria, tag e tipo contenuto
3. viene definita una CTA chiara
4. il contenuto viene pubblicato e reso disponibile all'app

## Esempio contenuto completo

### Esempio 1

- Titolo: Nuove regole permesso di soggiorno
- Excerpt: Cambia la procedura per il rinnovo. Serve appuntamento anticipato e documentazione aggiornata.
- Categoria: Inclusione sociale
- Tag: Migranti
- Tipo contenuto: Operativo
- CTA label: Richiedi assistenza
- CTA URL: pagina supporto o modulo richiesta

### Esempio 2

- Titolo: Corso gratuito digital marketing
- Excerpt: Percorso breve per imparare strumenti digitali utili per lavoro o autoimpiego.
- Categoria: Formazione
- Tag: Giovani, Donne
- Tipo contenuto: Opportunità
- CTA label: Partecipa
- CTA URL: pagina iscrizione corso

### Esempio 3

- Titolo: Nuove opportunità di microcredito
- Excerpt: Verifica se il tuo profilo può accedere a un supporto finanziario per avviare una piccola attività.
- Categoria: Imprenditorialità
- Tag: Donne, Imprenditori
- Tipo contenuto: Opportunità
- CTA label: Scopri se puoi accedere
- CTA URL: pagina microcredito o form pre-valutazione

## Deliverable WordPress minimi

Per partire servono:

1. CPT `opportunita_wecoop`
2. tassonomia categoria principale
3. tassonomia tag/filtro
4. tassonomia tipo contenuto
5. campi custom per CTA e ordinamento
6. endpoint REST o query standard per app
7. backoffice semplice per team operativo

## Nota finale

L'obiettivo non è avere una sezione descrittiva, ma una sezione che generi azione.

**Progetti e Opportunità** deve diventare un motore di conversione:

- informa
- orienta
- attiva
- porta l'utente verso una richiesta o un contatto concreto