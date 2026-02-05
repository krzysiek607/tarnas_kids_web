-- ============================================
-- ANALYTICS_EVENTS TABLE - Schema + RLS
-- ============================================
-- KRYTYCZNE: Ta tabela przechowuje dane o aktywności dzieci.
-- Bez RLS każdy użytkownik może odczytać zachowania innych dzieci
-- (naruszenie COPPA/GDPR - profilowanie behawioralne dzieci).

CREATE TABLE IF NOT EXISTS analytics_events (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    event_name TEXT NOT NULL,
    parameters JSONB DEFAULT '{}',
    platform TEXT DEFAULT 'unknown',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indeks dla wyszukiwania po user_id
CREATE INDEX IF NOT EXISTS idx_analytics_events_user_id ON analytics_events(user_id);

-- Indeks złożony dla zapytań panelu rodzica (user_id + event_name)
CREATE INDEX IF NOT EXISTS idx_analytics_events_user_event
    ON analytics_events(user_id, event_name);

-- Włącz RLS
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;

-- Polityka: Użytkownicy widzą tylko swoje eventy (Panel Rodzica)
CREATE POLICY "Users can view own analytics"
    ON analytics_events FOR SELECT
    USING (auth.uid() = user_id);

-- Polityka: Użytkownicy dodają tylko swoje eventy
CREATE POLICY "Users can insert own analytics"
    ON analytics_events FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- BRAK polityki UPDATE - eventy analityczne są niemutowalne (append-only)
-- BRAK polityki DELETE - eventy nie powinny być usuwane przez użytkowników
-- (admin używa service_role key do zarządzania danymi)

-- ============================================
-- JEŚLI TABELA JUŻ ISTNIEJE (migracja):
-- ============================================
-- 1. Dodaj FK (jeśli brak):
-- ALTER TABLE analytics_events
--   ADD CONSTRAINT fk_analytics_user
--   FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
--
-- 2. Włącz RLS:
-- ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;
--
-- 3. Dodaj polityki (skopiuj CREATE POLICY z góry)
