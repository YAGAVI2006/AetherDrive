@echo off
title AetherDrive SDV Digital Cockpit Launcher
cd /d "%~dp0"
echo ============================================================
echo  Starting AetherDrive SDV Platform & Telemetry Simulator
echo ============================================================
echo 1. Launching Vehicle Dynamics Simulator (10 Hz MQTT Publisher)...
start "AetherDrive Simulator" python simulator\vehicle_simulator.py
timeout /t 1 >nul
echo 2. Launching Digital Cockpit HMI (Qt 6 / QML)...
start "AetherDrive Cockpit HMI" python hmi\hmi_runner.py
echo.
echo Both systems are running! You can interact with the cockpit window.
pause
