<div align="center">

# [Панель управления Hestia (RPM версия)](https://hestiadocs.brepo.ru)

![Скриншот веб-интерфейса HestiaCP](./docs/public/images/demo.png)

## Легкая и мощная серверная панель для современных веб-сред

**Стабильная версия:** 1.9.5 (RPM) |
[RPM версия](https://hestiadocs.brepo.ru) |
[Оригинальный проект для Ubuntu/Debian](https://hestiacp.com) |
[История изменений](/CHANGELOG.md) |
[Форум поддержки](https://forum.hestiacp.com)
<br><br>
[![Статус сборки Drone](https://drone.hestiacp.com/api/badges/hestiacp/hestiacp/status.svg?ref=refs/heads/main)](https://drone.hestiacp.com/hestiacp/hestiacp)
[![Статус проверки кода](https://github.com/hestiacp/hestiacp/actions/workflows/lint.yml/badge.svg)](https://github.com/hestiacp/hestiacp/actions/workflows/lint.yml)
[![Техподдержка](https://img.shields.io/badge/Gurubase-Обсуждение_на_английском_в_форуме_Hestia-006BFF)](https://gurubase.io/g/hestia)

</div>

## [English](README.en.md)

## [Deutsch](README.de.md)

## [Español](README.es.md)

## [हिन्दी](README.hi.md)

## [日本語](README.ja.md)

## [简体中文](README.zh-Hans.md)

## [繁體中文](README.zh-Hant.md)

Панель управления Hestia (RPM версия) разрабатывается и поддерживается независимой командой, специализирующейся на RPM-ориентированных дистрибутивах. После ответвления от оригинального проекта данная версия включает изменения, которые не позволяют синхронизировать обновления с Ubuntu/Debian версией (некоторые функции не применимы к RPM-системам). Пожалуйста, сообщайте о проблемах непосредственно в этот проект.

Ниже представлено общее описание панели.

## **Добро пожаловать!**

Hestia Control Panel предоставляет администраторам простой веб-интерфейс и CLI-инструменты для быстрого развертывания доменов, почтовых аккаунтов, DNS-зон и баз данных через централизованную панель без ручной настройки отдельных компонентов.

## Функционал и сервисы

- Apache2 и NGINX с PHP-FPM
- Поддержка нескольких версий PHP (7.4[EOL](https://www.php.net/supported-versions.php)-8.3, по умолчанию 8.2 из репозитория Remi + кастомные сборки)
- DNS-сервер (Bind)
- Почтовый сервис с антивирусом/антиспамом и веб-почтой (POP/IMAP/SMTP, ClamAV, SpamAssassin, Sieve, Roundcube)
- Базы данных MariaDB/MySQL и PostgreSQL
- Поддержка SSL Let's Encrypt
- Фаервол с защитой от брутфорса и IP-менеджментом (iptables, fail2ban, ipset)

## Поддерживаемые системы

- **MSVSphere:** 9
- **AlmaLinux:** 9
- **RockyLinux:** 9

**Важно:**

- HestiaCP не поддерживает 32-битные ОС!
- На OpenVZ 7 и старых версиях возможны проблемы с DNS/фаерволом. Рекомендуем KVM/LXC-виртуализацию.

## Установка Hestia

- **Примечание:** Для корректной работы устанавливайте на чистую ОС.

Требуются базовые знания администрирования Linux-серверов.

### Шаг 1: Авторизация

Войдите как **root** через SSH:

```bash
ssh root@ваш.сервер
```

### Шаг 2: Загрузка

Получите установочный скрипт:

```bash
wget https://dev.brepo.ru/bayrepo/hestiacp/raw/branch/master/install/hst-install.sh
```

### Шаг 3: Запуск

Выполните скрипт и следуйте инструкциям:

```bash
bash hst-install.sh
```

После установки вы получите приветственное письмо и данные для входа.

### Кастомная установка

Используйте параметры для выбора компонентов:

```bash
bash hst-install.sh -h
```

## Обновление системы

Автообновления включены по умолчанию (управление: **Настройки сервера > Обновления**). Ручное обновление:

```bash
dnf update
```

## Поддержка и отчеты

- Проблемы с RPM-версией: [GitHub Issues](https://github.com/bayrepo/hestiacp-rpm/issues)
- Оригинальная версия: [Репозиторий проекта](https://github.com/hestiacp/hestiacp)

## Авторские права

Оригинальный код: [HestiaCP](https://github.com/hestiacp/hestiacp)

## Лицензия

Распространяется под лицензией [GPL v3](https://github.com/hestiacp/hestiacp/blob/release/LICENSE), основан на [VestaCP](https://vestacp.com/).
