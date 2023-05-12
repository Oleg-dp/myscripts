@echo on
set IPADDR=%1
set TR_LOG_FILE=%IPADDR%.trace.log
echo *******************************  >> %TR_LOG_FILE%
echo %date% %time:~0,8% >> %TR_LOG_FILE%
tracert -d %IPADDR% >> %TR_LOG_FILE%
echo *******************************  >> %TR_LOG_FILE%
del %2
