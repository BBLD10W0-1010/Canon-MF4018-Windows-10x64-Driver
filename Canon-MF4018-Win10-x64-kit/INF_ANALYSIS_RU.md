# Технический разбор INF и зависимостей

## Основной пакет MFDrivers

Официальный установщик: `installers\MF4010_MFDrivers_W64_uk_EN.exe`

Распакованная рабочая папка: `drivers\MF4010_MF4018_MFDrivers_x64`

Состав:

- `x64\Setup.exe` - штатный установщик Canon.
- `x64\Driver\CNLB0KA64.INF` - драйвер печати UFR II LT.
- `x64\Driver\MF31SCN.INF` - драйвер сканера ScanGear/WIA/TWAIN.
- `x64\Driver\ufriilt.cab` - зависимости печати.
- `x64\Driver\scan.cab` - зависимости сканера.
- `x64\Driver\CNLB0K.CAT` и `x64\Driver\MF31SCN.CAT` - каталоги подписи.
- `x64\misc\DelDrv.exe` - официальный деинсталлятор Canon.

## Печать: CNLB0KA64.INF

Ключевые параметры:

```text
Class=Printer
Provider="Canon"
DriverVer=06/26/2007,2.10.0.0
CatalogFile=CNLB0K.CAT
Model="Canon MF4010 Series UFRII LT"
Hardware ID=USBPRINT\CanonMF4010_Series58E4
Source CAB=ufriilt.cab
```

Зависимости печати описаны в секциях `MF4010_FILES`, `UFR2_FILES`, `NETSPOT_CPCA`, `NETSPOT_COMMON`, `PROFILE_MONO` и `PROFILE_MONITOR_HDTV`. Физически они лежат в `ufriilt.cab`; распаковывать CAB вручную не нужно, SetupAPI/установщик Canon берут файлы из CAB.

Каталог `CNLB0K.CAT` проверен как `Valid`, издатель подписи - Microsoft Windows Hardware Compatibility Publisher.

## Сканирование: MF31SCN.INF

Ключевые параметры:

```text
Class=Image
Provider="Canon"
DriverVer=03/20/2007,11.3.0.0
CatalogFile.NTamd64=MF31SCN.CAT
FriendlyName="WIA Canon MF4010 Series"
Hardware ID=USB\VID_04A9&PID_26B4&MI_00
Source CAB=scan.cab
```

INF использует стандартную инфраструктуру Windows Still Image:

```text
Include=sti.inf
Needs=STI.USBSection
SubClass=StillImage
DeviceType=1
```

Также ставится co-installer:

```text
cncilsc.dll,Coinstaller_EntryPoint
```

TWAIN/WIA-компоненты копируются в системные папки и `TWAIN_32\MF4010`; реестр настраивается в ветках Canon ScanGear/WIA. Это объясняет, почему MF Toolbox видит источник как `Canon MF4010 Series`.

Каталог `MF31SCN.CAT` проверен как `Valid`, издатель подписи - Microsoft Windows Hardware Compatibility Publisher.

## MF Toolbox 4.9

Официальный установщик: `installers\ToolBox4911mf18WinEN.exe`

Распакованная рабочая папка: `toolbox\MF_Toolbox_4.9.1.1_mf18`

В `Setup\TBOXCFG.ini` есть список источников сканирования, включая:

```text
12=Canon MF4010 Series
```

Это подтверждает совместимость с источником, который создаёт `MF31SCN.INF`.

Подписи:

- внешний `ToolBox4911mf18WinEN.exe` - Canon Inc., Valid;
- распакованный `Setup.exe` - Canon Inc., Valid;
- `Setup\TBOXCFG.EXE` - NotSigned. Это служебная утилита внутри официального пакета Canon, не отдельный драйвер ядра.

## Опциональный Network/USB Scan Patch

Официальный установщик: `optional\NetworkUSBScanPatchEN.exe`

Назначение по странице Canon: исправление ситуации, когда USB-сканирование не работает после обновления Windows до более новой версии. Canon отдельно предупреждает, что после будущих обновлений Windows патч может потребоваться снова.

Внутри патча есть ветка для MF4010:

```text
UpdateProgram\64bit\DeviceIF\MF4010\CNCLSD31.dll
UpdateProgram\32bit\DeviceIF\MF4010\CNCLSD31.DLL
```

Поэтому патч оставлен в комплекте как совместимый remedial-компонент, но не как обязательный первый шаг. Сначала нужно поставить MFDrivers, перезагрузиться и проверить сканирование.

## Что не изменялось

- INF-файлы не редактировались.
- CAT-файлы не пересоздавались.
- Драйверы не подписывались самодельным сертификатом.
- Никакие исполняемые файлы Canon не патчились.

## Практический вывод

Для Windows 10 x64 основной путь установки:

1. Установщик Canon MFDrivers создаёт принтер `Canon MF4010 Series UFRII LT` и WIA/TWAIN-сканер `WIA Canon MF4010 Series`.
2. MF Toolbox 4.9 использует созданный источник `Canon MF4010 Series`.
3. Если после обновлений Windows USB-сканирование не работает, применяется официальный Canon Network/USB Scan Patch.

На реальном MF4018 визуальное имя MF4010 Series является ожидаемым, а не признаком неправильного драйвера.
