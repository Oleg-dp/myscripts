@echo on
set IP_ADDR=8.8.8.8
set LOG_FILE=%IP_ADDR%tr.log
set LOCK_FILE=%IP_ADDR%tr.lck
set TR_LOCK_FILE=%IP_ADDR%.trace.lock

echo Monitoring %IP_ADDR%...

:monitor
ping -n 1 %IP_ADDR% >nul
if %errorlevel% neq 0 (
    echo %date% %time% %IP_ADDR% is not reachable. >>%LOG_FILE%
    echo lock > %LOCK_FILE%
			if not exist %TR_LOCK_FILE% (
			echo lock > %TR_LOCK_FILE%
			start /B /MIN call trace.cmd %IP_ADDR% %TR_LOCK_FILE%
			) else (
			echo test
			)

    goto monitor
) else (
    	if exist %LOCK_FILE% (
    	echo %date% %time% %IP_ADDR% is reachable. >>%LOG_FILE%
		del /f %LOCK_FILE% > nul
		) else (
    		goto wait
			)
)

:wait
ping -n 11 localhost >nul
goto monitor
