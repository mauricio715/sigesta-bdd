@echo off
title SI-GESTA ai-service (FastAPI :8001)
cd /d "%SIGESTA_DIR%\ai-service"
".venv\Scripts\python.exe" -m uvicorn main:app --host 127.0.0.1 --port 8001 > "%SIGESTA_LOGS%\ai-service.log" 2>&1
