@echo off
set IPADDR=%1

REM Get current date and time
set datetime=%date%_%time%

REM Replace colons with underscores
set datetime=%datetime::=_%

REM Replace slashes with dashes
set datetime=%datetime:/=-%

REM Remove milliseconds if present
set datetime=%datetime:,=%

set TSHARK_LOG=%IPADDR%_%datetime%.tshark.pcap

"C:\Program Files\Wireshark\tshark.exe" -i 8 -a duration:60 -w %TSHARK_LOG%
ipconfig /renew >nul
del %2
exit
