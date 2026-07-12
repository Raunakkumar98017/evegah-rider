# R8 / Proguard rules for Evegah Rider App
# Ignore missing classes warnings from google_mlkit_text_recognition packages
-dontwarn com.google.mlkit.vision.text.**
-keep class com.google.mlkit.vision.text.** { *; }
