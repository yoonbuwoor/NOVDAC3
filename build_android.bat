@echo off
where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter n'est pas installe ou absent du PATH.
  pause
  exit /b 1
)
flutter create --platforms=android --org com.novateur221 --project-name droneatlas .
python tool\configure_android.py
flutter pub get
flutter build apk --release
if errorlevel 1 (
  echo La compilation a echoue.
  pause
  exit /b 1
)
echo APK cree dans build\app\outputs\flutter-apk\app-release.apk
pause
