# Supabase Row Level Security (RLS) Audit Report

**Application:** Tarnas Kids (Children's Educational App)
**Audit Date:** 2026-02-05
**Auditor:** Security Reviewer Agent (Claude Opus 4.6)
**Compliance Scope:** COPPA, GDPR (children's data)

---

## Executive Summary

This audit examines the Supabase Row Level Security configuration for the Tarnas Kids
application -- a children's educational app that stores gameplay data, pet state, and
analytics events in Supabase. The application uses **anonymous authentication** (no email
or password), meaning each device installation receives a unique anonymous user ID via
`supabase.auth.signInAnonymously()`.

**Overall Risk Level: HIGH**

- 3 tables identified in active use (`inventory`, `pet_states`, `analytics_events`)
- 1 additional table referenced in PRD but NOT found in code (`daily_logins`)
- Only 1 of 3 active tables has documented RLS policies (`pet_states`)
- NO SQL schema or RLS policies found for `inventory` or `analytics_events`
- Hardcoded PostHog API key found in source code (MEDIUM severity)
- Supabase anon key properly gitignored but currently hardcoded in committed example output
- Race condition identified in `addEvolutionPoints` (LOW severity for this app context)

### Issue Summary

| Severity | Count | Description |
|----------|-------|-------------|
| CRITICAL | 2 | Missing RLS policies for `inventory` and `analytics_events` tables |
| HIGH | 1 | No SQL migration files for `inventory` or `analytics_events` (cannot verify RLS is applied) |
| HIGH | 1 | PostHog API key hardcoded in `main.dart` (committed to git) |
| MEDIUM | 1 | `inventory` table schema in example file is missing `user_id` column |
| MEDIUM | 1 | Race condition in `addEvolutionPoints` (read-modify-write without locking) |
| LOW | 1 | `daily_logins` table referenced in PRD but not implemented |
| LOW | 1 | Supabase anon key in `supabase_config.dart` is gitignored (good) but the example reveals project ref |

---

## 1. Table Inventory

### Table: `inventory`

| Property | Details |
|----------|---------|
| **Purpose** | Stores rewards/treats earned by children (cookies, candy, ice cream, chocolate) |
| **Data Stored** | `user_id`, `item_type`, `reward_id`, `reward_name`, `created_at` |
| **Operations** | INSERT (addReward), SELECT (getInventory, countRewards, getInventoryCounts, getInventoryStream), DELETE (consumeItem) |
| **Access Model** | Each user should only access their own inventory items |
| **SQL Schema Found** | PARTIAL -- only in example file, MISSING `user_id` column in schema definition |
| **RLS Policies Found** | **NONE** |
| **Risk** | **CRITICAL** |

**Client-side queries observed:**
- `database_service.dart:90` -- INSERT with explicit `user_id`
- `database_service.dart:119-121` -- SELECT with `.eq('user_id', userId)`
- `database_service.dart:140-142` -- SELECT with `.eq('user_id', userId).eq('reward_id', ...)`
- `database_service.dart:163-164` -- SELECT with `.eq('user_id', userId)`
- `database_service.dart:206-208` -- STREAM with `.eq('user_id', userId)`
- `database_service.dart:252-256` -- SELECT with `.eq('user_id', userId).eq('reward_id', ...)`
- `database_service.dart:274-277` -- DELETE with `.eq('id', itemId).eq('user_id', userId)`

**Positive finding:** All queries in `database_service.dart` include `user_id` filtering.
However, without server-side RLS enforcement, a malicious client can bypass these filters
by crafting direct API requests to the Supabase REST endpoint using the anon key.

**Schema issue:** The example file at `lib/config/supabase_config.dart.example` defines:
```sql
CREATE TABLE inventory (
  id BIGSERIAL PRIMARY KEY,
  item_type TEXT NOT NULL,
  reward_id TEXT NOT NULL,
  reward_name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```
This schema is **missing the `user_id` column**. The actual deployed table must have it
(since the code successfully writes `user_id`), but the documented schema is incomplete
and, critically, contains **no RLS policies**.

---

### Table: `pet_states`

| Property | Details |
|----------|---------|
| **Purpose** | Stores virtual pet state per user (hunger, happiness, energy, hygiene, evolution, sleep) |
| **Data Stored** | `user_id`, `hunger`, `happiness`, `energy`, `hygiene`, `sleep_start_time`, `evolution_points`, `updated_at`, `created_at` |
| **Operations** | SELECT (getPetState, getSleepStartTime, getEvolutionPoints), UPSERT (savePetState, addEvolutionPoints, resetEvolutionPoints, startSleep), UPDATE (wakeUpAndCalculateEnergy) |
| **Access Model** | Each user has exactly one row (UNIQUE constraint on `user_id`) |
| **SQL Schema Found** | YES -- `supabase_pet_states.sql` |
| **RLS Policies Found** | **YES -- all 4 operations covered** |
| **Risk** | **LOW** (properly configured) |

**RLS policies documented in `supabase_pet_states.sql`:**
- SELECT: `auth.uid() = user_id`
- INSERT: `auth.uid() = user_id` (WITH CHECK)
- UPDATE: `auth.uid() = user_id` (USING + WITH CHECK)
- DELETE: `auth.uid() = user_id`

**IMPORTANT CAVEAT:** These policies exist in the SQL file, but there is no automated
migration system. It is impossible to confirm from the code alone that these policies
were actually applied to the production Supabase instance. This must be verified manually
in the Supabase Dashboard.

---

### Table: `analytics_events`

| Property | Details |
|----------|---------|
| **Purpose** | Stores analytics events (game starts, completions, rewards, pet interactions, screen views) |
| **Data Stored** | `user_id`, `event_name`, `parameters` (JSON), `created_at`, `platform` |
| **Operations** | INSERT (from analytics_service.dart), SELECT (from parent_panel_screen.dart) |
| **Access Model** | Users should only INSERT their own events and SELECT their own events |
| **SQL Schema Found** | **NONE** |
| **RLS Policies Found** | **NONE** |
| **Risk** | **CRITICAL** |

**Client-side queries observed:**
- `analytics_service.dart:260-266` -- INSERT with `user_id` from `_userId` field
- `parent_panel_screen.dart:42-46` -- SELECT with `.eq('user_id', userId).eq('event_name', 'game_start')`
- `parent_panel_screen.dart:48-52` -- SELECT with `.eq('user_id', userId).eq('event_name', 'reward_earned')`

**Positive finding:** All queries filter by `user_id`.

**Concern:** Without RLS, any authenticated user (even anonymous) could query ALL
analytics events from ALL users by making direct REST API calls. This could expose:
- Which games each child plays
- How often they play
- What rewards they earn
- Platform/device information

While individual records do not contain PII (no names, emails), the `user_id` field
combined with analytics data constitutes behavioral profiling of children, which is
regulated under both COPPA and GDPR.

---

### Table: `daily_logins` (NOT IMPLEMENTED)

| Property | Details |
|----------|---------|
| **Purpose** | Referenced in PRD (`tasks/prd-production-release.md` line 143) but not found in any Dart code |
| **Status** | Not yet implemented |
| **Risk** | LOW (does not exist yet) |
| **Action** | When implemented, RLS must be added from day one |

---

## 2. Security Analysis

### 2.1 Authentication Model

The app uses **Supabase Anonymous Authentication** (`signInAnonymously()`). This means:
- Every device installation gets a unique UUID
- No email, password, or personal identifiers are collected (COPPA-positive)
- The anon key is used with an authenticated session (JWT contains the anonymous user ID)
- `auth.uid()` in RLS policies correctly maps to the anonymous user's UUID

**Assessment:** The authentication model is appropriate for a children's app. Anonymous
auth minimizes data collection while still enabling per-user data isolation. However,
this model depends entirely on RLS to prevent cross-user data access, since the anon key
is embedded in the client app and can be extracted.

### 2.2 Can User A Access User B's Data?

**Without RLS (CURRENT STATE for `inventory` and `analytics_events`):**

YES. An attacker who extracts the Supabase URL and anon key from the app (trivial with
APK decompilation) can:

1. Create an anonymous session
2. Call the Supabase REST API directly:
   ```
   GET https://efnxsjneewsqhxcglelz.supabase.co/rest/v1/inventory?select=*
   Authorization: Bearer <jwt_token>
   apikey: <anon_key>
   ```
3. Retrieve ALL rows from `inventory` and `analytics_events` for ALL users

**With RLS properly applied (as it is for `pet_states`):**

NO. The RLS policy `auth.uid() = user_id` ensures that even direct API calls can only
return rows belonging to the authenticated user.

### 2.3 Write Operation Scoping

All write operations in `database_service.dart` explicitly set `user_id` to
`currentUserId`. However, without RLS WITH CHECK constraints:

- A malicious client could INSERT rows with a **different** `user_id`, polluting another
  user's inventory
- A malicious client could DELETE rows belonging to other users from `inventory`

### 2.4 The `addEvolutionPoints` Race Condition

In `database_service.dart:361-389`, `addEvolutionPoints` performs:
1. READ current points (`getPetState()`)
2. Calculate new points in Dart code
3. WRITE new points back (`upsert`)

This is a classic **read-modify-write** race condition. Two concurrent calls could both
read the same value and one update would be lost. In the context of this children's game,
the impact is LOW (a child might lose a few evolution points), but it violates best
practices. The correct approach would be a Supabase RPC function with:
```sql
UPDATE pet_states
SET evolution_points = evolution_points + $points
WHERE user_id = auth.uid()
RETURNING evolution_points;
```

### 2.5 Hardcoded Secrets

**CRITICAL: Supabase credentials in `supabase_config.dart`**
- The actual config file IS gitignored (line 65 of `.gitignore`): GOOD
- The example file reveals the project reference (`efnxsjneewsqhxcglelz`): LOW risk
  since this is derivable from the compiled app anyway
- The anon key is a PUBLIC key by Supabase design, meant to be in the client. This is
  acceptable IF AND ONLY IF RLS is properly configured on all tables.

**HIGH: PostHog API key hardcoded in `main.dart:77`**
```dart
final config = PostHogConfig('phc_BL81wy8lEm6vrX1OVV2Y7oINDk99N1wubbhsLEVA3pg');
```
This key is committed to the repository. While PostHog public keys are designed to be
client-side, it should still be moved to a configuration file that can be rotated without
a code change. Additionally, if this repository is public or shared, the key is exposed.

### 2.6 Realtime Stream Security

`database_service.dart:205-208` uses Supabase Realtime:
```dart
_client.from('inventory').stream(primaryKey: ['id']).eq('user_id', userId);
```
Supabase Realtime respects RLS policies. Without RLS on `inventory`, the `.eq()` filter
is client-side only, and the Realtime subscription could potentially leak data from other
users depending on the Supabase Realtime configuration.

---

## 3. COPPA/GDPR Compliance Notes

### Data Minimization (GDPR Art. 5(1)(c), COPPA)

| Check | Status | Notes |
|-------|--------|-------|
| No PII collected | PASS | Anonymous auth, no names/emails |
| Minimal data stored | PASS | Only game state and analytics |
| No behavioral profiling | WARN | `analytics_events` tracks game usage patterns per user |
| No third-party data sharing | WARN | PostHog receives event data with session replay |

### Data Protection (GDPR Art. 32)

| Check | Status | Notes |
|-------|--------|-------|
| Encryption in transit | PASS | Supabase uses HTTPS |
| Encryption at rest | PASS | Supabase encrypts at rest by default |
| Access control (RLS) | **FAIL** | 2 of 3 tables lack RLS |
| Data isolation | **FAIL** | Without RLS, cross-user access is possible |

### Right to Erasure (GDPR Art. 17)

| Check | Status | Notes |
|-------|--------|-------|
| `pet_states` CASCADE delete | PASS | `ON DELETE CASCADE` from `auth.users` |
| `inventory` CASCADE delete | **UNKNOWN** | No schema file found to verify FK constraint |
| `analytics_events` CASCADE delete | **UNKNOWN** | No schema file found |

### PostHog Session Replay

The app enables PostHog session recording with `config.sessionReplay = true` and
`config.sessionReplayConfig.maskAllTexts = true`. While text masking is enabled:

- Session recordings of children's interactions are being sent to PostHog servers
- This may constitute processing of children's personal data under GDPR
- COPPA requires verifiable parental consent before collecting data from children under 13
- The app has no parental consent gate before PostHog begins recording

---

## 4. Recommended RLS Policies (SQL)

### 4.1 Table: `inventory`

```sql
-- ============================================
-- INVENTORY TABLE - Full schema with RLS
-- ============================================

-- Corrected schema (with user_id and proper FK)
CREATE TABLE IF NOT EXISTS inventory (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    item_type TEXT NOT NULL,
    reward_id TEXT NOT NULL,
    reward_name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for user_id lookups
CREATE INDEX IF NOT EXISTS idx_inventory_user_id ON inventory(user_id);

-- Enable RLS
ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only read their own inventory
CREATE POLICY "Users can view own inventory"
    ON inventory FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: Users can only insert items for themselves
CREATE POLICY "Users can insert own inventory items"
    ON inventory FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can only update their own items
CREATE POLICY "Users can update own inventory items"
    ON inventory FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can only delete their own items
CREATE POLICY "Users can delete own inventory items"
    ON inventory FOR DELETE
    USING (auth.uid() = user_id);
```

### 4.2 Table: `analytics_events`

```sql
-- ============================================
-- ANALYTICS_EVENTS TABLE - Full schema with RLS
-- ============================================

CREATE TABLE IF NOT EXISTS analytics_events (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    event_name TEXT NOT NULL,
    parameters JSONB DEFAULT '{}',
    platform TEXT DEFAULT 'unknown',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for user_id + event_name lookups (used by parent panel)
CREATE INDEX IF NOT EXISTS idx_analytics_events_user_id ON analytics_events(user_id);
CREATE INDEX IF NOT EXISTS idx_analytics_events_user_event
    ON analytics_events(user_id, event_name);

-- Enable RLS
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only read their own analytics
CREATE POLICY "Users can view own analytics"
    ON analytics_events FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: Users can only insert their own analytics events
CREATE POLICY "Users can insert own analytics"
    ON analytics_events FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- NO UPDATE policy - analytics events should be immutable
-- NO DELETE policy - analytics events should not be deleted by users
-- (Admin can use service_role key for data management)
```

### 4.3 Table: `pet_states` (ALREADY HAS RLS -- verify in production)

The SQL in `supabase_pet_states.sql` is correct. Verify it is applied by running in the
Supabase SQL Editor:

```sql
-- Verify RLS is enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('inventory', 'pet_states', 'analytics_events');

-- Verify policies exist
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE schemaname = 'public'
AND tablename IN ('inventory', 'pet_states', 'analytics_events');
```

### 4.4 Future Table: `daily_logins` (when implemented)

```sql
-- ============================================
-- DAILY_LOGINS TABLE - Schema with RLS
-- ============================================

CREATE TABLE IF NOT EXISTS daily_logins (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    login_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, login_date)  -- One entry per user per day
);

CREATE INDEX IF NOT EXISTS idx_daily_logins_user_id ON daily_logins(user_id);

ALTER TABLE daily_logins ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own logins"
    ON daily_logins FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own logins"
    ON daily_logins FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- No UPDATE or DELETE needed for login records
```

### 4.5 Atomic Evolution Points RPC (recommended)

```sql
-- Replace read-modify-write with atomic operation
CREATE OR REPLACE FUNCTION add_evolution_points(points_to_add INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    new_points INTEGER;
BEGIN
    UPDATE pet_states
    SET evolution_points = evolution_points + points_to_add,
        updated_at = NOW()
    WHERE user_id = auth.uid()
    RETURNING evolution_points INTO new_points;

    -- If no row exists, create one
    IF NOT FOUND THEN
        INSERT INTO pet_states (user_id, evolution_points, updated_at)
        VALUES (auth.uid(), points_to_add, NOW())
        RETURNING evolution_points INTO new_points;
    END IF;

    RETURN new_points;
END;
$$;
```

---

## 5. Action Items

### CRITICAL (Fix Before Production)

| # | Action | File/Location | Details |
|---|--------|---------------|---------|
| 1 | **Apply RLS to `inventory` table** | Supabase Dashboard SQL Editor | Use SQL from Section 4.1 |
| 2 | **Apply RLS to `analytics_events` table** | Supabase Dashboard SQL Editor | Use SQL from Section 4.2 |
| 3 | **Verify `inventory` has `user_id` FK to `auth.users` with ON DELETE CASCADE** | Supabase Dashboard | If missing, add: `ALTER TABLE inventory ADD CONSTRAINT fk_inventory_user FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;` |
| 4 | **Verify `analytics_events` has `user_id` FK with ON DELETE CASCADE** | Supabase Dashboard | Same as above for analytics |
| 5 | **Verify `pet_states` RLS is actually enabled in production** | Supabase Dashboard | Run verification query from Section 4.3 |

### HIGH (Fix Before Production)

| # | Action | File/Location | Details |
|---|--------|---------------|---------|
| 6 | **Create SQL migration files for ALL tables** | `C:\tarnas_kids\supabase\` | Store schema + RLS for `inventory`, `analytics_events`, `pet_states`, and future tables in version control |
| 7 | **Move PostHog API key to config** | `C:\tarnas_kids\lib\main.dart:77` | Move `phc_BL81wy8lEm6vrX1OVV2Y7oINDk99N1wubbhsLEVA3pg` to a config file that is gitignored, or use `--dart-define` |
| 8 | **Fix `inventory` example schema** | `C:\tarnas_kids\lib\config\supabase_config.dart.example` | Add `user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE` column to the documented schema |
| 9 | **Test cross-user data isolation** | Manual test | Create two anonymous sessions, verify user A cannot see user B's data via direct API calls |

### MEDIUM (Fix When Possible)

| # | Action | File/Location | Details |
|---|--------|---------------|---------|
| 10 | **Replace `addEvolutionPoints` with RPC** | `C:\tarnas_kids\lib\services\database_service.dart:361-389` | Use atomic `add_evolution_points` RPC function (Section 4.5) to prevent race condition |
| 11 | **Evaluate PostHog session replay compliance** | `C:\tarnas_kids\lib\main.dart:84` | Assess whether session replay of children's interactions requires parental consent under COPPA/GDPR. Consider disabling for children under 13 or adding a consent gate. |
| 12 | **Add `analytics_events` immutability** | Supabase Dashboard | No UPDATE or DELETE policies for analytics (events should be append-only) |
| 13 | **Restrict `analytics_events` SELECT to parent panel** | Consider architecture | Analytics reads currently happen from client code in `parent_panel_screen.dart`. Consider a Supabase Edge Function or RPC to aggregate stats server-side, reducing exposed data surface. |

### LOW (Consider Fixing)

| # | Action | File/Location | Details |
|---|--------|---------------|---------|
| 14 | **Implement `daily_logins` with RLS from day one** | When US for daily logins is picked up | Use SQL from Section 4.4 |
| 15 | **Add Supabase project ref to gitignore note** | `C:\tarnas_kids\.gitignore` | The project ref `efnxsjneewsqhxcglelz` is exposed in the example file; while low risk, consider removing it |

---

## 6. Security Checklist

- [ ] **No hardcoded secrets** -- FAIL: PostHog key in `main.dart`; Supabase anon key properly gitignored
- [x] **All inputs validated** -- Client-side user_id always sourced from `auth.currentUser.id`
- [x] **SQL injection prevention** -- Using Supabase client SDK (parameterized queries)
- [x] **XSS prevention** -- Flutter app (not web-rendered HTML)
- [x] **Authentication required** -- Anonymous auth ensures every user has a session
- [ ] **Authorization verified (RLS)** -- FAIL: 2 of 3 tables lack RLS
- [x] **HTTPS enforced** -- Supabase uses HTTPS by default
- [ ] **All tables have RLS** -- FAIL: `inventory` and `analytics_events` unconfirmed
- [ ] **CASCADE delete for GDPR erasure** -- UNKNOWN: Cannot verify for `inventory` and `analytics_events`
- [x] **No PII in database** -- Only anonymous UUIDs and game data
- [ ] **Session replay consent** -- WARN: PostHog session replay may need consent gate
- [x] **Error messages do not leak data** -- Errors are caught and logged to Crashlytics, not shown to users

---

## 7. Verification Steps

After applying the RLS policies, verify with these tests:

### Test 1: Verify RLS is Enabled

Run in Supabase SQL Editor:
```sql
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('inventory', 'pet_states', 'analytics_events');
```
Expected: All three should show `rowsecurity = true`.

### Test 2: Verify Policies Exist

```sql
SELECT tablename, policyname, cmd
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, cmd;
```
Expected: At least SELECT, INSERT, UPDATE, DELETE policies for `inventory` and
`pet_states`; SELECT and INSERT for `analytics_events`.

### Test 3: Cross-User Isolation (manual)

1. Open two terminals/Postman sessions
2. Sign in anonymously with the anon key to get two different JWTs
3. With User A's JWT, insert a row into `inventory`
4. With User B's JWT, attempt `SELECT * FROM inventory`
5. Expected: User B sees 0 rows (only their own, which is empty)

### Test 4: Unauthorized INSERT Prevention

1. With User A's JWT, attempt to INSERT into `inventory` with `user_id` set to User B's UUID
2. Expected: RLS WITH CHECK rejects the insert (user_id must match auth.uid())

---

*This audit covers the codebase as of 2026-02-05. RLS policies must be verified against
the live Supabase Dashboard, as there is no automated migration system to guarantee the
SQL files in the repository match the production database configuration.*
