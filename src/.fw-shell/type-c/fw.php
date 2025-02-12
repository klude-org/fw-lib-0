@echo off
setlocal enabledelayedexpansion

:: Extract update content using embedded PHP
php -r "file_put_contents('new_main.bat', file_get_contents('update_source.bat'));" 

:: Create the update script
(
echo @echo off
echo timeout /t 1 /nobreak ^>nul
echo copy /y new_main.bat "%~f0" ^>nul
echo del new_main.bat
echo call "%~f0"
echo del "update.bat"
) > update.bat

:: Run update.bat and exit
call update.bat
exit