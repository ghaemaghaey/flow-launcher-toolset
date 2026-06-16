@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Flow Launcher Toolset Installer
color 0A

set "ROOT=%~dp0"
for %%I in ("%ROOT%.") do set "ROOT=%%~fI"
set "TARGET=%APPDATA%\FlowLauncher\Plugins"
set "TEXTTOOLS=%ROOT%\TextTools"
set "RASMIO=%ROOT%\rasmio_tool"

cls
echo ================================================
echo   Flow Launcher Toolset Installer
echo ================================================
echo.
echo Source : %ROOT%
echo Target : %TARGET%
echo.
echo This will copy the plugins and delete the repository folder afterward.
choice /c YN /m "Proceed with installation?"
if errorlevel 2 (
    echo Installation cancelled.
    exit /b 1
)

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
set "CLEANUP_SCRIPT=%TEMP%\flow_launcher_toolset_cleanup.cmd"
set "CLEANUP_MARKER=%ROOT%\installer.lock"
set "CLEANUP_NAME_RETRY_LIMIT=10"
> "%CLEANUP_MARKER%" echo cleanup
set /a CLEANUP_NAME_RETRIES=0
:cleanup_name_check
if exist "%CLEANUP_SCRIPT%" (
    set /a CLEANUP_NAME_RETRIES+=1
    if !CLEANUP_NAME_RETRIES! geq !CLEANUP_NAME_RETRY_LIMIT! (
        echo Failed to prepare the cleanup script in %TEMP%. Please clear temporary installer files and try again.
        exit /b 1
    )
    set "CLEANUP_SCRIPT=%TEMP%\flow_launcher_toolset_cleanup_%RANDOM%.cmd"
    goto cleanup_name_check
)
(
    echo @echo off
    echo setlocal EnableExtensions EnableDelayedExpansion
    echo set "FAIL_REASON="
    echo set "CLEANUP_RETRY_LIMIT=5"
    echo set "CLEANUP_RETRY_DELAY=1"
    echo if not exist "%ROOT%\install.cmd" if not defined FAIL_REASON set "FAIL_REASON=missing install.cmd"
    echo if not exist "%ROOT%\README.md" if not defined FAIL_REASON set "FAIL_REASON=missing README.md"
    echo if not exist "%ROOT%\TextTools" if not defined FAIL_REASON set "FAIL_REASON=missing TextTools"
    echo if not exist "%ROOT%\rasmio_tool" if not defined FAIL_REASON set "FAIL_REASON=missing rasmio_tool"
    echo if not exist "%CLEANUP_MARKER%" if not defined FAIL_REASON set "FAIL_REASON=missing install marker"
    echo if defined FAIL_REASON goto cleanup_fail
    echo set /a RETRIES=0
    echo :cleanup_try
    echo rmdir /s /q "%ROOT%" 2^>nul
    echo if not exist "%ROOT%" goto cleanup_finish
    echo set /a RETRIES+=1
    echo if ^!RETRIES^! geq ^!CLEANUP_RETRY_LIMIT^! goto cleanup_finish
    echo timeout /t ^!CLEANUP_RETRY_DELAY^! /nobreak ^>nul
    echo goto cleanup_try
    echo :cleanup_fail
    echo echo Cleanup skipped: ^!FAIL_REASON^!
    echo goto cleanup_finish
    echo :cleanup_finish
    echo del "%%~f0"
) > "%CLEANUP_SCRIPT%"
cd /d "%TEMP%" >nul
start "" /min cmd /c call "%CLEANUP_SCRIPT%"
echo Cleanup started in the background.
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
