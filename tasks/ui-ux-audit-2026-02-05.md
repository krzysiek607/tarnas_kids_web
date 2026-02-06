# UI/UX Audit - TaLu Kids (2026-02-05)

## Problemy KRYTYCZNE (widoczne od razu)

### 1. Za male przyciski dla dzieci 3-8 lat
- Przyciski Settings/Music na Home: **44x44px** (powinno byc 60+)
- Back buttons: **44x44px**
- Przyciski rysowania (AppBar): **48x48px**
- Przyciski akcji zwierzaka: za niskie (~55px wysokosci)
- **Fix:** Zwiekszyc wszystkie touch targety do min 56-60px

### 2. Mikroskopijny tekst
- Nazwy jedzenia w ekwipunku pet_screen: **10px** - prawie nieczytelne
- Etykiety przyciskow zwierzaka: **11px**
- Nazwy narzedzi rysowania: **11px**
- Nazwy przedmiotow w "Znajdz litere": **11px**
- Matching game card labels: **14px** - borderline
- **Fix:** Zwiekszyc tekst z 10-11px do min 14-16px

### 3. Brakujace assety zwierzaka
- Fazy 3 (secondCrack) i 4 (hatched) uzywaja placeholderow z Fazy 2
- Dziecko przechodzi >50% ewolucji bez wizualnej zmiany
- Pliki: `assets/images/Creature/` - tylko 8 plikow, brak unikatowych dla faz 3-4

### 4. Przycisk "Przygoda" na ekranie glownym
- Pokazuje zwykly `SnackBar` "Wkrotce wiecej!" - wyglada jak bug
- **Fix:** Ukryc lub usunac przycisk do czasu implementacji

---

## Problemy WYSOKIE (profesjonalizm)

### 5. Duplikacja kodu `_ArchMenuButton`
- Ten sam widget (130+ linii) skopiowany 3x w:
  - `lib/screens/home_screen.dart` (linie 214-342)
  - `lib/screens/learning_screen.dart` (linie 189-317)
  - `lib/screens/fun_screen.dart` (linie 157-285)
- Rowniez `_BackButton` zduplikowany w learning i fun
- **Fix:** Wyciagnac do `lib/widgets/arch_menu_button.dart` i `lib/widgets/back_button.dart`

### 6. Niespojne dialogi
- Gry: `KidFriendlyConfirmDialog` (kolorowy, z emoji) - DOBRY
- Zwierzak reset: standardowy `AlertDialog` (szary, dorosly) - ZLY
- Settings usuniecie danych: tez standardowy AlertDialog - ZLY
- **Fix:** Wszedzie uzyc `KidFriendlyConfirmDialog`

### 7. Niespojnna nawigacja
- Home/Fun: `context.push()` (go_router)
- Learning: `Navigator.push()` z `FadePageRoute`
- Pet: `Navigator.pop()` bezposrednio
- **Fix:** Ujednolicic - wszedzie go_router

### 8. Brak Semantics (dostepnosc)
- Prawie zero etykiet `Semantics` - niedostepne dla czytnikow ekranu
- Tylko 1 Semantics widget znaleziony (w BubbleTooltip)
- **Fix:** Dodac Semantics labels na nawigacji, przyciskach, grach

---

## Problemy SREDNIE (jakosc)

### 9. Ekran glowny - brak brandingu
- Nie ma logo ani nazwy "TaLu Kids" - tylko tlo i przyciski
- **Fix:** Dodac animowane logo/maskotke u gory ekranu

### 10. Zwierzak wyglada blado
- `Opacity(0.8)` na obrazku zwierzaka w pet_screen - wyglada "wymyty"
- **Fix:** Usunac lub podniesc do 0.95

### 11. Za duzo ikon w AppBar rysowania
- 6 przyciskow (back, share, save, undo, redo, delete) - przytlaczajace dla dziecka
- **Fix:** Przeniesc share/save do menu dolnego, zostawic undo/redo/back

### 12. Emoji jako ikony - ryzyko renderingu
- Rendering emoji rozni sie miedzy Android/iOS/starsze urzadzenia
- Niektorych emoji (np. 🪿 ges) nie renderuja na starszych telefonach
- **Fix (dlugoterminowy):** Wlasne ikony SVG dla kluczowych elementow

### 13. Nieuzywane widgety (dead code)
- `lib/widgets/big_button.dart` - nieuzywany
- `lib/widgets/game_tile.dart` - nieuzywany
- **Fix:** Usunac

### 14. Hardcoded stat bar width na pet screen
- `_StatBar` oblicza szerokosc: `(MediaQuery.of(context).size.width - 200) * (value / 100)`
- Hardcoded 200px nie dziala dobrze na roznych ekranach
- **Fix:** Uzyc `LayoutBuilder` lub `Expanded` z `FractionallySizedBox`

### 15. Preloader bez brandingu
- Faza 1 ladowania: goaly `CircularProgressIndicator` na bialym tle
- Brak logo, nazwy, ani zadnej grafiki podczas ladowania
- **Fix:** Dodac logo/animacje ladowania

### 16. Dwa fonty uzywane niespojnie
- Glowny: **Nunito** (cala aplikacja)
- Specjalny: **Fredoka** (tylko evolution overlay i tracing game titles)
- Fredoka pojawia sie w 2 miejscach - wyglada niespojnie
- **Fix:** Albo uzyc Fredoka w wiekszej ilosci "specjalnych momentow" albo usunac

### 17. Brak stanow ladowania w grach
- Gry (matching, maze, dots) nie maja loading indicators
- Jesli dane potrzebuja chwili, uzytkownik widzi pusty ekran

### 18. Brak empty states w grach
- Jesli cos sie nie zaladuje, wiekszosc gier pokazuje puste obszary
- Tylko inventory na pet screen ma explicit empty state ("Zbieraj w grach!")

---

## Mocne strony (NIE ZMIENIAC)

- **S1. Paleta kolorow** - Pink/teal/yellow/purple cieply i przyjazny. Background #FFF9F5 lagodny.
- **S2. Mikro-interakcje** - Scale animations, BubbleTooltip, particle explosions, confetti, bounce+fly.
- **S3. Dzwiek** - Click sounds, success/error, animal sounds, music ducking, syllable audio.
- **S4. Bramka rodzicielska** - 4-sekundowe przytrzymanie z progress bar - eleganckie.
- **S5. Glassmorphism** - Spojny styl na pet screen (70% white, 20px radius).
- **S6. System nagrod** - Cookie/candy/icecream/chocolate -> karmienie zwierzaka = gameplay loop.
- **S7. Drawing optimization** - Backing-image pattern (bake strokes to bitmap) - pro.
- **S8. Skeleton loader** - Drawing screen ma porz  adny skeleton loading.

---

## Plan dzialania (priorytet)

### Quick wins (1 sesja):
1. Zwiekszyc touch targety do min 56-60px (home, learning, fun, pet, drawing)
2. Zwiekszyc tekst z 10-11px do 14-16px (pet, drawing, find_letter, matching)
3. Usunac `Opacity(0.8)` ze zwierzaka
4. Wyciagnac `_ArchMenuButton` do wspolnego widgetu
5. Ukryc/usunac przycisk "Przygoda"
6. Usunac `BigButton`/`GameTile` (dead code)

### Srednioterminowe (1-2 sesje):
7. Ujednolicic dialogi - wszedzie `KidFriendlyConfirmDialog`
8. Ujednolicic nawigacje - wszedzie go_router
9. Uproscic AppBar rysowania (3 ikony zamiast 6)
10. Dodac logo/maskotke na ekranie glownym
11. Naprawic hardcoded stat bar width

### Dlugoterminowe:
12. Dedykowane assety dla faz 3-4 ewolucji
13. Wlasne ikony SVG zamiast emoji
14. Semantics dla dostepnosci (WCAG 2.1 AA)
15. Rive animacje (z PRD Faza 3)
16. Loading/empty states we wszystkich grach

---

## Pliki do modyfikacji (mapowanie)

| Problem | Plik(i) |
|---------|---------|
| Touch targety Home | `lib/screens/home_screen.dart` (settings/music buttons) |
| Touch targety Learning/Fun | `lib/screens/learning_screen.dart`, `lib/screens/fun_screen.dart` (back button) |
| Touch targety Pet | `lib/screens/pet_screen.dart` (action buttons) |
| Touch targety Drawing | `lib/screens/drawing_screen.dart` (AppBar buttons) |
| Maly tekst Pet | `lib/screens/pet_screen.dart` (food names 10px, button labels 11px) |
| Maly tekst Drawing | `lib/screens/drawing_screen.dart` (tool names 11px) |
| Maly tekst FindLetter | `lib/screens/learning/find_letter_screen.dart` (item names 11px) |
| Maly tekst Matching | `lib/screens/games/matching_game_screen.dart` (card labels 14px) |
| ArchMenuButton duplikacja | `lib/screens/home_screen.dart`, `learning_screen.dart`, `fun_screen.dart` |
| Niespojne dialogi | `lib/screens/pet_screen.dart`, `lib/screens/settings_screen.dart` |
| Nawigacja | `lib/screens/learning_screen.dart` (uzywa Navigator zamiast go_router) |
| Opacity zwierzaka | `lib/screens/pet_screen.dart` (Opacity 0.8) |
| AppBar rysowania | `lib/screens/drawing_screen.dart` (6 przyciskow) |
| Dead code | `lib/widgets/big_button.dart`, `lib/widgets/game_tile.dart` |
| Stat bar width | `lib/screens/pet_screen.dart` (_StatBar hardcoded 200px) |
| Przycisk Przygoda | `lib/screens/home_screen.dart` (snackbar "Wkrotce wiecej!") |

---

*Audit przeprowadzony: 2026-02-05*
*Agent: Claude Opus 4.6 z pelnym przegladem 41 plikow*
