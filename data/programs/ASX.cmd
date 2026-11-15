@echo off
setlocal
rem ASX/XJSON program launcher. JavaScript is an optional bridge; this
rem command routes directly to the native JSON runtime.
set "ROOT=%~dp0.."
set "RUNTIME=%ROOT%\bin\micronaut_xjson.exe"
if not exist "%RUNTIME%" set "RUNTIME=%ROOT%\versions\kuhul-v1.0.0\bin\runtime\micronaut_xjson.exe"
if not exist "%RUNTIME%" (
  echo ASX runtime not found: %RUNTIME% 1>&2
  exit /b 2
)
if "%~1"=="" (
  echo Usage: programs\ASX.cmd ^<manifest.json^> [runtime arguments]
  exit /b 64
)
"%RUNTIME%" --manifest "%~1" %2 %3 %4 %5 %6 %7 %8 %9
exit /b %ERRORLEVEL%
