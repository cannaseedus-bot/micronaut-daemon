@echo off
setlocal
cd /d "%~dp0"
python -X utf8 tools\build_aiml_bson.py --root "%CD%" --output build\io\aiml-grams\alice.bson
if errorlevel 1 exit /b %ERRORLEVEL%
python -X utf8 tools\bson_to_aiml_runtime.py --bank build\io\aiml-grams\alice.bson --output build\io\aiml-grams\alice.runtime.jsonl
if errorlevel 1 exit /b %ERRORLEVEL%
python -X utf8 tools\aiml_to_gguf.py --from-jsonl build\io\aiml-grams\alice.runtime.jsonl --output-path build\alice.aiml.gguf --repo-root "C:\Users\canna\.llama-win-cpu-x64\llama.cpp"
if errorlevel 1 exit /b %ERRORLEVEL%
exit /b 0
