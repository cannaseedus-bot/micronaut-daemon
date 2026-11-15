@echo off
setlocal
rem K'UHUL semantic/stdlib launcher. Backend selection remains native and
rem manifest-driven: OpenCL 1.2, D3D11 CS5, D3D12, or DirectXMath CPU.
set "ROOT=%~dp0.."
set "ENGINE=%ROOT%\versions\kuhul-v1.0.0\bin\native\kuhul_engine.exe"
if not exist "%ENGINE%" (
  echo K'UHUL engine not found: %ENGINE% 1>&2
  exit /b 2
)
if "%~1"=="" (
  echo Usage: programs\KUHUL.cmd ^<program-or-stdlib-file^> [runtime arguments]
  exit /b 64
)
"%ENGINE%" "%~1" %2 %3 %4 %5 %6 %7 %8 %9
exit /b %ERRORLEVEL%
