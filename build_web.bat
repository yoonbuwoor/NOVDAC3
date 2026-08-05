@echo off
where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter n'est pas installe ou absent du PATH.
  pause
  exit /b 1
)
flutter create --platforms=web --org com.novateur221 --project-name droneatlas .
python tool\configure_web.py
flutter pub get
flutter build web --release
if errorlevel 1 (
  echo La compilation a echoue.
  pause
  exit /b 1
)
echo Version Web creee dans build\web
pause
