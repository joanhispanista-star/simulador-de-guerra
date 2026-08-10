@echo off
title Maquinas - Drones de Combate
cd /d "%~dp0"

echo.
echo   ===========================================
echo    MAQUINAS - Drones de Combate
echo   ===========================================
echo.
echo   Levantando el servidor...
echo.

rem  Hace falta servidor: con doble clic sobre drones.html (file://) el
rem  navegador BLOQUEA las descargas del terreno, del satelite y de
rem  OpenStreetMap, y tambien la webcam. Por eso esto y no el archivo suelto.

where node >nul 2>nul
if errorlevel 1 (
  echo   [X] No encuentro Node.js en este equipo.
  echo       Instalalo desde https://nodejs.org y vuelve a abrir esto.
  echo.
  pause
  exit /b 1
)

start "" http://localhost:8199/drones.html

echo   Ya deberia haberse abierto el navegador.
echo   Si no, entra a:  http://localhost:8199/drones.html
echo.
echo   DEJA ESTA VENTANA ABIERTA mientras juegas.
echo   Para cerrar el juego, cierra esta ventana.
echo.

node servidor.js 8199

echo.
echo   El servidor se detuvo.
pause
