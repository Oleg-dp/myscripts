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

$Report = $ReportLines -join "`n"

# Надсилання звіту
Send-TelegramMessage -Message $Report
