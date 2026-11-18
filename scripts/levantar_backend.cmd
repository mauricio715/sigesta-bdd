@echo off
title SI-GESTA backend (Laravel :8000)
cd /d "%SIGESTA_DIR%\backend"
"%SIGESTA_PHP%" artisan serve --host=127.0.0.1 --port=8000 > "%SIGESTA_LOGS%\backend.log" 2>&1
