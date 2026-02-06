-- ============================================
-- TABELA PET_STATES - stan zwierzaka w Supabase
-- ============================================

-- Utwórz tabelę pet_states
CREATE TABLE IF NOT EXISTS pet_states (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    hunger DOUBLE PRECISION DEFAULT 80.0,
    happiness DOUBLE PRECISION DEFAULT 80.0,
    energy DOUBLE PRECISION DEFAULT 80.0,
    hygiene DOUBLE PRECISION DEFAULT 80.0,
    sleep_start_time TIMESTAMPTZ DEFAULT NULL,  -- NULL = nie śpi, data = śpi od tego czasu
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)  -- Jeden rekord na użytkownika
);

-- Indeks dla szybkiego wyszukiwania po user_id
CREATE INDEX IF NOT EXISTS idx_pet_states_user_id ON pet_states(user_id);

-- RLS (Row Level Security)
ALTER TABLE pet_states ENABLE ROW LEVEL SECURITY;

-- Polityki RLS - użytkownik widzi tylko swój stan
CREATE POLICY "Users can view own pet state"
    ON pet_states FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own pet state"
    ON pet_states FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own pet state"
    ON pet_states FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own pet state"
    ON pet_states FOR DELETE
    USING (auth.uid() = user_id);

-- Trigger do automatycznej aktualizacji updated_at
CREATE OR REPLACE FUNCTION update_pet_states_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_pet_states_updated_at
    BEFORE UPDATE ON pet_states
    FOR EACH ROW
    EXECUTE FUNCTION update_pet_states_updated_at();

-- ============================================
-- KOMENTARZ DO LOGIKI SNU
-- ============================================
--
-- sleep_start_time:
--   - NULL = zwierzak NIE śpi
--   - TIMESTAMPTZ = zwierzak śpi od tego czasu
--
-- Regeneracja energii:
--   - 1 minuta snu = 1 punkt energii
--   - Maksymalnie 100 punktów energii
--
-- Przykład użycia:
--   1. Użytkownik kładzie zwierzaka spać:
--      UPDATE pet_states SET sleep_start_time = NOW() WHERE user_id = ?
--
--   2. Użytkownik budzi zwierzaka:
--      - Pobierz sleep_start_time
--      - Oblicz: minuty = NOW() - sleep_start_time
--      - nowaEnergia = energia + minuty (max 100)
--      - UPDATE pet_states SET sleep_start_time = NULL, energy = nowaEnergia WHERE user_id = ?

-- ============================================
-- MIGRACJA: Dodanie evolution_points
-- ============================================
-- Uruchom to zapytanie w Supabase SQL Editor jeśli tabela już istnieje:

ALTER TABLE pet_states
ADD COLUMN IF NOT EXISTS evolution_points INTEGER DEFAULT 0;

-- ============================================
-- KOMENTARZ DO LOGIKI EWOLUCJI
-- ============================================
--
-- evolution_points:
--   - Punkty ewolucji jajka (0 do 100+)
--   - Zdobywane przez opiekę nad zwierzakiem
--
-- Punktacja:
--   - feed(): +5 pkt
--   - wash(): +3 pkt
--   - play(): +2 pkt
--
-- Fazy ewolucji:
--   - Faza 1 (Jajko):            0 - 30 pkt
--   - Faza 2 (Pierwsze Pęknięcie): 31 - 70 pkt
--   - Faza 3 (Drugie Pęknięcie):  71 - 100 pkt
--   - Faza 4 (Wyklucie):         > 100 pkt
