@echo off
setlocal enabledelayedexpansion

set yaml_file_path=%1
set build_number=%2

(for /f "delims=" %%i in (%yaml_file_path%) do (
    set line=%%i
    echo !line:latest=%build_number%!
)) > %yaml_file_path%.tmp

move /Y %yaml_file_path%.tmp %yaml_file_path%
