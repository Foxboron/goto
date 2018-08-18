@echo off

rem the goto statement below is the builtin CMD statement, it must not be confused with
rem the real goto. If you insist on using CMD as your main terminal,
rem a problem is that goto is a reserved name. in CMD this projects goto will be
rem shortened down to 'gt'
rem in all other terminals (powershell, iTerm, bash, sh, etc) - goto will be used.

goto check_Permissions


:check_Permissions
    echo Administrative permissions required. Detecting permissions...

    net session >nul 2>&1
    if %errorLevel% == 0 (
        echo Success: Administrative permissions confirmed.
        goto setup_goto
    ) else (
        echo Failure: You need to run this as admin.
        exit
    )


:setup_goto
	echo Setting up environment variables (GOTOPATH)
	setx GOTOPATH "%APPDATA%\goto"
	setx GOTOBINPATH "%cd%\bin\win"

	echo Adding bins
	mklink %GOTOBINPATH%\gt.bat %GOTOBINPATH%\goto.bat 

	echo setting active project
	echo goto>"%GOTOPATH%\.state\active-project"

	rem echo setting up symbolic links to bin
	rem mklink /D %GOTOPATH%\bin %cd%\bin\win

	echo .
	echo .
	echo Now add two things to your path:
	echo 	add %%GOTOPATH%% to your user %%PATH%% environment variable.
	echo 	add %%GOTOBINPATH%% to your user %%PATH%% environment variable.


