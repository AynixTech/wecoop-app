# Risposta a Lizandro — Centro Notifiche e badge

Ciao Lizandro,

grazie per la proposta: è allineata alla direzione che stiamo dando all’app (accompagnamento continuo, non solo consultazione on-demand).

**Cosa c’è già**  
L’app Flutter riceve già push via Firebase (FCM) su diversi eventi di pratica (cambio stato, integrazione documentale, appuntamenti/promemoria, avvisi scadenza tessera). I permessi badge su iOS sono già richiesti.

**Cosa costruiremo**  
1. **Centro Notifiche** in app, con elenco lette / non lette e apertura diretta della pratica, documento o servizio collegato.  
2. **Badge sull’icona** con il numero delle notifiche operative non lette; il contatore si aggiorna quando l’utente apre/legge la notifica.  
3. **Solo comunicazioni operative** nel badge (nuova comunicazione, stato pratica, documento disponibile/richiesto, appuntamento/promemoria, scadenza, risposta a richiesta). I contenuti promozionali potranno restare informativi ma **non incrementeranno il badge**.  
4. Completamento dei gap oggi assenti (es. risposta supporto, documento di output disponibile, scadenze documenti con push).

Flusso: evento piattaforma → salvataggio in inbox → push sul telefono → badge → Centro Notifiche → deep link all’oggetto.

Ti aggiorniamo con una timeline di rilascio (backend + app) e, a breve, un’anteprima del Centro Notifiche.

Cordiali saluti,  
Anthony
