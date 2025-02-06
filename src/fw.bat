::<?php echo "\r   \r"; if(0): ?>
@echo off
if not defined FY__SHELL (
    SET FY__SHELL=1
    :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    :: DEFAULT SETTINGS
    SET FX__PHP_EXEC_STD_PATH=C:/xampp/current/php/php.exe
    SET FX__PHP_EXEC_XDBG_PATH=C:/xampp/current/php__xdbg/php.exe
    SET FX__ENV_FILE="%USERPROFILE%\___set_cli_env_vars__.bat"
    SET FX__DEBUG=1
    cmd /k
    exit /b 0
)


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: SESSION
goto :L__START
:getGUID
for /f "tokens=2 delims==" %%a in ('wmic os get localdatetime /value') do set dt=%%a
set "%~1=%dt:~0,8%-%dt:~8,4%-%dt:~12,2%%dt:~15,3%-%dt:~6,2%%dt:~8,2%%dt:~10,2%-%dt:~15,3%%dt:~12,2%%dt:~6,2%"
exit /b
:L__START

if not defined FX__SESSION (
    call :getGUID FX__SESSION
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: FW__PHP_EXEC_PATH
if "%FX__DEBUG%" NEQ "" (
    SET FW__PHP_EXEC_PATH=%FX__PHP_EXEC_XDBG_PATH%
) else (
    SET FW__PHP_EXEC_PATH=%FX__PHP_EXEC_STD_PATH%
)

if NOT exist %FW__PHP_EXEC_PATH% (
    SET FW__PHP_EXEC_PATH=php.exe
)

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: FW__ENV_FILE
if defined FW__ENV_FILE (
    SET "FW__ENV_FILE=%FX__ENV_FILE%"
)

if not defined FW__MY_DIR (
    SET "FW__MY_DIR=%~dp0"
)


SET CMD_FILE_A=%~dp0--fw\-cmd\__\%1\-@fw.bat
SET CMD_FILE_B=%~dp0--fw\-cmd\__\%1-@fw.bat

if exist "%CMD_FILE_A%" (
    call %CMD_FILE_B% %*
) else if exist "%CMD_FILE_B%" (
    call %CMD_FILE_B% %*
) else (
    %FW__PHP_EXEC_PATH% "%~f0" %*
)

if %ERRORLEVEL%==2 (
    pause
) else if exist "%FW__ENV_FILE%" (
    call "%FW__ENV_FILE%"
    del "%FW__ENV_FILE%"
)
  
exit /b 0

<?php endif; 

include 'fw.php';
