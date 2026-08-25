# QA — Centro Notifiche, badge e push

## Backend
- [ ] Migration: tabella `user_notifications`, colonne `visibile_cliente` e `scadenza_avviso_inviato_at`
- [ ] `GET /api/notifications` (JWT) restituisce lista + `unread_count`
- [ ] `GET /api/notifications/unread-count`
- [ ] `PATCH /api/notifications/:id/read` aggiorna `unread_count`
- [ ] `POST /api/notifications/read-all` azzera badge
- [ ] Cambio stato pratica → riga inbox + push con `aps.badge`
- [ ] Integrazione documenti / appuntamento / pagamento → inbox
- [ ] Commento con “comunicazione al socio” → type `operator_message`
- [ ] Upload documenti-risultato (senza completa) → `document_ready`
- [ ] Completamento pratica → status (non doppio document_ready)
- [ ] Reply supporto operatore → `support_reply`
- [ ] Cron `POST /api/documenti/jobs/avvisi-scadenza` con `x-cron-token`
- [ ] Cron tessera già esistente usa inbox
- [ ] Category `promotional` non incrementa unread

## App Flutter
- [ ] Login → campanella in home con badge chip
- [ ] Centro Notifiche: lista, pull-to-refresh, segna tutte
- [ ] Tap notifica → mark read + deep link (calendario / supporto / documenti)
- [ ] Badge icona iOS aggiornato dopo push e dopo mark-read
- [ ] Badge Android best-effort (launcher dipendente)
- [ ] Foreground push mostra local notification e aggiorna contatore
- [ ] Cold start da push apre destinazione corretta
- [ ] Resume app richiama unread-count

## Admin
- [ ] Checkbox “Invia come comunicazione al socio” nei commenti pratica
