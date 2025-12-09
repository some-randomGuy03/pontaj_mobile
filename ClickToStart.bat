@echo off
setlocal ENABLEDELAYEDEXPANSION

pushd %~dp0

echo.
echo Launching Pontaj App for web...
echo (Make sure Flutter SDK is installed and on PATH)
echo.

where flutter >nul 2>&1
if errorlevel 1 (
  echo ERROR: Flutter is not on PATH. Install Flutter and reopen this window.
  pause
  popd
  exit /b 1
)

REM Try Chrome first; if unavailable, fall back to web-server
flutter devices | findstr /I "chrome" >nul
if %errorlevel%==0 (
  echo Device 'chrome' found. Starting in Chrome...
  flutter run -d chrome
) else (
  echo Chrome device not found. Falling back to web-server...
  echo You can open the provided URL in your browser.
  flutter run -d web-server
)

popd
endlocal
pause

