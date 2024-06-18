# Schedule-Switch
Скрипт для запуска приложения в указанный промежуток времени
================================================================
Roman Ermakov <r.ermakov@emg.fm>

v1.00 2024-06-18 Первая версия.

### Задача:

Запускать указанное целевое приложение с параметрами в указанный промежуток времени и автоматически закрывать его в любое другое время, если оно запущено. 

### Правила выполнения:

Используем термины *"день"* и *"ночь"*.

Приложение будет запускаться, если определена *"ночь"*. Промежуток разрешённого запуска задаётся в переменных `$day` и `$night`.<br>
*"Ночью"* также считаются выходные дни и дополнительные выходные дни, переопределённые в переменной `$daysoff`.<br>
Дополнительные рабочие дни, которые считаются *"днём"*, переопределяются в переменной `$dayson`.

Например, если `$day = 0800` и `$night=2030`, целевое приложение будет запускаться между 20:30 и 8:00.<br>
Если целевое приложение в этот промежуток времени уже запущено, повторно запускаться оно не будет.

В промежуток между 8:00 и 20:30 приложение запускаться не будет.<br>
Если целевое приложение в этот промежуток уже запущено, оно будет принудительно закрываться.

Полный путь к приложению указывается в переменной `$path`.<br>
Полный путь к файлу, который это приложение должно открыть, указывается в переменной `$conf`.

*Например*, при `$path = "$env:SYSTEMROOT\System32\notepad.exe"` и `$conf = "$env:SYSTEMROOT\WindowsUpdate.txt"` скрипт будет запускать Блокнот и открывать в нём файл C:\WINDOWS\WindowsUpdate.txt

Переменная `$proc` содержит имя процесса целевого приложения, который скрипт будет принудительно закрывать, если определил *"день"*.


### Использование в Windows Scheduler

Скрипт написан на Powershell. Для неотвлекающего запуска скрипта из Планировщика Заданий в качестве команды нужно указать `%comspec%` . В качестве аргумента для этой команды нужно указать `/c start /min "" powershell -NonInteractive -WindowStyle hidden -File %PROGRAMDATA%\Microsoft\NM\Schedule-Switch.ps1` , где в аргументе -File указан путь к скрипту.