# WindowsSystemInfo.ps1
# Остання більш повна версія скрипта

# Примусове використання TLS 1.2 та старіших протоколів
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor `
                                                  [Net.SecurityProtocolType]::Tls11 -bor `
                                                  [Net.SecurityProtocolType]::Tls

# Параметри для Telegram
$TelegramToken = "YOUR_TELEGRAM_BOT_TOKEN"  # Замініть на ваш Telegram токен
$ChatID = "YOUR_CHAT_ID"  # Замініть на ваш Chat ID

# Функція для надсилання повідомлення в Telegram
function Send-TelegramMessage {
    param (
        [string]$Message
    )

    $Url = "https://api.telegram.org/bot$TelegramToken/sendMessage"
    $Body = @{
        chat_id    = $ChatID
        text       = $Message
        parse_mode = 'Markdown'
    }

    try {
        $JsonBody = $Body | ConvertTo-Json -Depth 4 -Compress

        $Response = Invoke-RestMethod -Uri $Url -Method Post -ContentType "application/json; charset=utf-8" -Body $JsonBody
        Write-Host "Повідомлення надіслано в Telegram."
    }
    catch {
        Write-Host "Помилка при надсиланні повідомлення в Telegram: $_"
    }
}

# 1. Отримання завантаження процесора та пам'яті
$CPU = Get-WmiObject win32_processor | Measure-Object -property LoadPercentage -Average | Select-Object -ExpandProperty Average
$CPUUsage = "Завантаження CPU: {0}%" -f $CPU

$Mem = Get-WmiObject win32_OperatingSystem
$TotalMem = [math]::Round($Mem.TotalVisibleMemorySize/1KB,2)
$FreeMem = [math]::Round($Mem.FreePhysicalMemory/1KB,2)
$UsedMem = $TotalMem - $FreeMem
$MemUsage = "Використання пам'яті: $UsedMem МБ з $TotalMem МБ"

# 2. Події в журналі Windows (останніх 5 помилок)
$SystemErrors = Get-EventLog -LogName System -EntryType Error -Newest 5 | Select-Object TimeGenerated, Source, EventID, Message

$SystemErrorsFormatted = $SystemErrors | ForEach-Object {
    $message = $_.Message.Split("`n")[0]
    # Обмежуємо довжину повідомлення, щоб уникнути перевищення ліміту Telegram
    if ($message.Length -gt 100) { $message = $message.Substring(0, 100) + "..." }
    "[{0}] {1} (EventID: {2}): {3}" -f $_.TimeGenerated.ToString("yyyy-MM-dd HH:mm:ss"), $_.Source, $_.EventID, $message
}

# 5. Перевірка наявності оновлень Windows
$Session = New-Object -ComObject Microsoft.Update.Session
$Searcher = $Session.CreateUpdateSearcher()
$Updates = $Searcher.Search("IsInstalled=0 and Type='Software'").Updates
$UpdatesCount = $Updates.Count
$UpdatesStatus = "Доступно оновлень Windows: $UpdatesCount"

# 10. Перевірка підключених користувачів
$Users = query user | Select-Object -Skip 1
$ActiveUsers = $Users | ForEach-Object {
    $line = ($_ -replace '\s{2,}', '|').Trim()
    $fields = $line -split '\|'
    if ($fields.Length -ge 6) {
        $userName = $fields[0]
        $sessionName = $fields[1]
        $sessionId = $fields[2]
        $state = $fields[3]
        $idleTime = $fields[4]
        $logonTime = $fields[5]
        "Користувач: $userName, Сесія: $sessionName, Час входу: $logonTime"
    }
}

# Отримання Uptime
$Uptime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
$UptimeDays = (New-TimeSpan -Start $Uptime -End (Get-Date)).Days
$UptimeFormatted = "Час роботи системи: $UptimeDays днів"

# Отримання дати останнього встановлення оновлень
$LastUpdate = (Get-HotFix | Where-Object { $_.InstalledOn -ne $null } | Sort-Object InstalledOn -Descending | Select-Object -First 1).InstalledOn
$LastUpdateFormatted = "Останнє встановлене оновлення: $LastUpdate"

# Перевірка вільного місця на диску
$DiskSpace = Get-PSDrive -PSProvider FileSystem | ForEach-Object {
    "$($_.Name): $([math]::round($_.Free/1GB,2)) ГБ вільно з $([math]::round(($_.Used + $_.Free)/1GB,2)) ГБ"
}

# Формування звіту
$ReportLines = @()
$ReportLines += "*Системний звіт:*"
$ReportLines += $UptimeFormatted
$ReportLines += $LastUpdateFormatted
$ReportLines += ($DiskSpace -join "`n")
$ReportLines += ""
$ReportLines += $CPUUsage
$ReportLines += $MemUsage
$ReportLines += ""
$ReportLines += "*Останні системні помилки:*"
if ($SystemErrorsFormatted) {
    $ReportLines += ($SystemErrorsFormatted -join "`n")
} else {
    $ReportLines += "Немає критичних помилок."
}
$ReportLines += ""
$ReportLines += $UpdatesStatus
$ReportLines += ""
$ReportLines += "*Активні користувачі:*"
if ($ActiveUsers) {
    $ReportLines += ($ActiveUsers -join "`n")
} else {
    $ReportLines += "Немає активних користувачів."
}

$Report = $ReportLines -join "`n"

# Надсилання звіту
Send-TelegramMessage -Message $Report
