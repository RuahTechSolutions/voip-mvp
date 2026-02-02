@echo off
REM Test script for VoIP notification server
REM Make sure the server is running with: npm run dev

setlocal enabledelayedexpansion

echo VoIP Notification Server - Test Script
echo ======================================
echo.

REM Test 1: Health Check
echo [1] Health Check
curl -X GET http://localhost:3000/health
echo.
echo.

REM Test 2: Get all registered tokens
echo [2] Get Registered Tokens
curl -X GET http://localhost:3000/tokens
echo.
echo.

REM Test 3: Register a new token
echo [3] Register New Token (Example)
echo Enter device token (or press Enter to skip):
set /p token=
if not "!token!"=="" (
    curl -X POST http://localhost:3000/register-token ^
      -H "Content-Type: application/json" ^
      -d "{\"token\":\"!token!\"}"
    echo.
)
echo.

REM Test 4: Send notification to specific token
echo [4] Send Notification to Token
echo Enter device token:
set /p sendtoken=
if not "!sendtoken!"=="" (
    curl -X POST http://localhost:3000/send-to-token ^
      -H "Content-Type: application/json" ^
      -d "{\"token\":\"!sendtoken!\",\"title\":\"Incoming Call\",\"body\":\"Test VoIP Notification\"}"
    echo.
)
echo.

REM Test 5: Send to all devices
echo [5] Send to All Registered Devices
curl -X POST http://localhost:3000/send-notification ^
  -H "Content-Type: application/json" ^
  -d "{\"title\":\"Test Call\",\"body\":\"Test notification to all devices\"}"
echo.
echo.

echo Tests Complete!
pause
