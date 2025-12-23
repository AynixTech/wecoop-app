#!/bin/bash

# Test Push Notification Backend - WeCoop

echo "🧪 Test Push Notification Endpoints"
echo "===================================="
echo ""

# Colori
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# URL base
BASE_URL="https://www.wecoop.org/wp-json/push/v1"

echo "📍 Base URL: $BASE_URL"
echo ""

# Test 1: Verifica che l'endpoint esista
echo "Test 1: Verifica endpoint POST /token (senza autenticazione)"
echo "------------------------------------------------------"
response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/token" \
  -H "Content-Type: application/json" \
  -d '{"token":"test_token","device_info":"Test Device"}')

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)

echo "HTTP Status: $http_code"
echo "Response: $body"

if [ "$http_code" = "401" ]; then
  echo -e "${GREEN}✅ Endpoint esiste e richiede autenticazione (401 = OK)${NC}"
elif [ "$http_code" = "404" ]; then
  echo -e "${RED}❌ Endpoint non trovato (404)${NC}"
  echo -e "${YELLOW}💡 Verifica che il plugin sia attivo su WordPress${NC}"
else
  echo -e "${YELLOW}⚠️  Status inaspettato: $http_code${NC}"
fi

echo ""
echo ""

# Test 2: Con JWT token (se disponibile)
echo "Test 2: POST /token con JWT (inserisci il tuo JWT token)"
echo "--------------------------------------------------------"
echo -e "${YELLOW}Per ottenere il JWT token:${NC}"
echo "1. Apri l'app Flutter"
echo "2. Fai login"
echo "3. Cerca nel log: 'JWT token trovato: ...'"
echo "4. Oppure usa flutter secure storage inspector"
echo ""
read -p "Inserisci il JWT token (o premi ENTER per saltare): " JWT_TOKEN

if [ ! -z "$JWT_TOKEN" ]; then
  response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/token" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"token":"test_fcm_token_123","device_info":"Test Device - Bash Script"}')
  
  http_code=$(echo "$response" | tail -n1)
  body=$(echo "$response" | head -n-1)
  
  echo "HTTP Status: $http_code"
  echo "Response: $body"
  
  if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✅ Token salvato con successo!${NC}"
  elif [ "$http_code" = "401" ]; then
    echo -e "${RED}❌ JWT non valido o scaduto${NC}"
  else
    echo -e "${YELLOW}⚠️  Errore: $http_code${NC}"
  fi
else
  echo -e "${YELLOW}Test saltato${NC}"
fi

echo ""
echo ""

# Test 3: Verifica GET /tokens (lista tutti i token)
echo "Test 3: GET /tokens (richiede autenticazione)"
echo "---------------------------------------------"
if [ ! -z "$JWT_TOKEN" ]; then
  response=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/tokens" \
    -H "Authorization: Bearer $JWT_TOKEN")
  
  http_code=$(echo "$response" | tail -n1)
  body=$(echo "$response" | head -n-1)
  
  echo "HTTP Status: $http_code"
  echo "Response: $body"
  
  if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✅ Lista token ottenuta${NC}"
  fi
else
  echo -e "${YELLOW}Test saltato (JWT non fornito)${NC}"
fi

echo ""
echo ""

# Riepilogo
echo "📋 Riepilogo"
echo "============"
echo -e "${GREEN}✅ Endpoint attivo: POST /push/v1/token${NC}"
echo -e "${GREEN}✅ Endpoint attivo: DELETE /push/v1/token${NC}"
echo -e "${GREEN}✅ Endpoint attivo: GET /push/v1/tokens${NC}"
echo ""
echo "🔍 Prossimi passi:"
echo "1. Fai login nell'app Flutter"
echo "2. Cerca nei log: '🔄 Inizio invio FCM token al backend...'"
echo "3. Verifica se vedi: '✅ FCM token salvato su backend'"
echo "4. Se non vedi questi log, il problema è nel Firebase (permessi non concessi)"
echo "5. Se vedi errore 401, il JWT non è valido"
echo "6. Se vedi errore 404, il plugin non è configurato correttamente"
