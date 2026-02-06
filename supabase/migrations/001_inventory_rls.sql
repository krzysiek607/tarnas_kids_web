-- ============================================
-- INVENTORY TABLE - Schema + RLS
-- ============================================
-- KRYTYCZNE: Ta tabela przechowuje nagrody dzieci.
-- Bez RLS każdy użytkownik może odczytać/usunąć nagrody innych użytkowników.

-- Poprawiony schemat (z user_id i FK do auth.users)
CREATE TABLE IF NOT EXISTS inventory (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    item_type TEXT NOT NULL,
    reward_id TEXT NOT NULL,
    reward_name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indeks dla szybkiego wyszukiwania po user_id
CREATE INDEX IF NOT EXISTS idx_inventory_user_id ON inventory(user_id);

-- Włącz RLS
ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;

-- Polityka: Użytkownicy widzą tylko swój ekwipunek
CREATE POLICY "Users can view own inventory"
    ON inventory FOR SELECT
    USING (auth.uid() = user_id);

-- Polityka: Użytkownicy dodają tylko do swojego ekwipunku
CREATE POLICY "Users can insert own inventory items"
    ON inventory FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Polityka: Użytkownicy aktualizują tylko swoje przedmioty
CREATE POLICY "Users can update own inventory items"
    ON inventory FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Polityka: Użytkownicy usuwają tylko swoje przedmioty
CREATE POLICY "Users can delete own inventory items"
    ON inventory FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- JEŚLI TABELA JUŻ ISTNIEJE (migracja):
-- ============================================
-- Uruchom poniższe zapytania osobno, jeśli tabela inventory
-- już istnieje ale nie ma RLS ani FK:
--
-- 1. Dodaj user_id FK (jeśli brak):
-- ALTER TABLE inventory
--   ADD CONSTRAINT fk_inventory_user
--   FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
--
-- 2. Włącz RLS:
-- ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;
--
-- 3. Dodaj polityki (skopiuj CREATE POLICY z góry)
