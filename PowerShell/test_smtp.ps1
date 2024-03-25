# Встановлення параметрів електронної пошти
$EmailFrom = "your_email@example.com"
$EmailTo = "recipient@example.com"
$Subject = "Test Subj"
$Body = "test"
$SMTPServer = "smtp.example.com"
$SMTPPort = 587
$Username = "your_email@example.com"
$Password = "your_password"

$secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($Username, $secpasswd)

# Ігнорувати сертіфікат, якщо треба
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

# Створення об'єкта поштового повідомлення
$SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom, $EmailTo, $Subject, $Body)

# Налаштування аутентифікації SMTP
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, $SMTPPort)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = $credential

# Відправка електронної пошти
$SMTPClient.Send($SMTPMessage)
