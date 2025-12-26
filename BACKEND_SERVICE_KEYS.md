# 🔑 Chiavi Standardizzate - Servizi e Categorie

## Problema Risolto

Le richieste di servizio arrivano dall'app in **3 lingue diverse** (italiano, inglese, spagnolo), causando duplicazioni nella dashboard backend:
- "Permesso di Soggiorno" (italiano)
- "Residence Permit" (inglese)  
- "Permiso de Residencia" (spagnolo)

**Soluzione**: L'app ora invia **chiavi standardizzate in inglese** indipendentemente dalla lingua dell'interfaccia utente.

---

## 📊 Mappatura Servizi

| Chiave Standard | Italiano | English | Español |
|----------------|----------|---------|---------|
| `caf_tax_assistance` | CAF - Assistenza Fiscale | CAF - Tax Assistance | CAF - Asistencia Fiscal |
| `immigration_desk` | Sportello Immigrazione | Immigration Desk | Oficina de Inmigración |
| `accounting_support` | Supporto Contabile | Accounting Support | Soporte Contable |
| `tax_mediation` | Mediazione Fiscale | Tax Mediation | Mediación Fiscal |

---

## 📋 Mappatura Categorie

### CAF - Assistenza Fiscale
| Chiave Standard | Italiano | English | Español |
|----------------|----------|---------|---------|
| `tax_return_730` | Dichiarazione dei Redditi (730) | Tax Return (730) | Declaración de la Renta (730) |
| `form_compilation` | Compilazione Modelli | Form Compilation | Compilación de Formularios |

### Sportello Immigrazione
| Chiave Standard | Italiano | English | Español |
|----------------|----------|---------|---------|
| `residence_permit` | Permesso di Soggiorno | Residence Permit | Permiso de Residencia |
| `citizenship` | Cittadinanza | Citizenship | Ciudadanía |
| `tourist_visa` | Visto Turistico | Tourist Visa | Visa Turística |
| `asylum_request` | Richiesta Asilo | Asylum Request | Solicitud de Asilo |

### Supporto Contabile
| Chiave Standard | Italiano | English | Español |
|----------------|----------|---------|---------|
| `income_tax_return` | Dichiarazione Redditi | Income Tax Return | Declaración de Renta |
| `vat_number_opening` | Apertura Partita IVA | VAT Number Opening | Apertura de Partita IVA |
| `accounting_management` | Gestione Contabilità | Accounting Management | Gestión de Contabilidad |
| `tax_compliance` | Adempimenti Fiscali | Tax Compliance | Cumplimientos Fiscales |
| `tax_consultation` | Consulenza Fiscale | Tax Consultation | Consultoría Fiscal |

### Mediazione Fiscale
| Chiave Standard | Italiano | English | Español |
|----------------|----------|---------|---------|
| `tax_debt_management` | Gestione Debiti Fiscali | Tax Debt Management | Gestión de Deudas Fiscales |

---

## 💾 Implementazione Backend

### 1. Database

Le richieste vengono salvate con le **chiavi standard**:

```sql
INSERT INTO wp_wecoop_richieste_servizi (
  servizio,
  categoria,
  ...
) VALUES (
  'immigration_desk',        -- Non più "Permesso di Soggiorno" / "Residence Permit"
  'residence_permit',         -- Chiave unica
  ...
);
```

### 2. Query Dashboard

**Raggruppamento per tipo di servizio** (ora funziona correttamente):

```sql
SELECT 
  servizio,
  COUNT(*) as totale_richieste
FROM wp_wecoop_richieste_servizi
GROUP BY servizio;
```

**Risultato**:
```
| servizio            | totale_richieste |
|---------------------|------------------|
| immigration_desk    | 45               |  ✅ Tutte le richieste insieme
| caf_tax_assistance  | 32               |
| accounting_support  | 18               |
| tax_mediation       | 7                |
```

**Prima della standardizzazione** (problema):
```
| servizio                      | totale_richieste |
|-------------------------------|------------------|
| Permesso di Soggiorno         | 15               |  ❌ Duplicato italiano
| Residence Permit              | 20               |  ❌ Duplicato inglese
| Permiso de Residencia         | 10               |  ❌ Duplicato spagnolo
| Sportello Immigrazione        | 8                |
| Immigration Desk              | 12               |
```

### 3. Filtraggio Richieste

```sql
-- Trova tutte le richieste di permesso di soggiorno
SELECT * FROM wp_wecoop_richieste_servizi
WHERE servizio = 'immigration_desk'
AND categoria = 'residence_permit';
```

### 4. Statistiche per Categoria

```sql
SELECT 
  servizio,
  categoria,
  COUNT(*) as totale,
  AVG(DATEDIFF(updated_at, created_at)) as giorni_medi_lavorazione
FROM wp_wecoop_richieste_servizi
WHERE stato = 'completata'
GROUP BY servizio, categoria
ORDER BY totale DESC;
```

---

## 🎨 Visualizzazione Dashboard

### Funzione Helper PHP per Tradurre le Chiavi

```php
<?php
/**
 * Converte chiave standard in nome leggibile nella lingua corrente
 */
function get_service_display_name($service_key, $lang = 'it') {
    $names = [
        'caf_tax_assistance' => [
            'it' => 'CAF - Assistenza Fiscale',
            'en' => 'CAF - Tax Assistance',
            'es' => 'CAF - Asistencia Fiscal',
        ],
        'immigration_desk' => [
            'it' => 'Sportello Immigrazione',
            'en' => 'Immigration Desk',
            'es' => 'Oficina de Inmigración',
        ],
        'accounting_support' => [
            'it' => 'Supporto Contabile',
            'en' => 'Accounting Support',
            'es' => 'Soporte Contable',
        ],
        'tax_mediation' => [
            'it' => 'Mediazione Fiscale',
            'en' => 'Tax Mediation',
            'es' => 'Mediación Fiscal',
        ],
    ];
    
    return $names[$service_key][$lang] ?? $service_key;
}

function get_category_display_name($category_key, $lang = 'it') {
    $names = [
        'tax_return_730' => [
            'it' => 'Dichiarazione dei Redditi (730)',
            'en' => 'Tax Return (730)',
            'es' => 'Declaración de la Renta (730)',
        ],
        'residence_permit' => [
            'it' => 'Permesso di Soggiorno',
            'en' => 'Residence Permit',
            'es' => 'Permiso de Residencia',
        ],
        'citizenship' => [
            'it' => 'Cittadinanza',
            'en' => 'Citizenship',
            'es' => 'Ciudadanía',
        ],
        'tourist_visa' => [
            'it' => 'Visto Turistico',
            'en' => 'Tourist Visa',
            'es' => 'Visa Turística',
        ],
        'asylum_request' => [
            'it' => 'Richiesta Asilo',
            'en' => 'Asylum Request',
            'es' => 'Solicitud de Asilo',
        ],
        'income_tax_return' => [
            'it' => 'Dichiarazione Redditi',
            'en' => 'Income Tax Return',
            'es' => 'Declaración de Renta',
        ],
        'vat_number_opening' => [
            'it' => 'Apertura Partita IVA',
            'en' => 'VAT Number Opening',
            'es' => 'Apertura de Partita IVA',
        ],
        'accounting_management' => [
            'it' => 'Gestione Contabilità',
            'en' => 'Accounting Management',
            'es' => 'Gestión de Contabilidad',
        ],
        'tax_compliance' => [
            'it' => 'Adempimenti Fiscali',
            'en' => 'Tax Compliance',
            'es' => 'Cumplimientos Fiscales',
        ],
        'tax_consultation' => [
            'it' => 'Consulenza Fiscale',
            'en' => 'Tax Consultation',
            'es' => 'Consultoría Fiscal',
        ],
        'tax_debt_management' => [
            'it' => 'Gestione Debiti Fiscali',
            'en' => 'Tax Debt Management',
            'es' => 'Gestión de Deudas Fiscales',
        ],
        'form_compilation' => [
            'it' => 'Compilazione Modelli',
            'en' => 'Form Compilation',
            'es' => 'Compilación de Formularios',
        ],
    ];
    
    return $names[$category_key][$lang] ?? $category_key;
}

// Uso
$richieste = get_richieste_servizi();
foreach ($richieste as $richiesta) {
    echo get_service_display_name($richiesta->servizio, 'it');
    echo ' - ';
    echo get_category_display_name($richiesta->categoria, 'it');
}
```

### Esempio Output Dashboard

```
📊 Statistiche Richieste Servizi

Sportello Immigrazione: 45 richieste
  ├─ Permesso di Soggiorno: 28
  ├─ Cittadinanza: 12
  ├─ Visto Turistico: 3
  └─ Richiesta Asilo: 2

CAF - Assistenza Fiscale: 32 richieste
  ├─ Dichiarazione dei Redditi (730): 25
  └─ Compilazione Modelli: 7

Supporto Contabile: 18 richieste
  ├─ Dichiarazione Redditi: 8
  ├─ Apertura Partita IVA: 5
  ├─ Gestione Contabilità: 3
  └─ Consulenza Fiscale: 2

Mediazione Fiscale: 7 richieste
  └─ Gestione Debiti Fiscali: 7
```

---

## 🔄 Migrazione Dati Esistenti

Se hai già richieste nel database con nomi tradotti, esegui questo script:

```sql
-- Aggiorna servizi
UPDATE wp_wecoop_richieste_servizi 
SET servizio = 'immigration_desk'
WHERE servizio IN ('Sportello Immigrazione', 'Immigration Desk', 'Oficina de Inmigración');

UPDATE wp_wecoop_richieste_servizi 
SET servizio = 'caf_tax_assistance'
WHERE servizio IN ('CAF - Assistenza Fiscale', 'CAF - Tax Assistance', 'CAF - Asistencia Fiscal');

UPDATE wp_wecoop_richieste_servizi 
SET servizio = 'accounting_support'
WHERE servizio IN ('Supporto Contabile', 'Accounting Support', 'Soporte Contable');

UPDATE wp_wecoop_richieste_servizi 
SET servizio = 'tax_mediation'
WHERE servizio IN ('Mediazione Fiscale', 'Tax Mediation', 'Mediación Fiscal');

-- Aggiorna categorie
UPDATE wp_wecoop_richieste_servizi 
SET categoria = 'residence_permit'
WHERE categoria IN ('Permesso di Soggiorno', 'Residence Permit', 'Permiso de Residencia');

UPDATE wp_wecoop_richieste_servizi 
SET categoria = 'citizenship'
WHERE categoria IN ('Cittadinanza', 'Citizenship', 'Ciudadanía');

UPDATE wp_wecoop_richieste_servizi 
SET categoria = 'tourist_visa'
WHERE categoria IN ('Visto Turistico', 'Tourist Visa', 'Visa Turística');

UPDATE wp_wecoop_richieste_servizi 
SET categoria = 'asylum_request'
WHERE categoria IN ('Richiesta Asilo', 'Asylum Request', 'Solicitud de Asilo');

UPDATE wp_wecoop_richieste_servizi 
SET categoria = 'tax_return_730'
WHERE categoria IN ('Dichiarazione dei Redditi (730)', 'Tax Return (730)', 'Declaración de la Renta (730)');

UPDATE wp_wecoop_richieste_servizi 
SET categoria = 'form_compilation'
WHERE categoria IN ('Compilazione Modelli', 'Form Compilation', 'Compilación de Formularios');

UPDATE wp_wecoop_richieste_servizi 
SET categoria = 'income_tax_return'
WHERE categoria IN ('Dichiarazione Redditi', 'Income Tax Return', 'Declaración de Renta');

UPDATE wp_wecoop_richieste_servizi 
SET categoria = 'vat_number_opening'
WHERE categoria IN ('Apertura Partita IVA', 'VAT Number Opening', 'Apertura de Partita IVA');

UPDATE wp_wecoop_richieste_servizi 
SET categoria = 'accounting_management'
WHERE categoria IN ('Gestione Contabilità', 'Accounting Management', 'Gestión de Contabilidad');

UPDATE wp_wecoop_richieste_servizi 
SET categoria = 'tax_compliance'
WHERE categoria IN ('Adempimenti Fiscali', 'Tax Compliance', 'Cumplimientos Fiscales');

UPDATE wp_wecoop_richieste_servizi 
SET categoria = 'tax_consultation'
WHERE categoria IN ('Consulenza Fiscale', 'Tax Consultation', 'Consultoría Fiscal');

UPDATE wp_wecoop_richieste_servizi 
SET categoria = 'tax_debt_management'
WHERE categoria IN ('Gestione Debiti Fiscali', 'Tax Debt Management', 'Gestión de Deudas Fiscales');
```

---

## ✅ Vantaggi

1. **Nessuna duplicazione** - Tutte le richieste dello stesso tipo raggruppate
2. **Query semplificate** - Filtraggio e statistiche più facili
3. **Scalabilità** - Facile aggiungere nuove lingue senza modificare il database
4. **Consistenza** - Database pulito e organizzato
5. **Retrocompatibilità** - Script di migrazione per dati esistenti

---

**Data aggiornamento**: 26 Dicembre 2025  
**Versione App**: 1.0.0+  
**Compatibilità**: Tutte le versioni future
