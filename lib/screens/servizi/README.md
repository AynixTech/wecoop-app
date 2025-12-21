# Sistema di Gestione Servizi WECOOP

## Struttura dell'applicazione

### 📁 Organizzazione delle schermate

```
lib/screens/servizi/
├── accoglienza_screen.dart          # Servizi di accoglienza e orientamento
├── permesso_soggiorno_screen.dart   # Sotto-livello: tipi di permesso
├── cittadinanza_screen.dart         # Richiesta cittadinanza con verifica requisiti
├── asilo_politico_screen.dart       # Protezione internazionale
├── visa_turismo_screen.dart         # Visto turistico
├── mediazione_fiscale_screen.dart   # Servizi fiscali
├── supporto_contabile_screen.dart   # Servizi contabili
└── richiesta_form_screen.dart       # Form dinamico generico
```

## 🎯 Flusso utente

### 1. **Home Screen**
L'utente vede 3 pulsanti principali:
- Accoglienza e Orientamento
- Mediazione Fiscale
- Supporto Contabile

### 2. **Schermate di primo livello**

#### Accoglienza e Orientamento
→ 4 opzioni:
- **Permesso di Soggiorno** → Schermata con 4 sotto-opzioni
  - Per Lavoro Subordinato → Form
  - Per Lavoro Autonomo → Form
  - Per Motivi Familiari → Form
  - Per Studiare in Italia → Form
- **Cittadinanza** → Verifica requisiti (10 anni) → Form
- **Asilo Politico** → Form diretto
- **Visa per Turismo** → Form diretto

#### Mediazione Fiscale
→ 2 opzioni:
- **730** → Form per dipendenti/pensionati
- **Persona Fisica** → Form per dichiarazione redditi

#### Supporto Contabile
→ 5 opzioni:
- **Aprire Partita IVA** → Form
- **Gestire la Partita IVA** → Form
- **Tasse e Contributi** → Form
- **Chiarimenti e Consulenza** → Form
- **Chiudere o Cambiare Attività** → Form

### 3. **Form dinamico**
Il `RichiestaFormScreen` è un componente riutilizzabile che:
- Genera automaticamente i campi in base alla configurazione
- Supporta tipi: text, textarea, number, date, select
- Valida i campi obbligatori
- Invia i dati al CRM via API

## 📋 Tipi di campi supportati

```dart
{
  'label': 'Nome campo',
  'type': 'text|textarea|number|date|select',
  'required': true|false,
  'options': ['Opzione 1', 'Opzione 2'], // Solo per select
}
```

## 🔌 Integrazione CRM

Il file `richiesta_form_screen.dart` invia i dati al CRM tramite POST HTTP:

```dart
POST https://your-crm-api.com/richieste
Content-Type: application/json

{
  "servizio": "Nome servizio",
  "categoria": "Categoria specifica",
  "data_richiesta": "2025-12-21T10:30:00.000Z",
  "campi": {
    "Nome completo": "Mario Rossi",
    "Data di nascita": "15/03/1990",
    // ... altri campi
  }
}
```

### Configurazione endpoint CRM

Modifica la riga 170 in `richiesta_form_screen.dart`:

```dart
final response = await http.post(
  Uri.parse('TUO_ENDPOINT_CRM_QUI'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode(data),
);
```

## 🎨 Personalizzazione

### Aggiungere un nuovo servizio principale

1. Creare una nuova screen in `lib/screens/servizi/`
2. Aggiornare `home_screen.dart` per aggiungere il pulsante
3. Definire le sotto-categorie

### Aggiungere una nuova sotto-categoria

Esempio per aggiungere "Rinnovo Patente" in Accoglienza:

```dart
_ServiceOptionCard(
  icon: Icons.directions_car,
  title: 'Rinnovo Patente',
  description: 'Rinnovo patente di guida',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RichiestaFormScreen(
          servizio: 'Accoglienza e Orientamento',
          categoria: 'Rinnovo Patente',
          campi: const [
            {'label': 'Nome completo', 'type': 'text', 'required': true},
            // ... altri campi
          ],
        ),
      ),
    );
  },
),
```

## 🔧 Funzionalità implementate

✅ Navigazione multi-livello (Home → Servizio → Sotto-categoria → Form)  
✅ Form dinamici con validazione  
✅ Campi di diversi tipi (testo, data, select, numero)  
✅ Verifica prerequisiti (es. 10 anni per cittadinanza)  
✅ Integrazione API/CRM  
✅ Feedback visivo all'utente  
✅ Dialog di conferma dopo invio  

## 🚀 Prossimi passi

- [ ] Configurare endpoint CRM reale
- [ ] Aggiungere upload documenti
- [ ] Implementare autenticazione per tracciare le richieste
- [ ] Dashboard per vedere stato richieste
- [ ] Notifiche push quando ci sono aggiornamenti
- [ ] Traduzione multilingua
