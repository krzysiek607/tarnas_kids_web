# PRD: Produkcyjny Release Tarnas Kids

## Introduction

Tarnas Kids to edukacyjna aplikacja Flutter dla dzieci 3-8 lat zawierajaca gry edukacyjne (literki, sylaby, liczenie, szlaczki, sekwencje), gry rozrywkowe (labirynt, memory, laczenie kropek), wirtualnego zwierzaka (tamagotchi z ewolucja) i system nagrod. Aplikacja jest gotowa funkcjonalnie - ten PRD opisuje wszystko co potrzebne do profesjonalnego release na Google Play i App Store.

**Lokalizacja projektu:** `C:\tarnas_kids`
**Dokumentacja:** `C:\AI`
**Wersja:** 1.0.0+1

## Goals

- Wypuscic Tarnas Kids na Google Play i App Store jako profesjonalna aplikacja
- Spelnic wymagania prawne (COPPA/GDPR) dla aplikacji dzieciecych
- Zapewnic stabilnosc i brak crashy w produkcji
- Przygotowac wszystkie materialy marketingowe (ikona, screenshoty, opisy)
- Zintegrowac animacje Rive dla zwierzaka
- Dodac onboarding flow dla nowych uzytkownikow

---

## Fazy Release

### FAZA 1: Blokery prawne i techniczne (KRYTYCZNE)
Bez tego nie mozna opublikowac aplikacji w sklepach.

### FAZA 2: Jakosc kodu i stabilnosc
Testy, error handling, performance - aplikacja musi byc solidna.

### FAZA 3: Rive + Onboarding (Dopracowanie)
Profesjonalne animacje zwierzaka i flow dla nowych uzytkownikow.

### FAZA 4: Materialy marketingowe i submission
Screenshoty, opisy, ikona, konta deweloperskie, submission.

---

## User Stories

### FAZA 1: Blokery prawne i techniczne

#### US-001: Zmiana Android Application ID
**Opis:** Jako deweloper, musze zmienic Application ID z domyslnego na unikalne ID firmy, bo Google Play odrzuci apke z `com.example`.

**Acceptance Criteria:**
- [ ] Zmienic `applicationId` w `android/app/build.gradle.kts` na docelowe (np. `com.tarnas.kids`)
- [ ] Zaktualizowac package name w `AndroidManifest.xml`
- [ ] Zaktualizowac `namespace` w `build.gradle.kts`
- [ ] Zaktualizowac Kotlin package w `MainActivity.kt`
- [ ] Zaktualizowac iOS Bundle Identifier w Xcode
- [ ] Zweryfikowac ze Firebase config matchuje nowy ID
- [ ] Zweryfikowac ze Supabase deep links (jesli sa) matchuja nowy ID
- [ ] `flutter build apk --debug` przechodzi bez bledow
- [ ] `flutter build ios --debug --no-codesign` przechodzi bez bledow

#### US-002: Konfiguracja release signing (Android)
**Opis:** Jako deweloper, musze skonfigurowac podpisywanie APK/AAB kluczem release, bo Google Play wymaga podpisanej paczki.

**Acceptance Criteria:**
- [ ] Wygenerowac keystore (`keytool -genkey`)
- [ ] Stworzyc `android/key.properties` z danymi keystore (NIE commitowac do git!)
- [ ] Dodac `key.properties` do `.gitignore`
- [ ] Skonfigurowac `signingConfigs` w `build.gradle.kts`
- [ ] `flutter build appbundle --release` generuje podpisany AAB
- [ ] AAB testowany przez `bundletool` lub Google Play Console

#### US-003: Ekran Polityki Prywatnosci w aplikacji
**Opis:** Jako rodzic, chce miec dostep do polityki prywatnosci w aplikacji, bo to wymagane przez COPPA/GDPR i sklepy.

**Acceptance Criteria:**
- [ ] Nowy ekran `privacy_policy_screen.dart` wyswietlajacy tresc z `PRIVACY_POLICY.md`
- [ ] Dostepny z ekranu ustawien (strefa rodzica)
- [ ] Uzupelnic placeholder `[UZUPELNIJ_EMAIL]` w PRIVACY_POLICY.md
- [ ] Uzupelnic placeholder `[UZUPELNIJ_URL]` w PRIVACY_POLICY.md
- [ ] Dodac route w `app_router.dart`
- [ ] Tekst czytelny, scrollowalny

#### US-004: Regulamin (Terms of Service)
**Opis:** Jako deweloper, musze dodac regulamin bo App Store wymaga Terms of Service URL.

**Acceptance Criteria:**
- [ ] Stworzyc `TERMS_OF_SERVICE.md` w katalogu projektu
- [ ] Nowy ekran `terms_screen.dart` lub wspoldzielony z privacy policy
- [ ] Dostepny z ekranu ustawien (strefa rodzica)
- [ ] Dodac route w `app_router.dart`

#### US-005: Konta deweloperskie
**Opis:** Jako deweloper, musze zalozyc konta w sklepach zeby moc opublikowac aplikacje.

**Acceptance Criteria:**
- [ ] Zalozyc konto Google Play Console ($25 jednorazowo)
- [ ] Zalozyc konto Apple Developer Program ($99/rok)
- [ ] Skonfigurowac profil dewelopera (nazwa, adres, kontakt)
- [ ] Dla Google Play: wypelnic deklaracje "Designed for Families" (wymagane dla apek dzieciecych)
- [ ] Dla App Store: wypelnic Age Rating questionnaire

---

### FAZA 2: Jakosc kodu i stabilnosc

#### US-006: Rozszerzenie testow jednostkowych
**Opis:** Jako deweloper, chce miec minimum 70% pokrycia testami zeby miec pewnosc ze aplikacja dziala poprawnie.

**Status: DONE** (551 testow, 13 plikow testowych)

**Acceptance Criteria:**
- [x] Dodac `mocktail` i `fake_async` do dev_dependencies (zamiast mockito)
- [ ] Testy logiki gier: counting_game, sequence_game, find_letter
- [ ] Testy TracingCanvas: calculateScore(), waypoint detection
- [ ] Testy ConnectSyllables: sprawdzanie poprawnosci odpowiedzi
- [x] Testy PetNotifier: feed(), play(), wash(), sleep(), wakeUp(), acknowledgeRunaway() (68 testow)
- [x] Testy DatabaseService: addReward(), consumeItem(), getInventoryCounts() (76 testow z mockiem Supabase)
- [x] Testy AnalyticsService: logEvent(), identifyUser() (39 testow z mockiem Firebase/PostHog)
- [x] Testy DrawingProvider: undo/redo, narzedzia (62 testy)
- [x] Testy InventoryProvider: stream, konsumpcja (42 testy)
- [x] Testy SoundEffectsProvider + BackgroundMusicProvider (55 testow)
- [x] Testy ReviewService (17 testow)
- [x] Testy modeli: DrawingPoint (22), TracingPath (122)
- [x] `flutter test` przechodzi bez bledow (551 testow PASS)
- [ ] Coverage raport >= 70% (do uruchomienia z --coverage)

#### US-007: Testy E2E krytycznych flowow
**Opis:** Jako deweloper, chce przetestowac kluczowe sciezki uzytkownika end-to-end.

**Status: DONE** (30 testow integracyjnych, 4 sciezki)

**Acceptance Criteria:**
- [x] Test: Launch → Home → Wybor gry → Ukonczenie rundy → Powrot (8 testow)
- [x] Test: Launch → Zwierzak → Karmienie → Zabawa → Sen/Budzenie (10 testow)
- [x] Test: Launch → Ustawienia → Strefa rodzica → Bramka 4s (7 testow)
- [x] Test: Nawigacja po ekranach glownych (5 testow)
- [ ] Test: Offline mode - gry dzialaja bez internetu
- [ ] Testy uruchomione na emulatorze Android i Simulatorze iOS

**Pliki:** `integration_test/app_test.dart`, `integration_test/helpers/test_app.dart`

#### US-008: Audyt wydajnosci
**Opis:** Jako deweloper, musze sprawdzic ze aplikacja dziala plynnie na starszych urzadzeniach (dzieci czesto maja starsze tablety).

**Status: AUDYT DONE** (raport w `docs/PERFORMANCE_AUDIT.md`, quick wins zidentyfikowane)

**Acceptance Criteria:**
- [ ] Uruchomic Flutter DevTools Performance overlay
- [ ] Brak jank (frame drops) na ekranie glownym
- [ ] Brak jank podczas rysowania na TracingCanvas
- [ ] Czas startu aplikacji < 3 sekundy (cold start)
- [ ] Uzycie pamieci < 200MB
- [ ] Przetestowac na urzadzeniu z Android 8+ (API 26)

**Zidentyfikowane quick wins (z audytu):**
- [ ] QW-1: Future.wait() zamiast sekwencyjnego init w main.dart (~0.5-1.5s oszczednosci)
- [ ] QW-2: signInAnonymously() po runApp (nie blokuje UI)
- [ ] QW-3: Usuniecie 300ms sztucznego delay w PreloaderScreen
- [ ] QW-4: Precache Google Fonts offline
- [ ] QW-5: HomeScreen ref.watch z select() (unikniecie rebuild co 10s)

#### US-009: Weryfikacja Supabase RLS
**Opis:** Jako deweloper, musze upewnic sie ze Row Level Security w Supabase jest poprawnie skonfigurowany i uzytkownik nie moze odczytac danych innych uzytkownikow.

**Status: DONE** (audyt + migracje zastosowane na produkcji 2026-02-05)

**Acceptance Criteria:**
- [x] Tabela `inventory`: RLS ON, polityki SELECT/INSERT/UPDATE/DELETE z auth.uid()=user_id
- [x] Tabela `pet_states`: RLS ON, polityka ALL z auth.uid()=user_id
- [x] Tabela `analytics_events`: RLS ON, polityki SELECT/INSERT (append-only, brak UPDATE/DELETE)
- [ ] Tabela `daily_logins`: nie istnieje jeszcze (RLS gotowe w SQL na przyszlosc)
- [ ] Test: anonimowy user A nie widzi danych user B (do zweryfikowania recznie)
- [x] Supabase anon key chroniony przez RLS na wszystkich 3 tabelach

**Naprawione problemy krytyczne (2026-02-05):**
- Usunieto niebezpieczne polityki "Public insert" i "Public select" z inventory
- Zmieniono FK na ON DELETE CASCADE (inventory, pet_states) - GDPR Art. 17
- Utworzono tabele analytics_events od zera z pelnym RLS
- Utworzono atomowa funkcje RPC add_evolution_points (eliminuje race condition)
- Przeniesiono PostHog API key do gitignorowanego configu

**Pliki:** `supabase/migrations/001-004`, `docs/SUPABASE_RLS_AUDIT.md`

---

### FAZA 3: Rive + Onboarding

#### US-010: Integracja Rive z Flutter
**Opis:** Jako dziecko, chce zeby moj zwierzak byl ladnie animowany i reagowal na moje akcje.

**Acceptance Criteria:**
- [ ] Dodac `rive` package do pubspec.yaml
- [ ] Stworzyc `RivePetWidget` w `lib/widgets/`
- [ ] Mapowanie PetState (hunger, happiness, energy, hygiene) → Rive inputs
- [ ] Trigger animacji: OnTap, OnFeed, OnPlay, OnWash
- [ ] Animacja idle (oddychanie, mruganie)
- [ ] Animacja happy vs sad (w zaleznosci od stanu)
- [ ] Animacja sleeping (zzz)
- [ ] Animacja ewolucji (przejscie miedzy fazami)
- [ ] Zamiana obecnego `Image.asset(_getEggAsset())` na `RivePetWidget`
- [ ] Plynna animacja (60fps) na urzadzeniu testowym

#### US-011: Multi-Pet Support
**Opis:** Jako dziecko, chce wybrac swojego zwierzaka z kilku opcji.

**Acceptance Criteria:**
- [ ] Dodac pole `petType` do PetState (enum: dragon, phoenix, griffin, unicorn, crystal)
- [ ] Nowy ekran `pet_selection_screen.dart` z 5 animowanymi jajkami
- [ ] Animacja wyboru (jajko powieksza sie, reszta znika)
- [ ] Zapis wyboru w SharedPreferences + Supabase
- [ ] Routing: pierwszy launch → wybor zwierzaka → ekran zwierzaka
- [ ] Kazdy typ mapuje na odpowiedni plik .riv
- [ ] Migracja istniejacych danych (domyslnie dragon)

#### US-012: Onboarding Flow
**Opis:** Jako nowy uzytkownik (rodzic/dziecko), chce zobaczyc krotkie wprowadzenie do aplikacji przy pierwszym uruchomieniu.

**Acceptance Criteria:**
- [ ] Zaprojektowac flow onboardingu (do ustalenia z uzytkownikiem)
- [ ] Nowy ekran/seria ekranow onboardingowych
- [ ] Pokazanie glownych funkcji: gry, zwierzak, nagrody
- [ ] Mozliwosc pominiecia ("Pomin")
- [ ] Flaga `onboarding_completed` w SharedPreferences
- [ ] Routing: pierwszy launch → onboarding → home (nastepne launche → home)
- [ ] Animacje/ilustracje przyjazne dla dzieci

---

### FAZA 4: Materialy marketingowe i submission

#### US-013: Profesjonalna ikona aplikacji
**Opis:** Jako deweloper, potrzebuje profesjonalnej ikony ktora wyglada dobrze w sklepie.

**Acceptance Criteria:**
- [ ] Ikona 1024x1024 PNG (App Store wymaga dokladnie ten rozmiar)
- [ ] Ikona 512x512 PNG (Google Play)
- [ ] Brak kanalu alpha w wersji iOS (App Store wymaga)
- [ ] Wyrazista na malym rozmiarze (32x32 nadal czytelna)
- [ ] Uruchomic `flutter pub run flutter_launcher_icons` po podmianie
- [ ] Adaptive icon na Android (foreground + background)

#### US-014: Screenshoty do sklepow
**Opis:** Jako deweloper, potrzebuje profesjonalnych screenshtow do stron w sklepach.

**Acceptance Criteria:**
- [ ] Minimum 4 screenshoty (Google Play wymaga min. 2, App Store min. 3)
- [ ] Rozmiary: 1290x2796 (iPhone 15 Pro Max) i 2048x2732 (iPad Pro 12.9)
- [ ] Screenshoty pokazujace: ekran glowny, gre edukacyjna, zwierzaka, rysowanie
- [ ] Opcjonalnie: dodac teksty/ramki marketingowe na screenshotach
- [ ] Screenshoty na czystym urzadzeniu (bez paska debugowania)

#### US-015: Opisy w sklepach (ASO)
**Opis:** Jako deweloper, potrzebuje zoptymalizowanych opisow do Google Play i App Store.

**Acceptance Criteria:**
- [ ] Krotki opis (80 znakow) - Google Play
- [ ] Pelny opis (4000 znakow) - Google Play
- [ ] Subtitle (30 znakow) - App Store
- [ ] Promotional text (170 znakow) - App Store
- [ ] Description (4000 znakow) - App Store
- [ ] Keywords (100 znakow) - App Store
- [ ] Opisy w jezyku polskim (glowny rynek)
- [ ] Opcjonalnie: opisy w jezyku angielskim

#### US-016: Submission do Google Play
**Opis:** Jako deweloper, chce opublikowac aplikacje w Google Play.

**Acceptance Criteria:**
- [ ] `flutter build appbundle --release` generuje AAB
- [ ] Upload AAB do Google Play Console
- [ ] Wypelnic Store listing (opisy, screenshoty, ikona)
- [ ] Wypelnic Content rating questionnaire
- [ ] Wypelnic "Designed for Families" deklaracje
- [ ] Ustawic Data safety section (jakie dane zbieramy)
- [ ] Ustawic Privacy Policy URL
- [ ] Internal testing → Closed testing → Production
- [ ] Przejsc review Google Play

#### US-017: Submission do App Store
**Opis:** Jako deweloper, chce opublikowac aplikacje w App Store.

**Acceptance Criteria:**
- [ ] `flutter build ipa` generuje IPA
- [ ] Upload przez Xcode lub Transporter
- [ ] Wypelnic App Store Connect metadata
- [ ] Wypelnic Age Rating (4+)
- [ ] Ustawic Privacy Nutrition Labels (jakie dane zbieramy)
- [ ] Ustawic Privacy Policy URL
- [ ] TestFlight beta → Production submission
- [ ] Przejsc review Apple (uwaga: strozsze niz Google)

---

## Functional Requirements

- FR-01: Aplikacja musi miec unikalne Application ID (nie com.example)
- FR-02: APK/AAB musi byc podpisany kluczem release
- FR-03: Polityka prywatnosci musi byc dostepna w aplikacji i pod URL
- FR-04: Regulamin musi byc dostepny pod URL
- FR-05: Wszystkie debugPrint musza byc owijte w `if (kDebugMode)` **(DONE)**
- FR-06: Crashlytics musi lapac bledy z runZonedGuarded, PlatformDispatcher i serwisow **(DONE)**
- FR-07: Animacje Rive musza zastapic statyczne obrazki zwierzaka
- FR-08: Onboarding musi sie wyswietlic tylko przy pierwszym uruchomieniu
- FR-09: Dane uzytkownika musza byc chronione przez Supabase RLS **(DONE - 3/3 tabel z RLS)**
- FR-10: Aplikacja musi dzialac offline (SharedPreferences jako cache)
- FR-11: Aplikacja musi spelnic COPPA/GDPR (brak danych osobowych dzieci, zgoda rodzica)
- FR-12: Sekrety (API keys) nie moga byc hardcoded w commitowanym kodzie **(DONE)**
- FR-13: FK z ON DELETE CASCADE na wszystkich tabelach (GDPR Art. 17 - prawo do usuniecia) **(DONE)**
- FR-14: Panel Rodzica z wykresami aktywnosci, ulubionymi grami i eksportem statystyk **(DONE)**

## Non-Goals (Out of Scope dla v1.0)

- Nowe gry edukacyjne (dodawanie, kolory, zegar) - backlog
- System naklejek/odznak - zamrozony
- Powiadomienia push
- Lokalizacja na inne jezyki (oprócz polskiego)
- Monetyzacja / zakupy in-app
- Social features / leaderboardy
- Widget na ekran glowny
- Apple Watch / WearOS companion
- Tablet-specific layout (obecny responsive layout jest wystarczajacy)

## Technical Considerations

### Obecny stack:
- Flutter 3.10+ / Dart 3.x
- State management: Riverpod
- Routing: go_router
- Backend: Supabase (auth + database + realtime)
- Analytics: Firebase Analytics + PostHog (session replay)
- Crash reporting: Firebase Crashlytics
- Audio: audioplayers
- Local storage: SharedPreferences

### Zaleznosci dodane (sesja 2026-02-05):
- `mocktail: ^1.0.4` - testy (zamiast mockito - prostszy, bez codegen)
- `fake_async: ^1.3.2` - testy timerów
- `fl_chart: ^0.69.0` - wykresy w Panelu Rodzica

### Zaleznosci do dodania:
- `rive: ^0.13.x` - animacje zwierzaka (Faza 3)

### Wazne pliki konfiguracyjne:
- `android/app/build.gradle.kts` - Application ID, signing, min SDK
- `ios/Runner/Info.plist` - Bundle ID, permissions
- `pubspec.yaml` - wersja, dependencies
- `lib/config/supabase_config.dart` - klucze Supabase (gitignored, chroniony przez RLS)
- `lib/config/posthog_config.dart` - klucz PostHog (gitignored)
- `supabase/migrations/` - SQL migracje RLS (w version control)

### Raporty i dokumentacja:
- `docs/SUPABASE_RLS_AUDIT.md` - pelny audyt bezpieczenstwa RLS
- `docs/PERFORMANCE_AUDIT.md` - audyt wydajnosci z quick wins

## Success Metrics

- Aplikacja przechodzi review Google Play i App Store za pierwszym razem
- Zero crashy w pierwszym tygodniu (monitorowanie przez Crashlytics)
- Czas startu < 3 sekundy na urzadzeniu testowym
- Ocena 4.5+ w sklepach po pierwszych 50 ocenach
- Test coverage >= 70%

## Open Questions

1. **Application ID** - jaki docelowy? Propozycja: `com.tarnas.kids` lub `pl.tarnas.kids`
2. **Privacy Policy URL** - gdzie bedzie hostowana? (GitHub Pages? Supabase?)
3. **Email kontaktowy** - jaki adres do PRIVACY_POLICY.md?
4. **Onboarding** - jaki dokladnie flow? (do ustalenia w osobnej sesji)
5. **Assety Rive** - kto je tworzy? Harmonogram?
6. **Kategoria w sklepie** - "Education" czy "Kids" (albo obie)?
7. **Wiek docelowy w sklepie** - "Ages 5 & Under" czy "Ages 6-8" czy "Ages 5-8"?
8. **Czy aplikacja bedzie darmowa** czy bedzie plan platny?

---

## Status Tracker

| Faza | Story | Status | Notatki |
|------|-------|--------|---------|
| 1 | US-001 App ID | TODO | Czeka na decyzje ID |
| 1 | US-002 Signing | TODO | |
| 1 | US-003 Privacy Policy | **DONE** | Ekran gotowy, placeholdery email+URL do uzupelnienia |
| 1 | US-004 Terms of Service | **DONE** | |
| 1 | US-005 Konta deweloperskie | TODO | Krzysiek musi zalozyc |
| 2 | US-006 Testy jednostkowe | **DONE** | 551 testow, 13 plikow, mocktail+fake_async |
| 2 | US-007 Testy E2E | **DONE** | 30 testow, 4 sciezki krytyczne |
| 2 | US-008 Wydajnosc | **AUDYT DONE** | Raport gotowy, 5 quick wins do wdrozenia |
| 2 | US-009 Supabase RLS | **DONE** | Audyt + migracje na produkcji |
| 3 | US-010 Rive | TODO | Zalezy od assetow |
| 3 | US-011 Multi-Pet | TODO | Zalezy od US-010 |
| 3 | US-012 Onboarding | TODO | Do zaprojektowania |
| 4 | US-013 Ikona | TODO | Krzysiek generuje w Gemini |
| 4 | US-014 Screenshoty | TODO | Po zakonczeniu Fazy 3 |
| 4 | US-015 Opisy ASO | TODO | |
| 4 | US-016 Google Play | TODO | Po Fazie 1-3 |
| 4 | US-017 App Store | TODO | Po Fazie 1-3 |

### Postep faz:
- **FAZA 1:** 2/5 DONE (US-003, US-004) — blokery: App ID, Signing, konta deweloperskie
- **FAZA 2:** 4/4 DONE (US-006, US-007, US-008 audyt, US-009) — FAZA ZAKONCZONA
- **FAZA 3:** 0/3 — czeka na assety Rive
- **FAZA 4:** 0/5 — czeka na Faze 1+3

### Juz zrobione (poprzednie sesje):
- [x] FR-05: debugPrint owijte w kDebugMode (~100+ wystapien, 14 plikow)
- [x] FR-06: Crashlytics - runZonedGuarded, PlatformDispatcher, recordError w serwisach
- [x] Czyszczenie dead code (TODO, zakomentowany kod)
- [x] Mounted checks w animacjach
- [x] Share app / "Polec znajomemu" w ustawieniach
- [x] Silent catch blocks - dodano logging
- [x] In-app review (ReviewService po 5 grach)
- [x] US-004: Terms of Service - ekran, route /terms, link w strefie rodzica
- [x] US-003: Privacy Policy - ekran, route /privacy-policy, link w strefie rodzica (placeholdery email+URL czekaja)

### Zrobione (sesja 2026-02-05):
- [x] Organizacja 33 niezcommitowanych plikow w 5 logicznych commitow
- [x] US-006: 551 testow jednostkowych (modele, providery, serwisy) - mocktail + fake_async
- [x] US-007: 30 testow E2E (nawigacja, pet, ustawienia/bramka rodzica, gry)
- [x] US-008: Audyt wydajnosci - raport z 5 quick wins (startup ~4.8s → ~2.6s po wdrozeniu)
- [x] US-009: Audyt RLS + naprawione KRYTYCZNE braki:
  - Usunieto publiczne polityki z inventory (Public insert/select)
  - RLS na analytics_events (nowa tabela)
  - FK ON DELETE CASCADE na wszystkich tabelach (GDPR)
  - Atomowy RPC add_evolution_points (race condition fix)
  - PostHog API key przeniesiony do gitignorowanego configu
- [x] Rozbudowa Panelu Rodzica: wykresy fl_chart, statystyki, eksport, skeleton loading
- [x] SQL migracje w version control (supabase/migrations/000-004)

### Commity sesji 2026-02-05:
```
e81ab90 fix: krytyczne braki RLS + przeniesienie sekretow do configu
0b1f5a4 feat: rozbudowa panelu rodzica - wykresy, statystyki, eksport
f58acca test: testy E2E - nawigacja, pet, ustawienia, gry
94d793c docs: audyt RLS + audyt wydajnosci
0abb6e0 test: 551 testow jednostkowych - modele, providery, serwisy
e958bd7 chore: gitignore nul
eb53183 chore: zaleznosci, web config, PRD
0ab6789 refactor: database_service, gry, providery
89b5597 feat: privacy policy, terms, review service
93d9682 feat: Crashlytics, splash screens, kDebugMode
```

---

*Utworzono: 2026-02-04*
*Ostatnia aktualizacja: 2026-02-05*
