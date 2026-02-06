# Performance Audit - TaLu Kids

**Date:** 2026-02-05
**Target:** App startup < 3 seconds on 3G
**Platform:** Flutter (Android/iOS, tablets primary)

---

## 1. Startup Flow Analysis

### Waterfall Diagram (Sequential Execution)

```
[0ms]     WidgetsFlutterBinding.ensureInitialized()
[~10ms]   SystemChrome.setPreferredOrientations()      ~50ms
[~60ms]   _initializeFirebase()                         ~300-800ms (BLOCKING)
            Firebase.initializeApp()
            Crashlytics setup
[~860ms]  _initializePostHog()                          ~200-500ms (BLOCKING)
            PostHog setup + session replay config
[~1360ms] _initializeSupabase()                         ~500-1500ms (BLOCKING)
            Supabase.initialize()                         ~200-400ms
            signInAnonymously() [network!]                ~300-800ms
            DatabaseService.initialize()                  ~10ms
            AnalyticsService.initialize()                 ~50ms
            identifyUser() [network!]                     ~100-300ms
[~2860ms] runApp(TaLuKidsApp)                         ~50ms
[~2910ms] PreloaderScreen renders
            300ms artificial delay (emoji preload)        300ms (BLOCKING)
[~3210ms] _VideoIntroContent initializes
            VideoPlayerController.asset() load            ~500-2000ms (BLOCKING)
            Video playback starts                         8000ms video
            0.5s pause on last frame                      500ms
[~11710ms] context.go('/home')
            HomeScreen renders
            Background music auto-play attempt
```

**TOTAL ESTIMATED TIME TO INTERACTIVE: ~3.2-4.8 seconds (before video)**
**TOTAL TIME TO HOME SCREEN: ~12 seconds (with full video)**

### Key Observation
The startup waterfall shows **three sequential network calls** before the app even renders its first frame. On a 3G connection (~300kbps, 100-500ms latency), each network round-trip adds 500-2000ms. The video intro adds another 8+ seconds on top of that.

---

## 2. Identified Bottlenecks

### CRITICAL: Sequential Service Initialization (main.dart lines 27-33)

**Impact: ~1.5-3.0 seconds wasted**

Firebase, PostHog, and Supabase are initialized **sequentially** with `await`:

```dart
await _initializeFirebase();    // ~300-800ms
await _initializePostHog();     // ~200-500ms
await _initializeSupabase();    // ~500-1500ms (includes network call!)
```

These three services have **no dependency on each other** and could be initialized in parallel using `Future.wait()`. The anonymous auth call inside `_initializeSupabase()` is a network request that blocks the entire app on 3G.

### CRITICAL: Anonymous Auth Blocks App Start (main.dart line 157)

**Impact: ~300-800ms on 3G, potentially infinite on no network**

`supabase.auth.signInAnonymously()` is a network call that blocks `_initializeSupabase()`. If the network is slow or unavailable, this delays the entire app startup. There is no timeout configured.

### HIGH: Intro Video Loading (preloader_screen.dart line 124)

**Impact: ~500-2000ms loading + 8s playback + 0.5s pause**

The video (`Taro_Lumi_intro.mp4`) is loaded from assets after the emoji preload delay. On a cold start, decoding this video from the asset bundle takes significant time. Combined with the 8-second playback, users wait 9-11 seconds before seeing the home screen.

The "tap to skip" option exists but only appears **after** the video has been initialized and started playing -- not during the loading phase.

### HIGH: 300ms Artificial Delay in Preloader (preloader_screen.dart line 43)

**Impact: 300ms wasted**

```dart
await Future.delayed(const Duration(milliseconds: 300));
```

This fixed delay was reduced from 800ms but still wastes 300ms every startup for emoji font preloading that may not be necessary on all devices.

### MEDIUM: Google Fonts Network Download (app_theme.dart line 9)

**Impact: ~200-500ms first launch, 0ms cached**

```dart
static TextStyle get _baseTextStyle => GoogleFonts.nunito();
```

`google_fonts` downloads fonts from the internet on first use. On 3G, this can cause noticeable text rendering delays. Additional fonts are loaded in `evolution_overlay.dart` and `tracing_game_screen.dart` using `GoogleFonts.fredoka()`.

### MEDIUM: PetProvider Initialization Chain (pet_provider.dart line 150-263)

**Impact: ~200-500ms**

When `PetNotifier` is first accessed (on HomeScreen), it triggers:
1. `SharedPreferences.getInstance()` - disk I/O
2. `DatabaseService.instance.getSleepStartTime()` - network call
3. `DatabaseService.instance.getEvolutionPoints()` - network call
4. Multiple `prefs.setInt/setDouble` calls - disk I/O

This happens during the first frame of HomeScreen rendering.

### LOW: Background Music Initialization (background_music_provider.dart)

**Impact: ~100-200ms, lazy-loaded**

Audio player initialization is lazy (called on first `play()`), which is good. However, it triggers during the HomeScreen `initState`, adding to the initial frame time.

---

## 3. Asset Optimization

### Current Asset Inventory

| Category | Count | Format | Notes |
|----------|-------|--------|-------|
| Video | 1 | .mp4 | `Taro_Lumi_intro.mp4` - intro video |
| Background images | 5 | .png | home, learning, fun, pet, intro backgrounds |
| Icons | 15 | .png | menu icons, drawing tools |
| Rewards | 4 | .png | cookie, candy, icecream, chocolate |
| Creature/Pet | 8 | .webp | Egg states and evolution phases |
| App icon | 1 | .png | Launcher icon |
| Audio (music) | 1 | .mp3 | Theme music (looping) |
| Audio (SFX) | 3 | .mp3 | click, success, error |
| Audio (animals) | 10 | .mp3 | dog, cat, cow, etc. |
| Audio (syllables) | 80+ | .mp3 | Polish syllables for learning |
| Total assets | ~125+ | mixed | |

### Recommendations

#### Convert PNG to WebP (Quick Win)

The Creature assets already use WebP (good!), but 25 PNG images remain:
- **5 background images** - these are the largest PNGs (full-screen backgrounds)
- **15 icon PNGs** - smaller but still benefit from WebP
- **4 reward PNGs** - small images

**Expected savings:** WebP is typically 25-35% smaller than PNG with equivalent quality. For full-screen backgrounds, this could save 200-500KB per image.

#### Video Optimization

`Taro_Lumi_intro.mp4` is loaded from the asset bundle. Consider:
- Reducing video resolution (720p max for mobile)
- Using H.265/HEVC codec for smaller file size
- Reducing video length (8 seconds is long for impatient kids)
- Using a compressed animation format (Lottie/Rive) instead of video

#### Audio Compression

80+ syllable MP3 files are declared in the asset bundle. While individually small, they collectively increase the app bundle size. Consider:
- Verify all syllable files use consistent low bitrate (64kbps mono is sufficient for speech)
- Lazy-load syllable audio only when the syllable learning screen is opened

---

## 4. Code-Level Optimizations

### 4.1 `withOpacity()` Usage (67 occurrences)

**Impact: Unnecessary Color object allocations**

Found 67 uses of `.withOpacity()` across 13 files. In Flutter, `Color.withOpacity()` creates a new Color object each time. The newer `Color.withValues(alpha: x)` is preferred (already used in some places). While each call is cheap, it adds up in frequently rebuilt widgets.

### 4.2 `print()` Statements in Production (7 occurrences)

**Files:** `sound_effects_controller.dart` (3), `sound_effects_service.dart` (4)

These should use `debugPrint` guarded by `kDebugMode` (as done elsewhere in the codebase) to avoid I/O overhead in release builds.

### 4.3 TracingCanvas Score Calculation - O(n*m) Complexity

**File:** `tracing_canvas.dart` lines 447-571

The `calculateScore()` method has O(n*m) complexity where n = drawn points and m = pattern points. For long tracing paths, this performs thousands of distance calculations. Consider:
- Using a spatial index (grid-based lookup) for pattern points
- Reducing sampling frequency (currently every 5 pixels)
- Caching pattern point positions

### 4.4 DrawingPainter Spray Tool - Excessive Draw Calls

**File:** `drawing_painter.dart` lines 139-160

The spray tool creates `dotCount = strokeWidth * 3` circles per point. For a 24px stroke width, that is 72 circles per touch point, each with its own `drawCircle` call and `Random` instantiation. This can cause jank during fast drawing.

### 4.5 Missing RepaintBoundary Isolation

Several screens load full-screen background images without `RepaintBoundary`:
- `home_screen.dart` - `Image.asset('home_background.png')`
- `pet_screen.dart` - `Image.asset('petscreen_background.png')`

Without `RepaintBoundary`, these static images are re-composited every time any widget in the subtree changes.

### 4.6 HomeScreen Rebuilds on Pet State Changes

**File:** `home_screen.dart` line 60

```dart
final petState = ref.watch(petProvider);
```

HomeScreen watches the entire `petProvider`, which ticks every 10 seconds. This causes the entire HomeScreen to rebuild every 10 seconds just to update the pet icon. Consider using `ref.watch(petProvider.select((s) => s.evolutionStage))` to only rebuild when the evolution stage actually changes.

### 4.7 PetScreen addPostFrameCallback on Every Build

**File:** `pet_screen.dart` line 75-77

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  _checkForEvolution(petState);
});
```

This adds a new callback on **every build**, which is called every 10 seconds due to the pet tick timer. While not a major bottleneck, it creates unnecessary overhead.

### 4.8 Duplicate Sound Effect Services

Two separate services handle sound effects:
- `SoundEffectsService` (3 AudioPlayer instances for click/success/error)
- `SoundEffectsController` (1 AudioPlayer for SFX with ducking)

Both handle `success.mp3` playback. This duplication wastes memory (4 AudioPlayer instances total) and creates potential audio conflicts.

---

## 5. Dependency Analysis

### Current Dependencies (17 production, 6 dev)

| Dependency | Size Impact | Startup Impact | Needed? |
|------------|------------|----------------|---------|
| flutter_riverpod | Low | None | Yes - state management |
| go_router | Low | None | Yes - routing |
| supabase_flutter | **High** | **High** (network) | Yes - backend |
| firebase_core | **High** | **High** (init) | Yes - required for others |
| firebase_analytics | Medium | Low | Evaluate - overlap with PostHog |
| firebase_crashlytics | Medium | Low | Yes - crash reporting |
| posthog_flutter | Medium | **Medium** (init) | Evaluate - overlap with Firebase |
| audioplayers | Medium | Low (lazy) | Yes - audio |
| video_player | Medium | Medium (video decode) | Evaluate - only used for intro |
| google_fonts | Low | **Medium** (network download) | Bundle font instead |
| shared_preferences | Low | Low | Yes - local storage |
| cupertino_icons | Low | None | Yes - icons |
| share_plus | Low | None | Yes - sharing |
| path_provider | Low | None | Yes - file paths |
| gal | Low | None | Yes - gallery save |
| package_info_plus | Low | None | Yes - version info |
| in_app_review | Low | None | Yes - store review |

### Potential Redundancy: Firebase Analytics + PostHog

Both Firebase Analytics and PostHog are initialized at startup and receive the same events. `AnalyticsService._logEvent()` sends every event to **three** systems (Firebase, PostHog, Supabase). Consider:
- Using only PostHog for analytics (already has session replay)
- Keeping Firebase only for Crashlytics
- Removing Supabase analytics_events table (redundant with PostHog)

This would remove `firebase_analytics` dependency and reduce one await in the startup chain.

---

## 6. Recommendations Summary

### Quick Wins (1-2 hours each, high impact)

| # | Recommendation | Estimated Impact | Effort |
|---|---------------|-----------------|--------|
| 1 | **Parallelize service initialization** - Use `Future.wait([firebase, posthog, supabase])` in `main()` | **Save 0.5-1.5s startup** | 30 min |
| 2 | **Defer Supabase auth to post-first-frame** - Do not await anonymous auth before `runApp()` | **Save 0.3-1.0s startup** | 1 hour |
| 3 | **Remove 300ms artificial delay** in PreloaderScreen or reduce to 100ms | **Save 200ms startup** | 5 min |
| 4 | **Bundle Nunito font instead of downloading** - Use `google_fonts` local asset mode or replace with bundled font | **Save 200-500ms first launch** | 30 min |
| 5 | **Use `select()` on petProvider in HomeScreen** | **Eliminate rebuilds every 10s** | 10 min |

### Medium-Term Improvements (1-2 days)

| # | Recommendation | Estimated Impact | Effort |
|---|---------------|-----------------|--------|
| 6 | **Convert PNG backgrounds to WebP** | Save 200-500KB bundle size | 2 hours |
| 7 | **Add RepaintBoundary for background images** | Smoother animations on low-end tablets | 1 hour |
| 8 | **Merge SoundEffectsService and SoundEffectsController** into one service | Save 2 AudioPlayer instances | 3 hours |
| 9 | **Remove firebase_analytics** (redundant with PostHog) | Faster startup, smaller bundle | 2 hours |
| 10 | **Add configurable timeout to all network calls in startup** | Prevent infinite hangs on no-network | 2 hours |
| 11 | **Replace print() with guarded debugPrint** | Zero I/O overhead in release | 15 min |
| 12 | **Shorten or skip intro video for returning users** - Store flag in SharedPreferences | **Save 8-10s for repeat launches** | 2 hours |

### Long-Term Improvements (1+ weeks)

| # | Recommendation | Estimated Impact | Effort |
|---|---------------|-----------------|--------|
| 13 | **Replace video intro with Lottie/Rive animation** | Faster load, smaller bundle, smoother | 1 week |
| 14 | **Implement spatial indexing for tracing score calculation** | 60fps during complex tracing | 2-3 days |
| 15 | **Lazy-load syllable audio files** - Only load when learning screen opens | Reduce initial memory footprint | 1 day |
| 16 | **Implement image precaching** for screens - Use `precacheImage()` during preloader | Instant screen transitions | 1 day |
| 17 | **Profile and optimize spray tool rendering** | Smooth 60fps drawing | 1-2 days |

---

## 7. Estimated Impact Summary

### Current Startup Timeline (3G worst case)

```
Service init (sequential): ~2.0-3.5s
Preloader delay:           ~0.3s
Video load + play:         ~8.5-10s
Total to home:             ~10.8-13.8s
```

### After Quick Wins (#1-5)

```
Service init (parallel):   ~0.8-1.5s  (saved ~1.2-2.0s)
Preloader delay:           ~0.1s      (saved ~0.2s)
Video (skippable earlier): ~1.0-8.5s  (tap to skip works during load)
Total to home:             ~1.9-10.1s
Time to first interactive: ~1.9-2.6s  (TARGET MET)
```

### After All Recommendations

```
Service init (parallel, deferred auth):  ~0.5-1.0s
No artificial delay:                     ~0s
Animation instead of video:              ~2-3s (or skip for returning users)
Total to home (new user):                ~2.5-4.0s
Total to home (returning user):          ~0.5-1.0s
```

---

## 8. Security Note

During this audit, I observed that `supabase_config.dart` contains hardcoded Supabase URL and anon key directly in source code. While the anon key is designed to be public-facing (it is used client-side), the PostHog API key (`phc_BL81wy8lEm6vrX1OVV2Y7oINDk99N1wubbhsLEVA3pg`) in `main.dart` line 77 is also hardcoded. These should ideally be provided through environment variables or compile-time configuration (`--dart-define`) to allow easy rotation and prevent accidental exposure in open-source contexts.

---

## 9. Memory Considerations (Tablets with Limited RAM)

- **4 AudioPlayer instances** across two services waste memory. Consolidating to 2 (music + SFX) would help.
- **Full-screen PNG backgrounds** (5 screens) are decoded into memory at full resolution. Consider using `cacheWidth`/`cacheHeight` on `Image.asset()` to limit decoded image size to screen resolution.
- **TracingCanvas `_allPointsForScoring`** grows unbounded during a tracing session. Long sessions with many strokes accumulate thousands of `TracingPoint` objects.
- **80+ syllable MP3 files** are declared in the asset bundle manifest. Flutter loads the manifest eagerly -- consider splitting audio into deferred asset bundles if supported.

---

## 10. Animation Smoothness (60fps target)

### Good Practices Already in Place
- `RepaintBoundary` used in `TracingCanvas` (line 700)
- Image baking optimization in `TracingCanvas._bakeCurrentStroke()`
- `DrawingPainter` uses backing image pattern
- `shouldRepaint()` properly implemented in custom painters
- `EvolutionOverlay` uses `RepaintBoundary` for confetti

### Areas for Improvement
- Spray tool rendering creates many draw calls per frame
- `ConfettiPainter.shouldRepaint()` always returns `true` -- could use particle count comparison
- Missing `RepaintBoundary` around static background images in `HomeScreen` and `PetScreen`
- `_StatBar` in `PetScreen` uses `AnimatedContainer` with `MediaQuery.of(context).size.width` calculation on every build

---

*Audit performed on codebase at C:\talu_kids. Focus areas: startup time, memory usage, animation smoothness, and network efficiency.*
