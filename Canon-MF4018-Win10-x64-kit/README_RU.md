# Canon i-SENSYS MF4018 для Windows 10 x64

Рабочий офлайн-комплект для печати и сканирования Canon i-SENSYS MF4018 на Windows 10 64-bit.

Комплект собран из официальных пакетов Canon без изменения INF/CAT/EXE и без фиктивной подписи. В Windows устройство может отображаться как **Canon MF4010 Series**: это нормально, Canon распространяет MF4018 в общем legacy-пакете MF4010/MF4018.

## Что внутри

- `installers\MF4010_MFDrivers_W64_uk_EN.exe` - официальный Canon MFDrivers V2.10: печать UFRII LT + ScanGear/WIA/TWAIN.
- `drivers\MF4010_MF4018_MFDrivers_x64\x64\Setup.exe` - уже распакованный установщик драйверов.
- `toolbox\MF_Toolbox_4.9.1.1_mf18\Setup.exe` - Canon MF Toolbox 4.9 для удобного сканирования в файл/PDF/приложение.
- `optional\NetworkUSBScanPatchEN.exe` - официальный Canon patch для USB-сканирования после обновлений Windows; использовать только если сканирование не заработало после базовой установки.
- `scripts\01_Verify-Package.ps1` - проверка SHA256, цифровых подписей и ожидаемых INF-маркеров.
- `INF_ANALYSIS_RU.md` - технический разбор INF, зависимостей и ограничений.

## Проверенные контрольные суммы

```text
C5E0C5800DE336A886D3A00666C6FE63349F806C56D4C5760C7CCFC2914A89AA  installers\MF4010_MFDrivers_W64_uk_EN.exe
D4C4C8BEE96308A5F572CB46061C97CE2DCA5209ABC569B81241C36DC4FBE37F  installers\ToolBox4911mf18WinEN.exe
4D55A4A3E3F5A130BC7A9CCFC5F72F91EDF71646E99EFE25E959FC74157E973F  optional\NetworkUSBScanPatchEN.exe
```

Цифровые подписи проверены 14.09.2026:

- `MF4010_MFDrivers_W64_uk_EN.exe` - Canon Inc., Valid.
- `CNLB0K.CAT` и `MF31SCN.CAT` - Microsoft Windows Hardware Compatibility Publisher, Valid.
- `ToolBox4911mf18WinEN.exe` и распакованный `Setup.exe` - Canon Inc., Valid.
- `NetworkUSBScanPatchEN.exe` - Canon Inc., Valid.

Примечание: внутри MF Toolbox есть служебный файл `TBOXCFG.EXE` без отдельной подписи. Он находится внутри официального подписанного установщика Canon; это зафиксировано как предупреждение, а не скрыто.

## Перед установкой

1. Войдите под администратором.
2. Отключите USB-кабель MF4018 от компьютера.
3. Желательно создать точку восстановления Windows.
4. Не отключайте проверку подписи драйверов заранее. Сначала пробуйте обычную установку: CAT-файлы драйверов в этом комплекте подписаны Microsoft WHCP.
5. Подключайте МФУ напрямую к USB-порту компьютера, без USB-хаба.

## Рекомендуемая установка

1. Откройте PowerShell в папке комплекта и выполните проверку:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\01_Verify-Package.ps1
```

2. Запустите установку драйверов:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\02_Start_MFDrivers_Setup.ps1
```

В мастере Canon выберите установку по USB. Держите USB-кабель отключенным, пока мастер не попросит подключить устройство; затем подключите MF4018 и включите питание.

3. Перезагрузите Windows именно через **Restart / Перезагрузка**, не через выключение.

4. Установите MF Toolbox:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\03_Start_MF_Toolbox_Setup.ps1
```

5. Проверьте печать: **Settings -> Devices -> Printers & scanners -> Canon MF4010 Series UFRII LT -> Manage -> Print a test page**.

6. Проверьте сканирование:

- запустите **Canon MF Toolbox 4.9**;
- выберите источник **Canon MF4010 Series**;
- для первого теста используйте 300 dpi и обычное сохранение в файл/PDF.

7. Если печать работает, но сканер не виден или USB-сканирование падает после обновления Windows, перезагрузите Windows и запустите опциональный патч:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\04_Start_Optional_Scan_Patch.ps1
```

После патча снова выполните **Restart / Перезагрузка**.

## Ручная установка через INF, если мастер Canon не сработал

Для печати:

1. Откройте **Printers & scanners -> Add device -> Add manually**.
2. Выберите локальный/USB-принтер и порт USB.
3. Нажмите **Have Disk**.
4. Укажите файл:

```text
drivers\MF4010_MF4018_MFDrivers_x64\x64\Driver\CNLB0KA64.INF
```

5. Выберите **Canon MF4010 Series UFRII LT**.

Для сканера:

1. Откройте **Device Manager**.
2. Найдите неизвестное устройство/сканер Canon.
3. **Update driver -> Browse my computer**.
4. Укажите папку:

```text
drivers\MF4010_MF4018_MFDrivers_x64\x64\Driver
```

Сканер должен появиться как **WIA Canon MF4010 Series**. Если ручной сценарий не привязал USB-порт или WIA-устройство, возвращайтесь к `Setup.exe`: старый Canon-мастер лучше обрабатывает USB-установку этой линейки.

## Откат

1. Отключите USB-кабель MF4018.
2. Удалите **Canon MF Toolbox 4.9** через **Apps & features** или **Programs and Features**.
3. Запустите официальный деинсталлятор драйверов:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\90_Start_Canon_Driver_Uninstaller.ps1
```

4. В **Printers & scanners** удалите оставшийся принтер Canon, если он ещё отображается.
5. В **Device Manager** удалите **WIA Canon MF4010 Series** или неизвестное устройство Canon. Если Windows предложит удалить программное обеспечение драйвера, подтвердите.
6. Если драйвер печати остался в системе: откройте `printui /s /t2`, выберите **Canon MF4010 Series UFRII LT** и удалите пакет драйвера.
7. Для совсем упорного случая используйте `pnputil /enum-drivers`, найдите `CNLB0KA64.INF` или `MF31SCN.INF`, затем удалите только соответствующий `oemXX.inf`:

```powershell
pnputil /delete-driver oemXX.inf /uninstall /force
```

8. Перезагрузите Windows.

## Риски и ограничения

- Это legacy-драйвер: сами INF датированы 2007 годом и изначально описаны Canon для XP/Vista x64. Canon/Microsoft-каталог всё ещё связывает этот пакет с Windows 10 x64, но работа зависит от конкретной сборки Windows 10 и политики подписи в системе.
- Не используйте изменённые INF и самодельную подпись. В этом комплекте INF не менялись, а CAT-файлы валидны.
- Если корпоративная политика/Secure Boot/обновление Windows блокирует установку, безопаснее сначала попробовать чистый откат и установку заново. Отключение проверки подписи - крайний временный шаг и снижает защиту системы.
- Сканирование рассчитано на USB. MF Toolbox и ScanGear старые: не запускайте две программы сканирования одновременно, а для больших сканов на 600 dpi нужно много свободного места.
- После крупных обновлений Windows 10 USB-сканирование может снова сломаться; в этом случае Canon рекомендует повторно применить scan patch.
- Комплект предназначен для личного использования с вашим устройством Canon. Не распространяйте его как публичный архив: лицензия Canon ограничивает передачу ПО третьим лицам.

## Источники

- Canon Europe support page for i-SENSYS MF4018: `https://www.canon-europe.com/support/consumer/products/printers/i-sensys/mf-series/i-sensys-mf4018.html`
- Official MFDrivers URL from Canon server: `https://gdlp01.c-wss.com/gds/5/0100004725/03/MF4010_MFDrivers_W64_uk_EN.exe`
- Canon support page for MF Toolbox 4.9.1.1.mf18: `https://ph.canon/en/support/0200155904`
- Official MF Toolbox URL from Canon server: `https://gdlp01.c-wss.com/gds/9/0200001559/08/ToolBox4911mf18WinEN.exe`
- Canon support page for Network/USB Scan Patch: `https://asia.canon/en/support/0100765702`
- Official scan patch URL from Canon server: `https://gdlp01.c-wss.com/gds/7/0100007657/02/NetworkUSBScanPatchEN.exe`
