@echo off
title SI-GESTA frontend (Vite :5173)
cd /d "%SIGESTA_DIR%\frontend"
call "%SIGESTA_NPM%" run dev > "%SIGESTA_LOGS%\frontend.log" 2>&1
