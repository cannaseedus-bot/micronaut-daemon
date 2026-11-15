@echo off
setlocal
set "GEMMA_MODEL=C:\Users\canna\.models\gemma-3-1B-it-QAT-Q4_0.gguf"
set "GEMMA_SERVER=C:\Users\canna\.llama-win-cpu-x64\llama-server.exe"
if not exist "%GEMMA_MODEL%" (
  echo Missing Gemma model: %GEMMA_MODEL% 1>&2
  exit /b 2
)
if not exist "%GEMMA_SERVER%" (
  echo Missing llama.cpp CPU server: %GEMMA_SERVER% 1>&2
  exit /b 2
)
echo Starting local Gemma 3 1B on http://127.0.0.1:8091
"%GEMMA_SERVER%" --model "%GEMMA_MODEL%" --host 127.0.0.1 --port 8091 --ctx-size 4096 --parallel 1 --threads 4 --gpu-layers 0 --no-webui --no-slots --no-warmup
exit /b %ERRORLEVEL%
