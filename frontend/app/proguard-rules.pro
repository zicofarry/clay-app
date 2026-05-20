# Clay ProGuard Rules
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable

# Moshi
-keep class com.clay.core.model.** { *; }
-keep class com.clay.core.network.api.** { *; }
-dontwarn com.squareup.moshi.**

# Retrofit
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }
-keepclasseswithmembers class * {
    @retrofit2.http.* <methods>;
}

# OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
