@echo off
setlocal enabledelayedexpansion

if "%~1"=="/?" (
    call :show_help
    exit /b 0
)

if "%~3"=="" (
    echo Error: Not enough parameters
    call :show_help
    exit /b 1
)

set "DIRECTORY=%~1"
set "FROM_ENCODING=%~2"
set "TO_ENCODING=%~3"

if not exist "%DIRECTORY%" (
    echo Error: Directory "%DIRECTORY%" does not exist
    exit /b 1
)

call :check_encoding "%FROM_ENCODING%"
if errorlevel 1 (
    echo Error: Invalid source encoding "%FROM_ENCODING%"
    exit /b 1
)

call :check_encoding "%TO_ENCODING%"
if errorlevel 1 (
    echo Error: Invalid target encoding "%TO_ENCODING%"
    exit /b 1
)

where iconv >nul 2>&1
if errorlevel 1 (
    echo Error: iconv program not found in system
    echo Install Coreutils for Windows
    exit /b 1
)

echo Starting conversion from %FROM_ENCODING% to %TO_ENCODING%
echo Directory: %DIRECTORY%
echo REPLACING source files
echo.

set "FILE_COUNT=0"
set "ERROR_COUNT=0"

for /r "%DIRECTORY%" %%f in (*.txt *.xml *.html *.htm *.csv *.ini *.cfg *.log) do (
    call :convert_file "%%f" "%%~ff"
)

echo.
echo Conversion completed
echo Files processed: !FILE_COUNT!
if !ERROR_COUNT! neq 0 (
    echo Files with errors: !ERROR_COUNT!
)
exit /b 0

:show_help
echo Usage:
echo   enconvert.cmd /?
echo     - show this help
echo.
echo   enconvert.cmd directory from_encoding to_encoding
echo     - convert all files in directory with REPLACEMENT of source files
echo.
echo Parameters:
echo   directory     - directory to process
echo   from_encoding - source encoding
echo   to_encoding   - target encoding
echo.
echo Supported encodings: ascii, cp866, koi8, utf8, utf16
echo.
echo WARNING: Source files will be replaced!
echo.
echo Example:
echo   enconvert.cmd C:\MyFiles cp866 utf8
exit /b 0

:check_encoding
set "ENC=%~1"
if "%ENC%"=="ascii" exit /b 0
if "%ENC%"=="cp866" exit /b 0
if "%ENC%"=="koi8" exit /b 0
if "%ENC%"=="utf8" exit /b 0
if "%ENC%"=="utf16" exit /b 0
exit /b 1

:convert_file
set "INPUT_FILE=%~1"
set "FULL_PATH=%~2"

call :get_iconv_encoding "%FROM_ENCODING%" "ICONV_FROM"
call :get_iconv_encoding "%TO_ENCODING%" "ICONV_TO"

:generate_temp
set "TEMP_FILE=%TEMP%\iconv_temp_%RANDOM%_%TIME::=_%.tmp"
if exist "!TEMP_FILE!" goto generate_temp

echo Converting: !INPUT_FILE!
iconv -f !ICONV_FROM! -t !ICONV_TO! "!INPUT_FILE!" > "!TEMP_FILE!" 2>&1

if !errorlevel! neq 0 (
    echo Conversion error: !INPUT_FILE!
    echo   Command: iconv -f !ICONV_FROM! -t !ICONV_TO!
    set /a ERROR_COUNT+=1
    goto :cleanup_temp
)

if not exist "!TEMP_FILE!" (
    echo Error: Temporary file not created for !INPUT_FILE!
    set /a ERROR_COUNT+=1
    goto :cleanup_temp
)

for %%A in ("!TEMP_FILE!") do set "TEMP_SIZE=%%~zA"
if "!TEMP_SIZE!"=="0" (
    echo Error: Temporary file is empty for !INPUT_FILE!
    set /a ERROR_COUNT+=1
    goto :cleanup_temp
)

move /y "!TEMP_FILE!" "!INPUT_FILE!" >nul 2>&1

if !errorlevel! neq 0 (
    echo File replacement error: !INPUT_FILE!
    set /a ERROR_COUNT+=1
    goto :cleanup_temp
) else (
    echo Success: !INPUT_FILE!
    set /a FILE_COUNT+=1
)

:cleanup_temp
if exist "!TEMP_FILE!" del "!TEMP_FILE!" >nul 2>&1
exit /b 0

:get_iconv_encoding
set "USER_ENC=%~1"
set "RESULT_VAR=%~2"

if "!USER_ENC!"=="ascii" set "!RESULT_VAR!=ASCII"
if "!USER_ENC!"=="cp866" set "!RESULT_VAR!=CP866"
if "!USER_ENC!"=="koi8" set "!RESULT_VAR!=KOI8-R"
if "!USER_ENC!"=="utf8" set "!RESULT_VAR!=UTF-8"
if "!USER_ENC!"=="utf16" set "!RESULT_VAR!=UTF-16"

exit /b 0