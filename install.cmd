@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Flow Launcher Toolset Installer
color 0A

set "ROOT=%~dp0"
for %%I in ("%ROOT%.") do set "ROOT=%%~fI"
set "TARGET=%APPDATA%\FlowLauncher\Plugins"
set "TEXTTOOLS=%ROOT%TextTools"
set "RASMIO=%ROOT%rasmio_tool"

cls
echo ================================================
echo   Flow Launcher Toolset Installer
echo ================================================
echo.
echo Source : %ROOT%
echo Target : %TARGET%
echo.

if not exist "%TEXTTOOLS%" goto missing_source
if not exist "%RASMIO%" goto missing_source

if not exist "%TARGET%" (
    mkdir "%TARGET%" >nul 2>&1
    if errorlevel 1 goto target_error
)

echo Copying TextTools...
robocopy "%TEXTTOOLS%" "%TARGET%\TextTools" /E /NFL /NDL /NJH /NJS /NP /R:1 /W:1 >nul
if errorlevel 8 goto copy_error

echo Copying rasmio_tool...
robocopy "%RASMIO%" "%TARGET%\rasmio_tool" /E /NFL /NDL /NJH /NJS /NP /R:1 /W:1 >nul
if errorlevel 8 goto copy_error

echo.
echo Install complete.
echo Cleaning up the cloned folder...
start "" /b cmd /c "timeout /t 2 /nobreak >nul & rmdir /s /q ""%ROOT%"""
echo Done.
exit /b 0

:missing_source
echo Required folders were not found.
echo Run this installer from the repository root.
exit /b 1

:target_error
echo Failed to create the Flow Launcher plugins folder.
exit /b 1

:copy_error
echo Copy failed.
exit /b 1
