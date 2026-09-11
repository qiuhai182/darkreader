@echo off
setlocal
cd /d "%~dp0"

rem Dark Reader one-click build script
rem Usage: build.bat          -> release build
rem        build.bat debug    -> debug build

set "MODE=release"
if /i "%~1"=="debug" set "MODE=debug"

where node >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Node.js not found in PATH. Please install Node.js first.
    pause
    exit /b 1
)

if not exist node_modules (
    echo [1/2] First run: installing dependencies, please wait ...
    call npm install --no-audit --no-fund
    if errorlevel 1 goto fail
) else (
    echo [1/2] Dependencies OK
)

echo [2/2] Building Dark Reader (%MODE%) ... this may take a few minutes
if /i "%MODE%"=="debug" (
    call npm run debug
) else (
    call npm run build
)
if errorlevel 1 goto fail

echo.
echo ===== Build OK =====
echo Output: build\%MODE%\chrome , chrome-mv3 , firefox , thunderbird
echo Load via chrome://extensions -^> Load unpacked
pause
exit /b 0

:fail
echo.
echo [ERROR] Build failed, see messages above.
pause
exit /b 1
