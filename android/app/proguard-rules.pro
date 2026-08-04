# Regole ProGuard/R8 per WeCoop (release con minify + shrink).
# Manteniamo le classi delle librerie native che usano reflection.

# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Stripe (flutter_stripe / stripe-android)
-keep class com.stripe.android.** { *; }
-keep class com.reactnativestripesdk.** { *; }
-dontwarn com.stripe.android.**

# Firebase / FCM
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Modelli serializzati con reflection (se presenti). Mantiene i costruttori.
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Evita warning generici su annotazioni mancanti.
-dontwarn javax.annotation.**
