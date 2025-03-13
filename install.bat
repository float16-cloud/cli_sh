@echo off
setlocal enabledelayedexpansion

set BINARY_NAME=float16
set VERSION=0.1.0
set BASE_URL=https://float16-cli-executables.s3.ap-southeast-1.amazonaws.com

echo Installing float16 version %VERSION% for Windows...

:: Set installation path
set INSTALL_PATH=%USERPROFILE%\AppData\Local\Programs\%BINARY_NAME%
if not exist "%INSTALL_PATH%" mkdir "%INSTALL_PATH%"

:: Download binary (assuming x86/x64 architecture)
set DOWNLOAD_URL=%BASE_URL%/float16-cli-win-x64-%VERSION%.exe
echo Downloading from: %DOWNLOAD_URL%

:: Try PowerShell first (more reliable), then curl as fallback
powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%INSTALL_PATH%\%BINARY_NAME%.exe' }" 2>nul
if not exist "%INSTALL_PATH%\%BINARY_NAME%.exe" (
    echo PowerShell download failed, trying curl...
    curl -L -o "%INSTALL_PATH%\%BINARY_NAME%.exe" "%DOWNLOAD_URL%"
)

:: Verify the binary exists
if not exist "%INSTALL_PATH%\%BINARY_NAME%.exe" (
    echo Error: Failed to download binary. Please check your internet connection.
    exit /b 1
)

:: Update PATH permanently
echo Adding %INSTALL_PATH% to system PATH...
setx PATH "%PATH%;%INSTALL_PATH%"

echo.
echo Installation complete! 
echo Please restart your command prompt to use the 'float16' command.
echo.
pause 