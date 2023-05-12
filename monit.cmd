@echo off
set IP_ADDR=8.8.8.8
set LOG_FILE=%IP_ADDR%.log
set LOCK_FILE=%IP_ADDR%.lck
rem set TR_LOG_FILE=%IP_ADDR%.trace.log

echo Monitoring %IP_ADDR%...

:monitor
ping -n 1 %IP_ADDR% >nul
if %errorlevel% neq 0 (
    echo %date% %time:~0,8% %IP_ADDR% is not reachable. >>%LOG_FILE%
    echo lock > %LOCK_FILE%
    goto monitor
) else (
    	if exist %LOCK_FILE% (
    	echo %date% %time:~0,8% %IP_ADDR% is reachable. >>%LOG_FILE%
	del /f %LOCK_FILE% > nul
	) else (
    	goto wait
	)
)

:wait
ping -n 1 localhost >nul
goto monitor
