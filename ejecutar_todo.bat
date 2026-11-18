@echo off
cd /d "%~dp0"
echo Ejecutando servidores + pruebas + git. Log en logs\ejecucion.log ...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\ejecutar_todo.ps1" %*
echo.
echo Listo. Resumen en logs\resumen.txt
timeout /t 20
