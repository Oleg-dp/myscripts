@echo off
echo Syncing time with internet time servers...

:: Зупинка служби Windows Time
net stop w32time

:: Синхронізація часу
w32tm /config /manualpeerlist:"time.windows.com,0x1" /syncfromflags:manual /reliable:YES /update

:: Запуск служби Windows Time
net start w32time

:: Перевірка статусу синхронізації
w32tm /query /status

echo Time synchronization completed.
