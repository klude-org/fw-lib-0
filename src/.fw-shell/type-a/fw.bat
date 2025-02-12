::<?php echo "\r   \r"; if(0): ?>
:: #####################################################################################################################
:: #region LICENSE
::     /* 
::                                                EPX-WIN-SHELL
::     PROVIDER : KLUDE PTY LTD
::     PACKAGE  : EPX-PAX
::     AUTHOR   : BRIAN PINTO
::     RELEASED : 2025-02-11
::     
::     The MIT License
::     
::     Copyright (c) 2017-2025 Klude Pty Ltd. https://klude.com.au
::     
::     of this software and associated documentation files (the "Software"), to deal
::     in the Software without restriction, including without limitation the rights
::     to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
::     copies of the Software, and to permit persons to whom the Software is
::     furnished to do so, subject to the following conditions:
::     
::     The above copyright notice and this permission notice shall be included in
::     all copies or substantial portions of the Software.
::     
::     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
::     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
::     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
::     AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
::     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
::     OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
::     THE SOFTWARE.
::         
::     */
:: #endregion
:: # ###################################################################################################################
@echo off
if not defined FY__SHELL (
    SET FY__SHELL=1
    if not exist "%~dp0.fw.config.bat" (
        echo SET FX__PHP_EXEC_STD_PATH=C:/xampp/current/php/php.exe > "%~dp0.fw.config.bat"
        echo SET FX__PHP_EXEC_XDBG_PATH=C:/xampp/current/php__xdbg/php.exe >> "%~dp0.fw.config.bat"
        echo SET FX__ENV_FILE="%~dp0___set_cli_env_vars__.bat" >> "%~dp0.fw.config.bat"
        echo SET FX__DEBUG=0 >> "%~dp0.fw.config.bat"
        echo SET FW__LIB_SHELL=1 >> "%~dp0.fw.config.bat"
    )
    call %~dp0.fw.config.bat
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
SET PHP_FILE_C=%~dp0--fw\-fw\.fw.php
SET PHP_FILE_D=%~dp0--fw\.fw.php

if exist "%CMD_FILE_A%" (
    call %CMD_FILE_B% %*
    goto :L__DONE
) else if exist "%CMD_FILE_B%" (
    call %CMD_FILE_B% %*
    goto :L__DONE
)

if "%FW__LIB_SHELL%" EQU "1" (
    :: Direct call is permitted if it is 1
    if exist "%PHP_FILE_C%" (
        %FW__PHP_EXEC_PATH% "%PHP_FILE_C%" %*
        goto :L__DONE
    ) 
) 

if exist "%PHP_FILE_D%" (
    %FW__PHP_EXEC_PATH% "%PHP_FILE_D%" %*
) else (
    %FW__PHP_EXEC_PATH% "%~f0" %*
)    

:L__DONE
if %ERRORLEVEL%==2 (
    %FW__PHP_EXEC_PATH% "%~f0" %*
) else if exist "%FW__ENV_FILE%" (
    call "%FW__ENV_FILE%"
    del "%FW__ENV_FILE%"
)
  
exit /b 0

<?php endif; 

\defined('_\MSTART') OR \define('_\MSTART', \microtime(true));
if(
    \is_file($fw_dot_php = __DIR__.'/.fw.php')
    && ($_SERVER['argv'][1] ?? null) !== '--self-refresh'
){
    return include $fw_dot_php;
}
try {
    \set_error_handler(function($severity, $message, $file, $line){
        throw new \ErrorException(
            $message, 
            0,
            $severity, 
            $file, 
            $line
        );
    });
    if((function($f){
        if(!($content = \file_get_contents("https://raw.githubusercontent.com/klude-org/fw-lib-0/main/src/.fw-shell/type-a/.fw.php"))){
            echo "\033[91mFailed: Unable to download CLI interface\033[0m\n";
            return; 
        }
        $content = \str_replace(
            '#'.'__FW_INSTALLED__'.'#', 
            \json_encode([
                "source" => "github/klude-org/fw-lib-0/main",
                "installed_on" => \date('Y-m-d H:i:s'),
            ], JSON_UNESCAPED_SLASHES), 
            $content
        );
        \file_put_contents($f, $content);
        echo "\033[92mCLI interface installed successfully\033[0m\n";
        return true;
    })($fw_dot_php)){
        return include $fw_dot_php;
    }
} catch (\Throwable $ex) {
    if($_REQUEST['--verbose'] ?? null){
        echo "\033[91m\n"
            .$ex::class.": {$ex->getMessage()}\n"
            ."File: {$ex->getFile()}\n"
            ."Line: {$ex->getLine()}\n"
            ."\033[31m{$ex}\033[0m\n"
        ;
    } else {
        echo "\033[91m{$ex->getMessage()}\033[0m\n";
    }
}