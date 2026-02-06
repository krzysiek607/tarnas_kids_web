-- ============================================
-- RPC: add_evolution_points - atomowa operacja
-- ============================================
-- Rozwiązuje race condition w addEvolutionPoints()
-- (read-modify-write zamieniony na atomowy UPDATE + RETURNING)

CREATE OR REPLACE FUNCTION add_evolution_points(points_to_add INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    new_points INTEGER;
BEGIN
    -- Atomowy UPDATE - brak race condition
    UPDATE pet_states
    SET evolution_points = evolution_points + points_to_add,
        updated_at = NOW()
    WHERE user_id = auth.uid()
    RETURNING evolution_points INTO new_points;

    -- Jeśli brak wiersza - utwórz nowy
    IF NOT FOUND THEN
        INSERT INTO pet_states (user_id, evolution_points, updated_at)
        VALUES (auth.uid(), points_to_add, NOW())
        RETURNING evolution_points INTO new_points;
    END IF;

    RETURN new_points;
END;
$$;
