# ASX Hub

<div align="center">
  <a href="https://github.com/ALFiX01/ASX_Hub">
    <img src="https://github.com/ALFiX01/ASX_Hub/blob/main/Files/Images/design.png?raw=true" alt="ASX Hub Logo Banner" >
  </a>

  <br />

  <p><strong>Один хаб для полной настройки — легко, чётко, под тебя.</strong></p>

  <p>
    <a href="https://github.com/ALFiX01/ASX-Hub/releases/latest"><img src="https://img.shields.io/github/v/release/ALFiX01/ASX-Hub?style=for-the-badge" alt="GitHub Release"></a>
    <a href="https://github.com/ALFiX01/ASX-Hub/commits/main"><img src="https://img.shields.io/github/last-commit/ALFiX01/ASX-Hub?style=for-the-badge" alt="GitHub Last Commit"></a>
    <a href="https://github.com/ALFiX01/ASX-Hub/stargazers"><img src="https://img.shields.io/github/stars/ALFiX01/ASX-Hub?style=for-the-badge" alt="GitHub Stars"></a>
    <a href="https://github.com/ALFiX01/ASX-Hub/releases"><img src="https://img.shields.io/github/downloads/ALFiX01/ASX-Hub/total?style=for-the-badge" alt="GitHub all Downloads"></a>
    <a href="https://github.com/ALFiX01/ASX-Hub/releases"><img src="https://img.shields.io/github/downloads/ALFiX01/ASX-Hub/ASX.Hub.exe?style=for-the-badge" alt="GitHub EXE Downloads"></a>
  </p>
</div>

---

## ⚠️ Важное предупреждение об антивирусах

> **ASX Hub** изменяет настройки системы через реестр на основе выбранных пользователем параметров.  
> Эти действия могут быть распознаны антивирусами как подозрительная активность, несмотря на полное отсутствие вредоносного кода.

### Как поступить?

1. **Добавьте ASX Hub в исключения**  
   - [Скачайте ASX-Hub.exe](https://github.com/ALFiX01/ASX-Hub/releases/latest/download/ASX.Hub.exe).
   - Отключите антивирус на время установки.
   - Добавьте папку `<Системный диск>:\ASX` в список исключений вашего антивируса.
   - После запуска и входа в главное меню ASX Hub антивирус можно снова включить.

2. **Не используйте программу**, если у вас есть сомнения или вы не доверяете исходному коду.
   
---

## 🧠 Что такое ASX Hub?

**ASX Hub** — это удобная утилита для настройки, оптимизации и кастомизации Windows. Все нужные инструменты собраны в одном месте — больше не нужно устанавливать десятки программ, чтобы получить полный контроль над своей системой.

---

![Скриншот главного меню ASX Hub](https://github.com/ALFiX01/ASX_Hub/blob/main/Files/Images/MainMenu.png?raw=true)

---

## ✨ Основные возможности

- ⚙️ **Тонкая настройка системы**: ускорение загрузки, отзывчивость, твики производительности.
- 🛡️ **Контроль конфиденциальности**: отключение телеметрии, трекинга и прочих элементов слежки.
- 🖱️ **Редактор контекстного меню**: полное управление пунктами ПКМ Проводника.
- 🎨 **Визуальная кастомизация**: настройка внешнего вида Windows под себя.
- ⏱️ **Управление службами**: просмотр, отключение и управление автозагрузкой системных служб.
- 📦 **Автоустановка софта**: быстрая установка популярных приложений из встроенного списка.
- 🛠️ **Системные утилиты**: очистка, диспетчер автозагрузки, тестовые инструменты.
- 🔄 **ASX Revert** — система отката:
  - Создание точки восстановления.
  - Бэкап служб и важных веток реестра.
  - Восстановление после изменений.

---

## ⚠️ Важно: отказ от ответственности

> **ASX Hub** взаимодействует с системными компонентами Windows. Все действия выполняются **на ваш страх и риск**.

Перед использованием:
- Создайте точку восстановления или используйте **ASX Revert**.
- Ознакомьтесь с каждым твиком — большинство опций необратимы без бэкапа.
- Программа безопасна, но неправильное применение может привести к сбоям.

📖 [Как создать точку восстановления](https://support.microsoft.com/ru-ru/help/12415/windows-10-recovery-options)

---

## 🖥️ Системные требования

- **ОС:** Windows 10 / 11 (x64 рекомендуется)
- **Права администратора:** обязательны
- **Интернет:** требуется для обновлений и загрузки компонентов

---

## 🚀 Быстрый старт

### ✅ Установка

#### Способ 1: EXE-файл

1. Перейди на [страницу релизов](https://github.com/ALFiX01/ASX-Hub/releases/latest)
2. Скачай `ASX_Hub.exe` и помести его в удобное место

#### Способ 2: PowerShell (альтернатива)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://bit.ly/ASX-Hub'))
