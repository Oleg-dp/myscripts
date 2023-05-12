@echo off
set IP_ADDR=8.8.8.8

:monitor
ping -n 1 %IP_ADDR% >nul
if %errorlevel% neq 0 (
	ipconfig /release
	ipconfig /renew
    goto monitor
) else (
    	goto wait
)

rem :wait
rem ping -n 1 localhost >nul
rem goto monitor
