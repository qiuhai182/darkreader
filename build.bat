@echo off

python convert_to_utf8.py

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
echo (Task logs stream below; dots = still running)

rem Run the build via a PowerShell wrapper: child output streams to the
rem console in real time, with a heartbeat dot printed every 0.9 seconds.
set "NPMARG=build"
if /i "%MODE%"=="debug" set "NPMARG=debug"
powershell -NoProfile -Command "$p=Start-Process npm.cmd -ArgumentList 'run','%NPMARG%' -NoNewWindow -PassThru; $null=$p.Handle; while(!$p.HasExited){Start-Sleep -Milliseconds 900; Write-Host -NoNewline '.'}; $p.WaitForExit(); exit $p.ExitCode"
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
