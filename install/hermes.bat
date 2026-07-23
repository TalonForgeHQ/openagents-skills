@echo off
REM install\hermes.bat — install OpenAgents Skills into Hermes Agent (Windows)
REM Usage: curl -fsSL https://raw.githubusercontent.com/TalonForgeHQ/openagents-skills/main/install/hermes.bat -o install.bat && install.bat
REM Override: set REPO_URL=... and/or BRANCH=... before running

setlocal enabledelayedexpansion

if "%REPO_URL%"=="" set REPO_URL=https://github.com/TalonForgeHQ/openagents-skills
if "%BRANCH%"=="" set BRANCH=main

set DEST=%USERPROFILE%\.hermes\skills

if not exist "%DEST%" mkdir "%DEST%"

echo Installing OpenAgents Skills...
echo   Source: %REPO_URL% @ %BRANCH%
echo   Target: %DEST%

git clone --depth=1 --branch %BRANCH% %REPO_URL% "%TEMP%\openagents-skills-tmp" >nul 2>&1
if errorlevel 1 (
  echo Failed to clone %REPO_URL%
  exit /b 1
)

if not exist "%TEMP%\openagents-skills-tmp\skills" (
  echo Repo layout changed - could not find skills/ directory
  exit /b 1
)

xcopy /E /I /Y "%TEMP%\openagents-skills-tmp\skills\*" "%DEST%\" >nul
if errorlevel 1 (
  echo xcopy failed
  exit /b 1
)

echo Done. Restart any active agent sessions to pick up new skills.
echo Try: 'load the office-hours skill' or 'office-hours this idea'
rd /S /Q "%TEMP%\openagents-skills-tmp" >nul 2>&1
endlocal
