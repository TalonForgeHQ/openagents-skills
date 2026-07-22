@echo off
REM install\hermes.bat — install OpenAgents Skills into Hermes Agent (Windows)
REM Usage: curl -fsSL https://raw.githubusercontent.com/zinou-potts/openagents-skills/main/install/hermes.bat -o install.bat && install.bat

setlocal enabledelayedexpansion

set REPO_URL=https://github.com/zinou-potts/openagents-skills
set BRANCH=main

set DEST=%USERPROFILE%\.hermes\skills

if not exist "%DEST%" mkdir "%DEST%"

git clone --depth=1 --branch %BRANCH% %REPO_URL% "%TEMP%\openagents-skills-tmp" >nul 2>&1
if errorlevel 1 (
  echo Failed to clone %REPO_URL%
  exit /b 1
)

xcopy /E /I /Y "%TEMP%\openagents-skills-tmp\skills\*" "%DEST%\" >nul
echo Installed skills to %DEST%

rmdir /S /Q "%TEMP%\openagents-skills-tmp"
echo Done. Restart any active agent sessions to pick up new skills.
endlocal
