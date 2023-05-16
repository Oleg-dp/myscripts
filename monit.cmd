@echo off
rem Kyivstar DNS
set IP_ADDR=193.41.60.11
set LOG_FILE=%IP_ADDR%.log
set LOCK_FILE=%IP_ADDR%.lck
rem set TR_LOG_FILE=%IP_ADDR%.trace.log

echo Monitoring %IP_ADDR%... %date% %time:~0,8%

:monitor
ping -n 1 %IP_ADDR% >nul
if %errorlevel% neq 0 (
    if exist %LOCK_FILE% goto monitor
    echo %date% %time:~0,8% %IP_ADDR% is not reachable. >>%LOG_FILE%
    echo lock > %LOCK_FILE%
    echo %date% %time:~0,8% %IP_ADDR% is not reachable.
    goto monitor
) else (
    	if exist %LOCK_FILE% (
    	echo %date% %time:~0,8% %IP_ADDR% is reachable. >>%LOG_FILE%
    	echo %date% %time:~0,8% %IP_ADDR% is reachable. 
	del /f %LOCK_FILE% > nul
	) else (
    	goto wait
	)
)

:wait
ping -n 10 localhost >nul
goto monitor
