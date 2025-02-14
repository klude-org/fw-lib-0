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
if not exist %~dp0.local mkdir %~dp0.local
if not defined FY__SHELL (
    SET FY__SHELL=1
    if not exist "%~dp0.local\.fw.config.bat" (
        echo SET FX__PHP_EXEC_STD_PATH=C:/xampp/current/php/php.exe > "%~dp0.local\.fw.config.bat"
        echo SET FX__PHP_EXEC_XDBG_PATH=C:/xampp/current/php__xdbg/php.exe >> "%~dp0.local\.fw.config.bat"
        echo SET FX__ENV_FILE="%~dp0___set_cli_env_vars__.bat" >> "%~dp0.local\.fw.config.bat"
        echo SET FX__DEBUG=0 >> "%~dp0.local\.fw.config.bat"
        echo SET FW__LIB_SHELL=1 >> "%~dp0.local\.fw.config.bat"
    )
    call %~dp0.local\.fw.config.bat
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
SET PHP_FILE_C=%~dp0--fw\-fw\fw.php
SET PHP_FILE_D=%~dp0.local\.fw.php

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
\define('_\FSESS_DIR', \str_replace('\\','/', \getenv('FW__SESS_DIR') ?: \getcwd()));
(\is_file($f = \_\FSESS_DIR."/.local/.fw.config.php")) AND ($_ = \array_replace($_, \is_array($x = include $f) ? $x : []));

if(
    (\getenv('FW__LIB_SHELL') !== '0')
    && !\str_starts_with($_SERVER['argv'][1] ?? '', "--setup")
    && \is_file($f = __DIR__.'/../--fw/-fw/fw.php')
){
    return include $f;
}
try {
    
    global $_;
    (isset($_) && \is_array($_)) OR $_ = [];
    
    \define('_\BASE_DIR', \str_replace('\\','/', \dirname(__DIR__)));
    \define('_\INCP_DIR', \str_replace('\\','/', \dirname($_SERVER['SCRIPT_FILENAME'])));
    \set_include_path($_['TSP']['PATH'] ?? \_\BASE_DIR.PATH_SEPARATOR.\get_include_path());
    \spl_autoload_extensions('-#.php,/-#.php');
    \spl_autoload_register();
    \set_error_handler(function($severity, $message, $file, $line){
        throw new \ErrorException(
            $message, 
            0,
            $severity, 
            $file, 
            $line
        );
    });
    
    $_REQUEST = (function(){
        $parsed = [];
        $key = null;
        $args = \array_slice($argv = $_SERVER['argv'] ?? [], 1);
        foreach ($args as $arg) {
            if ($key !== null) {
                $parsed[$key] = $arg;
                $key = null;
            } else if(\str_starts_with($arg, '-')){
                if(\str_ends_with($arg, ':')){
                    $key = \substr($arg,0,-1);
                } else if(\str_contains($arg,':')) {
                    [$k, $v] = \explode(':', $arg);
                    $parsed[$k] = $v;
                } else {
                    $parsed[$arg] = true;
                }
            } else {
                $parsed[] = $arg;
            }
        }
        if ($key !== null) {
            $parsed[$key] = true;
        }
        return $parsed;
    })();
    
    if(!\is_null($_REQUEST['--setup'] ?? null)){
        $fn__ = function($fname,...$args){
            return $fname(...$args);
        };
        $dump__fn = function ($d){
            $d = array_diff_key($d, array_flip([
                '_GET','_POST','_SERVER','_FILES','_COOKIE','_ENV',
                'dump__fn','curl__fn','fs_delete__fn','_','f','argv','argc'
            ]));
            echo "\033[97m"
                ."    "
                .\str_replace("\n","\n    ", \json_encode(
                    $d, 
                    JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES
                ))
                .PHP_EOL
                ."\033[0m"
            ;
        };
        $fs_delete__fn = function($d){
            if(\is_dir($d)){
                foreach(new \RecursiveIteratorIterator(
                    new \RecursiveDirectoryIterator($d, \RecursiveDirectoryIterator::SKIP_DOTS)
                    , \RecursiveIteratorIterator::CHILD_FIRST
                ) as $f) {
                    if ($f->isDir()){
                        \rmdir($f->getRealPath());
                    } else {
                        unlink($f->getRealPath());
                    }
                }
                \rmdir($d);
            }
        };
        $curl__fn = function($url, $file = null){
            try{
                $verbose = ($_REQUEST['--verbose'] ?? null) ? true : false;
                if($verbose){
                    echo "Remote: {$url}\n";
                }
                if(!($ch = \curl_init($url))){
                    throw new \Exception("Failed: Unable to initialze curl");
                };
                \curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);  // Follow redirects
                \curl_setopt($ch, CURLOPT_USERAGENT, 'PHP');      // Set User-Agent header to avoid 403
                \curl_setopt($ch, CURLOPT_VERBOSE, $verbose);
                if($file){
                    if(!($fp = \fopen($file, 'w'))){
                        throw new \Exception("Failed: Unable to open tempfile for writing");
                    };
                    \curl_setopt($ch, CURLOPT_FILE, $fp);
                    \curl_exec($ch);
                    if (\curl_errno($ch)) {
                        throw new \Exception("Failed: cURL Error: " . \curl_error($ch));
                    }
                    if(($h = curl_getinfo($ch, CURLINFO_HTTP_CODE)) != 200){
                        \is_file($file) AND unlink($file);
                        throw new \Exception("Failed: Server responded with an {$h} error");
                    }
                    return \is_file($file);
                } else {
                    \curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                    $response = \curl_exec($ch);
                    if (\curl_errno($ch)) {
                        throw new \Exception("Failed: cURL Error: " . \curl_error($ch));
                    }
                    $result = \json_decode($response, true);
                    if (\json_last_error() === JSON_ERROR_NONE) {
                        return $result;
                    } else {
                        throw new \Exception("Json Error Code:(".\json_last_error()."): ".\json_last_error_msg());
                    }
                }
            } catch (\Throwable $ex) {
                if($file && \is_file($file)){
                    \unlink($file);
                }
                throw $ex;
            } finally {
                empty($fp) OR \fclose($fp);
                empty($ch) OR \curl_close($ch);
            }
        };
        $iterator__fn = function($d){
            return new \RecursiveIteratorIterator(
                new \RecursiveDirectoryIterator(
                    $d, 
                    \FilesystemIterator::SKIP_DOTS
                )
            );
        };
        
        $verbose = ($_REQUEST['--verbose'] ?? null) ? true : false;
        $lib_name = '--fw';
        $lib_dir = \_\BASE_DIR."/{$lib_name}";
        $local_dir = \_\BASE_DIR."/.local";
        $install_info_file = "{$lib_dir}/.installed.json";
        $source_slug = "klude-org/fw-lib-0";

        if($_REQUEST['-d'] ?? null){ //delete
            if(!\is_dir($lib_dir)){
                echo "Local: '{$lib_name}' doesn't exist.\n";
            } else {
                $fs_delete__fn($lib_dir);
                echo "Local: '{$lib_name}' was deleted.\n";
            }
            return;
        } else if($_REQUEST['-s'] ?? null){ //stash
            if(!\is_dir($lib_dir)){
                echo "Local: '{$lib_name}' doesn't exist.\n";
            } else {
                $dest_dir = \_\BASE_DIR."/{$lib_name}-stash-".\date('Y-md-Hi-s-').uniqid();
                if(!\rename($lib_dir, $dest_dir)){
                    throw new \Exception("Failed: Unable to modify the '{$lib_name}' directory - it might be in use!!!");
                }
                echo "Local: '{$lib_name}' was renamed to '{$fn__('basename',$dest_dir)}'\n";
            }
            return;
        } else if($_REQUEST['-b'] ?? null){ //backup
            if(!\is_dir($lib_dir)){
                echo "Local: '{$lib_name}' doesn't exist.\n";
            } else {
                $zip_file = \_\BASE_DIR."/.local/{$lib_name}-temp-".uniqid().'.zip';
                $zip = new \ZipArchive; 
                $zip->open($zip_file, \ZipArchive::CREATE | \ZipArchive::OVERWRITE); 
                $l = strlen("{$lib_dir}/");
                foreach(
                    new \RecursiveIteratorIterator(
                        new \RecursiveDirectoryIterator(
                            $lib_dir, 
                            \FilesystemIterator::SKIP_DOTS
                        )
                    ) 
                    as $file
                ){
                    $zip->addFile($file, substr($file, $l));
                } 
                $zip->close();
                $backup_file = \_\BASE_DIR."/.local/{$lib_name}-".\sha1_file($zip_file).\date('-Y-md-Hi-s').'.zip';
                if(!\rename($zip_file, $backup_file)){
                    throw new \Exception("Failed: Unable to modify the '{$lib_name}' directory - it might be in use!!!");
                }
                echo "Local: '{$lib_name}' was backed up to '{$fn__('basename',$backup_file)}'\n";
            }
            return;
        } else if(!\is_null($source_hint = $_REQUEST['-i'] ?? null)){ //install
            $r_host = 'github';
            $r_owner = 'klude-org';
            $r_repo = 'fw-lib-0';
            $r_version = ($source_hint === true) ? '0' : $source_hint;
            $stash_dir = "{$local_dir}/{$lib_name}-stash-".\date('Y-md-Hi-s-').uniqid();
            $pkg_dir = $local_dir.'/temp-'.\uniqid();
            if(\ctype_digit($r_version) || $r_version === '0'){
                if(!($result = $curl__fn("https://api.github.com/repos/{$source_slug}/releases"))){
                    throw new \Exception("Remote: '{$source_slug}' - No Releases Found!\n");
                }
                if(!($v = $result[(int) $r_version]['tag_name'] ?? null)){
                    if($count = \count($result) == 1){
                        echo "{$fn__('count',$result)} release available for '{$source_slug}'\n";
                        echo "index must be 0 (or don't specify a value)\n";
                    } else {
                        echo "{$fn__('count',$result)} releases available for '{$source_slug}'\n";
                        echo "index range 0 - ".($count - 1)."\n";
                    }
                    throw new \Exception("Remote: '{$source_slug}' - Invalid Release Index {$r_version}!\n");
                }
                $r_version = $v;
            }
            $zip_name = 'lib-cache-'.\str_replace('/','][',"[{$r_host}/{$r_owner}/{$r_repo}/{$r_version}]");
            $zip_file = "{$local_dir}/{$zip_name}.zip";
            \is_dir($d = $local_dir) OR \mkdir($d, 0777, true) OR (function($d){ 
                throw new \Exception("Failed: Unable to create directory: $d");
            })($d);
            if(\is_dir($lib_dir) && !\rename($lib_dir, $stash_dir)){
                throw new \Exception("Failed: Unable to modify the '{$lib_name}' directory - it might be in use!!!");
            }
            if(!\is_file($zip_file)){
                if(!$curl__fn(
                    "https://github.com/{$source_slug}/archive/refs/tags/{$r_version}.zip", 
                    $zip_file
                )){
                    echo "\033[91mFailed: Library couldn't be dowloaded\033[0m\n";
                    return;
                }
                echo "Library Downloaded: {$zip_name}\n";
            } else {
                echo "Library Exists: {$zip_name}\n";
            }
            try {
                if (($zip = new \ZipArchive)->open($zip_file) !== true) {
                    throw new \Exception("Failed: Unable to open ZIP file");
                }
                $sub_folder = \substr($s = $zip->getNameIndex(0), 0, \strpos($s, '/'));
                $zip->extractTo($pkg_dir);
                if(\is_dir($x = "{$pkg_dir}/{$sub_folder}/src")){
                    if(\rename($x, $lib_dir)){
                        \file_put_contents($install_info_file,\json_encode(
                            [
                                'host' => $r_host,
                                'owner' => $r_owner,
                                'repo' => $r_repo,
                                'version' => $r_version,
                                'source' => "{$r_host}/{$r_owner}/{$r_repo}/{$r_version}",
                            ],
                            JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES
                        ));
                        echo "\033[92mSelf Updated to {$r_version}.\033[0m\n";
                    } else {
                        throw new \Exception("Failed: Unable to write updates '{$r_version}' to library '{$lib_name}'");
                    }
                } else {
                    throw new \Exception("Failed: The extract doesn't have the folder '{$sub_folder}'");
                }
                $fs_delete__fn($stash_dir);
            } catch (\Throwable $ex){
                if(\is_dir($stash_dir)){
                    \rename($stash_dir, $lib_dir);
                }
                throw $ex;
            } finally {
                if(!empty($pkg_dir) && \is_dir($pkg_dir)){
                    $fs_delete__fn($pkg_dir);
                }
                empty($zip) OR $zip->close();
            }
        } else {
            if(!\is_dir($lib_dir)){
                echo "Local: '{$lib_name}' doesn't exist.\n";
            } else {
                if(
                    !\is_file($install_info_file)
                    || !($source = \json_decode(
                        \file_get_contents($install_info_file),
                        true
                    )['source'] ?? null)
                ) {
                    echo "Local: '{$lib_name}' info is not available.\n";
                } else {
                    
                }
                echo "Local: '{$lib_name}' is from {$source}\n";
            }
            if(!($result = $curl__fn("https://api.github.com/repos/{$source_slug}/tags"))){
                echo "Remote: '{$source_slug}' - No Tags Found!\n";
                return;
            }
            $verbose AND $dump__fn($result);
            echo "Remote: '{$source_slug}' - Available Tags:\n";
            foreach($result as $k => $v){
                echo "- {$v['name']}\n";
            }
            if(!($result = $curl__fn("https://api.github.com/repos/{$source_slug}/releases"))){
                echo "Remote: '{$source_slug}' - No Releases Found!\n";
                return;
            }
            $verbose AND $dump__fn($result);
            echo "Remote: '{$source_slug}' - Available Release Tags:\n";
            foreach($result as $k => $v){
                echo "- {$v['tag_name']}: {$v['name']}\n";
            }
            return;
        }
    } else {
        $intfc = 'fw';
        $path = \trim('__/'.\trim($_REQUEST[0] ?? '', '/'), '/');
        if(
            ($file = \stream_resolve_include_path("{$path}/-@{$intfc}.php"))
            || ($file = \stream_resolve_include_path("{$path}-@{$intfc}.php"))
            || ($file = \stream_resolve_include_path("{$path}/-@.php"))
            || ($file = \stream_resolve_include_path("{$path}-@.php"))
        ){ 
            (function() use($file){
                (function(){
                    foreach(\explode(PATH_SEPARATOR,get_include_path()) as $d){
                        \is_file($f = "{$d}/.functions.php") AND include_once $f;
                    }
                })();
                include $file;
            })->bindTo($GLOBALS['--CTLR'] = (object)['fn' => (object)[]])();
        } else {
            throw new \Exception("Not Found: ".($_REQUEST[0] ?? "/"));
        }
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