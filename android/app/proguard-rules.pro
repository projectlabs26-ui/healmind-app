# Flutter-specific ProGuard rules

# Keep Flutter wrapper classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep annotation
-keepattributes *Annotation*

# Keep Hive
-keep class com.healmind.healmind.models.** { *; }

# Keep Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }

# Keep AdMob
-keep class com.google.android.gms.internal.ads.** { *; }
