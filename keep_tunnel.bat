@echo off
echo ========================================
echo  ADB Reverse Tunnel - Auto Reconnect
echo ========================================
echo Keeping port 8000 forwarded to your phone...
echo Press Ctrl+C to stop.
echo.

:loop
C:\Users\cheta\AppData\Local\Android\Sdk\platform-tools\adb.exe reverse tcp:8000 tcp:8000 >nul 2>&1
if %errorlevel% == 0 (
    echo [%time%] Tunnel active
) else (
    echo [%time%] Phone disconnected, waiting...
)
timeout /t 3 /nobreak >nul
goto loop
