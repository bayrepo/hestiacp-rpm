# Приступая к работе

Этот раздел поможет вам установить Hestia на ваш сервер. Если Hestia уже установлена и вы просто ищете дополнительные возможности, вы можете пропустить эту страницу.

::: warning
Установщик необходимо запустить как **root**, либо напрямую из терминала, либо удаленно, используя SSH. Если вы этого не сделаете, установщик не продолжит работу.
:::

## Требования

::: warning
Hestia необходимо установить поверх новой установки операционной системы, чтобы обеспечить надлежащую функциональность.
Если на VPS/KVM уже есть учетная запись администратора, либо удалите этот идентификатор администратора по умолчанию, либо используйте `--force`, чтобы продолжить установку. Дополнительные сведения см. в разделе «Выборочная установка» ниже.
:::

| Компонент                                | Минимум                                                  | Рекомендуется                                          |
| :--------------------------------------- | :------------------------------------------------------- | :----------------------------------------------------- |
| **ЦП**                                   | 1 ядро, 64-разрядный                                     | 4 ядра                                                 |
| **Память**                               | 1 ГБ (без SpamAssassin и ClamAV)                         | 4 ГБ                                                   |
| **Диск**                                 | 10 ГБ HDD                                                | 40 ГБ SSD                                              |
| **Операционная система (Debian/Ubuntu)** | Debian 11, 12, 13 LTS <br>Ubuntu 22.04, 24.04, 26.04 LTS | Последняя версия Debian<br>Последняя версия Ubuntu LTS |
| **Операционная система (RPM)**           | MSVSphere 9<br>AlmaLinux 9<br>Rocky Linux 9              | MSVSphere 10<br>Rocky Linux 10<br>AlmaLinux 10         |

::: warning
Hestia работает только на процессорах AMD64 / x86_64 и ARM64 / aarch64. Также требуется 64-разрядная операционная система!

В настоящее время мы не поддерживаем процессоры на базе i386 или ARM7.
:::

### Поддерживаемые операционные системы

- MSVSphere 9,10
- AlmaLinux 9,10
- Rocky Linux 9,10

## Обычная установка

Интерактивный установщик, который установит конфигурацию программного обеспечения Hestia по умолчанию.

### Шаг 1: Загрузка

Загрузите скрипт установки для последней версии:

```bash
wget https://dev.brepo.ru/bayrepo/hestiacp/raw/branch/master/install/hst-install.sh
```

Если загрузка не удалась из-за ошибки проверки SSL, убедитесь, что вы установили пакет ca-certificate в своей системе — это можно сделать с помощью следующей команды:

```bash
yum install ca-certificates
```

### Шаг 2: Запуск

Чтобы начать процесс установки, просто запустите скрипт и следуйте инструкциям на экране:

```bash
bash hst-install.sh
```

Вы получите приветственное письмо по адресу, указанному во время установки (если применимо), а также инструкции на экране после завершения установки, чтобы войти в систему и получить доступ к вашему серверу.

## Выборочная установка

Если вы хотите настроить, какое программное обеспечение будет установлено, или хотите запустить автоматическую установку, вам нужно будет запустить выборочную установку.

Чтобы просмотреть список доступных параметров, запустите

```bash
bash hst-install.sh -h
```

### Список параметров установки

::: tip
Проще всего выбрать параметры установки с помощью [генератора строк установки](/install.md).
:::

Чтобы выбрать, какое программное обеспечение будет установлено, вы можете указать флаги в скрипте установки. Полный список параметров можно просмотреть ниже.

```bash
-a, --apache Install Apache [yes | no] default: yes
-w, --phpfpm Install PHP-FPM [yes | no] default: yes
-o, --multiphp Install Multi-PHP [yes | no] default: no
-v, --vsftpd Install Vsftpd [yes | no] default: yes
-j, --proftpd Install ProFTPD [yes | no] default: no
-k, --named Install Bind [yes | no] default: yes
-m, --mysql Install MariaDB [yes | no] default: yes
-M, --mysql-classic Install MySQL 8 [yes | no] default: no
-g, --postgresql Install PostgreSQL [yes | no] default: no
-x, --exim Install Exim [yes | no] default: yes
-z, --dovecot Install Dovecot [yes | no] default: yes
-Z, --sieve Install Sieve [yes | no] default: no
-c, --clamav Install ClamAV [yes | no] default: no
-t, --spamassassin Install SpamAssassin [yes | no] default: yes
-i, --firewall Install firewalld [yes | no] default: yes
-b, --fail2ban Install Fail2ban [yes | no] default: yes
-q, --quota Filesystem Quota [yes | no] default: no
-d, --api Activate API [yes | no] default: yes
-r, --port Change Backend Port default: 8083
-l, --lang Default language default: en
-y, --interactive Interactive install [yes | no] default: yes
-I, --nopublicip Use local ip [yes | no] default: no
-u, --uselocalphp Use PHP from local repo [yes | no] default: no
-C, --usemirrorclamav Use mirrored clamav [yes | no] default: no
-s, --hostname Set hostname
-e, --email Set admin email
-p, --password Set admin password
-R, --with-rpms Path to Hestia rpms
-f, --force Force installation
-h, --help Print this help
```

#### Пример

```bash
bash hst-install.sh \
	--interactive no \
	--hostname host.domain.tld \
	--email email@domain.tld \
	--password p4ssw0rd \
	--lang ru \
	--apache no \
	--named no \
	--clamav no \
	--spamassassin no
```

Эта команда установит Hestia на русском с такой конфигурацией:

- Nginx веб сервер
- PHP-FPM сервер приложений
- MariaDB база данных
- IPtables фаервол + Fail2Ban
- Vsftpd FTP сервер
- Exim почтовый сервер
- Dovecot POP3/IMAP сервер

## Что дальше?

К настоящему моменту у вас должна быть установлена ​​Hestia на вашем сервере. Вы готовы добавлять новых пользователей, чтобы вы (или они) могли добавлять новые веб-сайты на вашем сервере.

Чтобы получить доступ к панели управления, перейдите по адресу `https://host.domain.tld:8083` или `http://your.public.ip.address:8083`

## Расширенные опции RPM версии

Данная реадкция HestiaCP RPM Edition включает дополнительные оции такие как:

- `-I, --nopublicip` - если установлена данная опция, то установщик панели не получает внешний IP адрес сервера, где контрольная панель устанавливается (на случай если ваш сервер за NAT). Данную опцию можно включать, если у вас на сервере публичный IP или необходима внутрисетевая установка без внешнего доступа.

- `-u, --uselocalphp` - включить установку пакетов PHP из того-же репозитория, откуда ставится HestiaCP RPM Edition. Если не включать данную опцию, то PHP пакеты будут установлены из репозитория Remi. Если включить, то будет произведена так называемая установка локальных пакетов. Есть отличия в способе упаковке Local PHP и Remi PHP. Если сервера требуется расширенный набор PHP из Remi репозитория, то данную опцию лучше отключить, т.е задать `--uselocalphp no`. Local PHP более простая сборка с меньшим числом поддерживаемых модулей PHP, но подходит для большинства конфигураций CMS и имеет [страницу настройки подключаемых модулей](/docs/extensions/local-php.md)
