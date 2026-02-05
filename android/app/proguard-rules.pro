# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }

# Supabase / OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }

# PostHog
-keep class com.posthog.** { *; }

# Google Play Core (deferred components - not used but referenced by Flutter)
-dontwarn com.google.android.play.core.**

# Keep annotations
-keepattributes *Annotation*
