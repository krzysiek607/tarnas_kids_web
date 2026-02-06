# MCP Servers - Konfiguracja

## 📍 Lokalizacja pliku konfiguracyjnego

**Windows:**
```
%APPDATA%\claude\config.json
C:\Users\krzys\AppData\Roaming\claude\config.json
```

---

## 🔧 Kompletna konfiguracja (skopiuj do config.json)

```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server"],
      "env": {
        "SUPABASE_URL": "https://twoj-projekt.supabase.co",
        "SUPABASE_SERVICE_ROLE_KEY": "twoj-service-role-key"
      }
    },
    "context7": {
      "command": "context7-mcp-server",
      "args": [],
      "env": {
        "CONTEXT7_API_KEY": "twoj-context7-api-key"
      }
    },
    "sequential-thinking": {
      "command": "mcp-sequential-thinking",
      "args": ["--max-steps", "10"]
    }
  },
  "autoUpdate": true
}
```

---

## 🚀 Instalacja (wykonaj w terminalu)

### 1. Context7
```bash
npm install -g @context7/mcp-server
```
- Zarejestruj się: https://context7.com
- Dashboard → API Keys → wygeneruj klucz

### 2. Sequential Thinking
```bash
npm install -g @anthropic/mcp-sequential-thinking
```

### 3. Supabase (opcjonalnie - jeśli używasz backend)
```bash
# Instalacja nie jest potrzebna (używa npx)
# Tylko ustaw URL i KEY gdy będziesz mieć projekt Supabase
```

---

## ✅ Weryfikacja

W Claude Code uruchom:
```
/mcp list
```

Powinieneś zobaczyć:
```
✓ context7 - Connected
✓ sequential-thinking - Connected
✓ supabase - Connected (jeśli skonfigurowałeś)
```

---

## 🔒 Bezpieczeństwo

**WAŻNE:**
1. NIGDY nie commituj config.json do Git
2. Dodaj do .gitignore:
   ```
   # Claude Code
   .claude/
   **/config.json
   ```

---

## 📝 Co dają poszczególne serwery?

### Context7
- Automatycznie pobiera dokumentację pakietów (Flutter, Riverpod, go_router)
- Zawsze aktualna dokumentacja z pub.dev
- **Użycie:** Pytaj o pakiety, Claude automatycznie sięgnie po docs

### Sequential Thinking
- Rozwiązuje złożone problemy krok po kroku
- Automatycznie się aktywuje przy refaktoringu
- **Użycie:** "Zrefaktoruj projekt na feature-based architecture"

### Supabase
- Bezpośredni dostęp do bazy danych
- Tworzenie tabel, queries, authentication
- **Użycie:** Gdy dodasz backend do aplikacji

---

## ⚡ Quick Setup (minimalna konfiguracja)

Jeśli nie chcesz instalować wszystkiego teraz, zacznij od:

**config.json (tylko Sequential Thinking):**
```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "mcp-sequential-thinking",
      "args": ["--max-steps", "10"]
    }
  }
}
```

Instalacja:
```bash
npm install -g @anthropic/mcp-sequential-thinking
```

Resztę dodasz później gdy będzie potrzebne.
