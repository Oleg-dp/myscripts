@echo off
rem set IP_ADDR=8.8.8.8
rem Kyivstar DNS
set IP_ADDR=193.41.60.11
set LOG_FILE=%IP_ADDR%-renew.log
set LOCK_FILE=%IP_ADDR%-renew.lck

echo Monitoring %IP_ADDR%... %date% %time:~0,8%

:monitor

ping -n 1 %IP_ADDR% >nul
if %errorlevel% neq 0 (
    if exist %LOCK_FILE% goto monitor
    echo lock > %LOCK_FILE%
    echo %date% %time:~0,8% %IP_ADDR% is not reachable. >>%LOG_FILE%	
	ipconfig /release >nul
	ipconfig /renew >nul
	echo Monitoring %IP_ADDR%... %date% %time:~0,8%
    goto monitor
) else (
    	if exist %LOCK_FILE% (
    	echo %date% %time:~0,8% %IP_ADDR% is reachable. >>%LOG_FILE%
		del /f %LOCK_FILE% >nul
		) else (
    		goto wait
			)
)

:wait
ping -n 10 localhost >nul
goto monitor
