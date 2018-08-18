@echo off
set /p ACTIVE_PROJECT=<%GOTOPATH%\.state\active-project

if %1 == cd (
	cd %2
	goto end
)


python "%GOTOBINPATH%\..\..\the_real_goto.py" "%GOTOPATH%\.state\projects\%ACTIVE_PROJECT%.json" %*

:end 
	rem nothing here.