@echo off

REM Install dependencies in the scripts folder
call npm install --prefix scripts

REM Run node script and capture output into NPM_TOKEN
FOR /F "usebackq delims=" %%A IN (`node scripts\gcp-npm-auth.mjs`) DO (
  SET "NPM_TOKEN=%%A"
)

REM Make variable available to child processes
SETLOCAL ENABLEDELAYEDEXPANSION
SET "NPM_TOKEN=!NPM_TOKEN!"

REM Install with pnpm
pnpm install --no-frozen-lockfile