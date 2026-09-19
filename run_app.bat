@echo off
title Attendance Management System
echo ========================================================
echo Starting Attendance Management System Server (Port 8080)...
echo ========================================================
echo Opening web application in your default browser...
start http://127.0.0.1:8080
python -m uvicorn backend.main:app --port 8080 --host 127.0.0.1
pause
