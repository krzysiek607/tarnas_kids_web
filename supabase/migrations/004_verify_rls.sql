-- ============================================
-- WERYFIKACJA RLS - uruchom po zastosowaniu migracji
-- ============================================

-- 1. Sprawdź czy RLS jest włączony na wszystkich tabelach
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('inventory', 'pet_states', 'analytics_events');
-- Oczekiwany wynik: wszystkie 3 = true

-- 2. Sprawdź polityki RLS
SELECT tablename, policyname, cmd
FROM pg_policies
WHERE schemaname = 'public'
AND tablename IN ('inventory', 'pet_states', 'analytics_events')
ORDER BY tablename, cmd;
-- Oczekiwany wynik:
--   inventory:        SELECT, INSERT, UPDATE, DELETE
--   pet_states:       SELECT, INSERT, UPDATE, DELETE
--   analytics_events: SELECT, INSERT

-- 3. Sprawdź FK do auth.users (ON DELETE CASCADE)
SELECT
    tc.table_name,
    tc.constraint_name,
    rc.delete_rule
FROM information_schema.table_constraints tc
JOIN information_schema.referential_constraints rc
    ON tc.constraint_name = rc.constraint_name
WHERE tc.table_schema = 'public'
AND tc.constraint_type = 'FOREIGN KEY'
AND tc.table_name IN ('inventory', 'pet_states', 'analytics_events');
-- Oczekiwany wynik: wszystkie z delete_rule = CASCADE
