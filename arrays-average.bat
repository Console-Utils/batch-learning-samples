@echo off
setlocal enabledelayedexpansion
call :init

call :read_integer "Item count: "
set /a count=%result%
call :read_integer_array %count%

for /l %%i in (1, 1, %count%) do set /a array[%%i]=!result[%%i]!

call :print_array %count% array
call :find_average %count% array
set average=%result%
echo average=%average%

pause
exit /b %ec_success%

:init
    set /a "ec_success=0"
    set /a "ec_unknown_error=1"

    set /a "ec_bc_not_found=10"

    cls
    call :set_esc
exit /b %ec_success%

:read_integer
    set "prompt=%~1"

    :read_integer_loop
        set /p "result=%prompt%"
        echo %result%| findstr "^[0-9][0-9]*$ ^+[0-9][0-9]*$ ^-[0-9][0-9]*$" > nul || goto read_integer_loop
exit /b %ec_success%

:read_integer_array
    set /a "count=%~1"
    set "result="

    for /l %%i in (1, 1, %count%) do (
        call :read_integer "Item %%i: "
        set /a result[%%i]=!result!
    )
exit /b %ec_success%

:print_array
    setlocal
    set /a "count=%~1"
    set "arrayName=%~2"

    echo| set /p "=["
    for /l %%i in (1, 1, %count%) do (
        echo| set /p=%ESC%[32m!%arrayName%[%%i]!%ESC%[0m
        if %%i lss %count% echo| set /p "=, "
    )
    echo ]
    endlocal
exit /b %ec_success%

:find_average
    set /a "ec_no_bc_found=10"

    bc --version > nul 2> nul
    if errorlevel 1 (
        echo bc command not found to calculate average >&2
        exit /b %ec_no_bc_found%
    )

    set tmpFile="tmp.txt"

    set /a "count=%~1"
    set "arrayName=%~2"
    set /a "result=0"

    for /l %%i in (1, 1, %count%) do set /a "result=!result! + !%arrayName%[%%i]!"

    echo scale=3; %result% / %count% | bc > "%tmpFile%"
    
    for /f "delims=" %%i in ('type %tmpFile%') do set "result=%%i"
    del "%tmpFile%"
exit /b %ec_success%

:set_esc
    for /f "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
        set "esc=%%b"
        exit /b 0
    )
exit /b %ec_success%
