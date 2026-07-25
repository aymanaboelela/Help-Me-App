# R8 / ProGuard keeps for the release build.
#
# Only add a rule here with a reason attached. An unexplained `-keep` is how a
# shrink config rots into "keep everything" over a few releases.

# ---------------------------------------------------------------------------
# flutter_local_notifications
# ---------------------------------------------------------------------------
# The plugin persists every scheduled reminder as Gson JSON and reflects it back
# after a reboot. R8 has no way to see those reads, so it renames the fields and
# the reminders silently stop arriving — the failure only shows up on a real
# device, hours later, which is the worst possible place to find it.
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class * extends com.dexterous.flutterlocalnotifications.models.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Gson itself, for the same reason: generic type information is read at runtime.
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}
-dontwarn sun.misc.**

# ---------------------------------------------------------------------------
# flutter_secure_storage / Tink
# ---------------------------------------------------------------------------
# Tink registers key managers by class name. Losing one turns a readable health
# card into an unrecoverable decryption failure on the user's own device.
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**
-dontwarn javax.annotation.**
-dontwarn com.google.errorprone.annotations.**

# ---------------------------------------------------------------------------
# Desugaring
# ---------------------------------------------------------------------------
# java.time on API < 26 comes from desugar_jdk_libs; the shrinker sees calls into
# classes it considers absent.
-dontwarn java.lang.invoke.**
-dontwarn build.IgnoreJava8API

# ---------------------------------------------------------------------------
# Play Core
# ---------------------------------------------------------------------------
# Flutter's embedding references the deferred-components API even when the app
# uses no dynamic feature modules, as this one does not.
-dontwarn com.google.android.play.core.**

# ---------------------------------------------------------------------------
# Crash readability
# ---------------------------------------------------------------------------
# Keep line numbers so a stack trace from a user is worth something, but hide the
# original source file name.
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
