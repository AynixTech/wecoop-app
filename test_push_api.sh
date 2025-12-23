#!/bin/bash

# 🧪 Test Push Notifications API Endpoints
# Script per testare gli endpoint del backend WordPress

echo "🧪 Test Push Notifications API"
echo "================================"
echo ""

# Configurazione
API_BASE="https://www.wecoop.org/wp-json"
JWT_TOKEN=""  # Inserisci qui il tuo JWT token

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funzione per stampare risultato
print_result() {
    local status=$1
    local message=$2
    
    if [ $status -eq 200 ]; then
        echo -e "${GREEN}✅ SUCCESS${NC} - $message"
    elif [ $status -eq 401 ]; then
        echo -e "${RED}❌ UNAUTHORIZED${NC} - $message"
    elif [ $status -eq 404 ]; then
        echo -e "${RED}❌ NOT FOUND${NC} - $message"
    else
        echo -e "${YELLOW}⚠️  ERROR $status${NC} - $message"
    fi
}

# Test 1: Verifica endpoint esiste (senza auth)
echo "Test 1: Verifica endpoint /push/v1/token esiste"
echo "----------------------------------------------"
response=$(curl -s -w "\n%{http_code}" -X POST "${API_BASE}/push/v1/token" \
  -H "Content-Type: application/json" \
  -d '{"token": "test"}')

status_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

echo "Status Code: $status_code"
echo "Response: $body"
print_result $status_code "Endpoint trovato (dovrebbe essere 401 senza JWT)"
echo ""

# Test 2: Verifica con JWT token (se fornito)
if [ -z "$JWT_TOKEN" ]; then
    echo -e "${YELLOW}⚠️  Test 2 SKIPPED: JWT_TOKEN non configurato${NC}"
    echo "   Per testare con autenticazione:"
    echo "   1. Fai login nell'app"
    echo "   2. Copia il JWT token dai log"
    echo "   3. Modifica questo script e inserisci JWT_TOKEN='...'"
    echo ""
else
    echo "Test 2: POST /push/v1/token con JWT token"
    echo "-------------------------------------------"
    
    FCM_TOKEN="test_fcm_token_$(date +%s)"
    
    response=$(curl -s -w "\n%{http_code}" -X POST "${API_BASE}/push/v1/token" \
      -H "Authorization: Bearer ${JWT_TOKEN}" \
      -H "Content-Type: application/json" \
      -d "{\"token\": \"${FCM_TOKEN}\", \"device_info\": \"Test Script\"}")
    
    status_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    echo "Status Code: $status_code"
    echo "Response: $body"
    print_result $status_code "Salvataggio token"
    echo ""
    
    # Test 3: DELETE token
    echo "Test 3: DELETE /push/v1/token"
    echo "-------------------------------"
    
    response=$(curl -s -w "\n%{http_code}" -X DELETE "${API_BASE}/push/v1/token" \
      -H "Authorization: Bearer ${JWT_TOKEN}")
    
    status_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    echo "Status Code: $status_code"
    echo "Response: $body"
    print_result $status_code "Rimozione token"
    echo ""
fi

# Test 4: Verifica struttura JWT token nell'app
echo "Test 4: Come verificare JWT token nell'app"
echo "--------------------------------------------"
echo "1. Apri l'app Flutter in modalità debug"
echo "2. Fai login"
echo "3. Cerca nei log:"
echo "   - 'Login riuscito. Token ricevuto: eyJ...'"
echo "   - 'JWT Token trovato: eyJ...'"
echo ""
echo "4. Verifica che il token inizi con 'eyJ' (è un JWT valido)"
echo ""
echo "5. Verifica che dopo il login vedi:"
echo "   - '📱 FCM Token: ...'"
echo "   - '🔄 Inizio invio FCM token al backend...'"
echo "   - '✅ JWT token trovato: ...'"
echo "   - '📡 POST https://www.wecoop.org/wp-json/push/v1/token'"
echo ""

# Test 5: Verifica endpoint con curl completo
echo "Test 5: Comando curl completo per test manuale"
echo "------------------------------------------------"
echo ""
echo "# Sostituisci YOUR_JWT_TOKEN e YOUR_FCM_TOKEN:"
echo ""
echo "curl -X POST https://www.wecoop.org/wp-json/push/v1/token \\"
echo "  -H 'Authorization: Bearer YOUR_JWT_TOKEN' \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"token\": \"YOUR_FCM_TOKEN\", \"device_info\": \"Test Device\"}' \\"
echo "  -v"
echo ""

# Test 6: Verifica plugin WordPress
echo "Test 6: Verifica backend WordPress"
echo "------------------------------------"
echo "Sul server WordPress, verifica:"
echo ""
echo "1. Plugin 'WeCoop Push Notifications' attivo?"
echo "   wp plugin list | grep wecoop-push"
echo ""
echo "2. Tabella database creata?"
echo "   mysql -e 'SHOW TABLES LIKE \"wp_wecoop_push_tokens\"' database_name"
echo ""
echo "3. File firebase-credentials.json esiste?"
echo "   ls -la /var/www/html/firebase-credentials.json"
echo ""
echo "4. Composer dependencies installate?"
echo "   ls -la wp-content/plugins/wecoop-push-notifications/vendor/"
echo ""

echo "================================"
echo "🏁 Test completato!"
echo ""
echo "📝 Prossimi passi:"
echo "1. Se vedi 401 → JWT token non valido, rifare login"
echo "2. Se vedi 404 → Endpoint non esiste, attivare plugin"
echo "3. Se vedi 500 → Errore server, controllare log WordPress"
echo ""
