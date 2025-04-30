@echo off

set "scriptPath=%~f0"
set "scriptDir=%~dp0"
if "%scriptDir:~-1%"=="\" set "scriptDir=%scriptDir:~0,-1%"

REM Store the initial current directory
cd > initial_dir.tmp
set /p "initialDir=" < initial_dir.tmp
del initial_dir.tmp

REM Check for administrative privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Needs administrator permissions
    echo [INFO] Requesting it...
    REM Construct the command to relaunch with elevation
    REM Use PowerShell to request elevation and run the script again
    powershell -Command "Start-Process -Verb RunAs -FilePath \"%scriptPath%\" -WorkingDirectory \"%scriptDir%\" -Wait"
    if %errorlevel% neq 0 (
        echo Failed to elevate. Please run the script as administrator.
        pause
    )
    exit
    REM If the elevated process finishes, change back to the initial directory
    if exist "%scriptDir%" cd /d "%scriptDir%"
    exit
)

if exist "%scriptDir%" cd /d "%scriptDir%"

echo [INFO] Running with administrator permissions

set errormessage=
set pythonpath=
set pippath=pip
rem C:\Users\User\AppData\Local\Programs\Python\Python312\Scripts\pip.exe
mkdir setupfiles
chcp 1200 > nul

echo [INFO] Checking internet connection
Ping www.google.nl -n 1 -w 1000 >NUL 2>&1
if errorlevel 1 (
	set errormessage=[ERROR] No internet connected
	goto error
) else (
	echo [INFO] Internet connected
)

echo [INFO] Checking for python installations
where python > nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] Found python at:
    where python
    python --version > nul 2>&1
    if errorlevel 1 (
        echo [WARNING] Python appears to be installed, but the 'python' command is not working correctly.
        echo [WARNING] This might indicate an Microsoft false positive app execution alias or issues with your PATH.
        goto python_system
    )
) ELSE (
    echo [INFO] Python NOT found in PATH
    echo [INFO] Starting installation
    goto python_system
)

:python_packages
echo [INFO] Enable long paths
powershell New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force >NUL 2>&1

echo [INFO] Generating venv
%pythonpath% -m venv files\.venv

echo [INFO] Activating venv
call files\.venv\Scripts\activate.bat

echo [INFO] Installing packages
%pippath% install -r files\requirements.txt >NUL 2>&1

echo [INFO] Everything installed. Have fun!

echo [INFO] Cleaning up
rd /s /q setupfiles
goto eof

:python_system
echo [INFO] Downloading userwide python
curl https://www.python.org/ftp/python/3.12.9/python-3.12.9-amd64.exe -o setupfiles\python-3.12.9.exe >NUL 2>&1
echo [INFO] Installing python. Please be patient...
start /wait setupfiles\python-3.12.9.exe /passive /quiet
set pythonpath=%LocalAppData%\Programs\Python\Python312\python.exe
rem FOR /F "tokens=*" %%g IN ('where pip') do (set pippath=%%g)
echo [INFO] Python installed
goto python_packages

:error
echo %errormessage%

:eof
pause