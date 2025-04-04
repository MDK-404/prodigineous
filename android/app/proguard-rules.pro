# Keep the classes required by Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class io.flutter.plugins.flutterlocalnotifications.** { *; }

# Keep the classes required by the timezone package
-keep class com.google.android.material.datepicker.** { *; }

# Keep Firebase related classes
-keep class com.google.firebase.** { *; }
-keep class com.google.firebase.messaging.** { *; }

# Keep Flutter’s reflection-based code (if needed for scheduling notifications)
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.app.** { *; }

# Keep the required classes for your app's scheduled notifications
-keep class com.example.prodigenious.** { *; }
