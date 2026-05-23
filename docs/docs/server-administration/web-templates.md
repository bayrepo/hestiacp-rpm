# Веб-шаблоны и кэш FastCGI/Proxy

## Как работают веб-шаблоны?

::: warning
Изменение шаблонов может вызвать ошибки на сервере и привести к тому, что некоторые службы не смогут перезагрузиться или запуститься.
:::

Каждый раз, когда вы перестраиваете пользователя или домен, файлы конфигурации домена перезаписываются новыми шаблонами.

Это происходит, когда:

- HestiaCP обновляется.
- Администратор инициирует это.
- Пользователь изменяет настройки.

Шаблоны можно найти в `/usr/local/hestia/data/templates/web/`.

| Служба | Расположение |
| ----------------------- | ----------------------------------------------------- |
| Nginx (Proxy) | /usr/local/hestia/data/templates/web/nginx/ |
| Nginx - PHP FPM | /usr/local/hestia/data/templates/web/nginx/php-fpm/ |
| Apache2 (Legacy/modphp) | /usr/local/hestia/data/templates/web/apache2/ |
| Apache2 - PHP FPM | /usr/local/hestia/data/templates/web/apache2/php-fpm/ |
| PHP-FPM | /usr/local/hestia/data/templates/web/php-fpm/ |

::: warning
Избегайте изменения шаблонов по умолчанию, так как они перезаписываются обновлениями. Чтобы этого не произошло, скопируйте их:

```bash
cp original.tpl new.tpl
cp original.stpl new.stpl
cp original.sh new.sh
```

:::

Завершив редактирование шаблона, включите его для нужного домена в панели управления.

После изменения существующего шаблона необходимо перестроить конфигурацию пользователя. Это можно сделать с помощью команды [v-rebuild-user](../reference/cli.md#v-rebuild-user) или массовой операции в веб-интерфейсе..

### Доступные переменные

| Имя | Описание | Пример |
| -------------------- | ----------------------------------------------------- | ------------------------------------------ |
| `%ip%` | IP-адрес сервера | `123.123.123.123` |
| `%proxy_port%` | Порт прокси | `80` |
| `%proxy_port_ssl%` | Порт прокси (SSL) | `443` |
| `%web_port%` | Порт веб-сервера | `8080` |
| `%web_ssl_port%` | Порт веб-сервера (SSL) | `8443` |
| `%domain%` | Домен | `domain.tld` |
| `%domain_idn%` | Домен (интернационализированный) | `domain.tld` |
| `%alias_idn%` | Псевдоним домена (интернационализированный) | `alias.domain.tld` |
| `%docroot%` | Корневой каталог документов домена | `/home/username/web/public_html/` |
| `%sdocroot%` | Частный корень домена | `/home/username/web/public_shtml/` |
| `%ssl_pem%` | Расположение SSL-сертификата | `/usr/local/hestia/data/user/username/ssl` |
| `%ssl_key%` | Расположение SSL-ключа | `/usr/local/hestia/data/user/username/ssl` |
| `%web_system%` | Программное обеспечение, используемое в качестве веб-сервера | `Nginx` |
| `%home%` | Домашний каталог по умолчанию | `/home` |
| `%user%` | Имя текущего пользователя | `username` |
| `%backend_lsnr%` | Ваш сервер FPM по умолчанию | `proxy:fcgi://127.0.0.1:9000` |
| `%proxy_extentions%` | Расширения, которые должен обрабатывать прокси-сервер | Список расширений |

::: tip
`%sdocroot%` также можно установить на `%docroot%` с помощью настроек
:::

## Как изменить настройки для определенного домена

С переходом на PHP-FPM в настоящее время есть 2 разных способа:

1. С помощью `.user.ini` в домашнем каталоге `/home/user/web/domain.tld/public_html`.
2. Через конфигурацию пула PHP-FPM.

Шаблоны конфигурации для пула PHP можно найти в `/usr/local/hestia/data/templates/web/php-fpm/`.

::: warning
Поскольку мы используем несколько PHP, нам необходимо распознавать используемую версию PHP. Поэтому мы используем следующую схему именования: `YOURNAME-PHP-X_Y.tpl`, где X_Y — ваша версия PHP.

Например, шаблон PHP 8.1 будет `YOURNAME-PHP-8_1.tpl`.
:::

## Установка модулей PHP

```bash
dnf install php-package-name
```

Например, следующая команда установит `php-memcached` и `php-redis`, включая необходимые дополнительные пакеты для PHP.

```bash
dnf install php-memcached php-redis
```

## Nginx FastCGI Cache

::: tip
FastCGI применяется только для сервера Nginx + PHP-FPM. Если вы используете Nginx + Apache2 + PHP-FPM, это к вам не применимо!
:::

Кэш FastCGI — это опция в Nginx, позволяющая кэшировать вывод FastCGI (в данном случае PHP). Он временно создаст файл с содержимым вывода. Если другой пользователь запрашивает ту же страницу, Nginx проверит, действителен ли возраст кэшированного файла, и если да, то отправит кэшированный файл пользователю, вместо того чтобы запрашивать его в FastCGI.

Кэш FastCGI лучше всего подходит для сайтов, получающих много запросов и страницы которых не так часто меняются, например, новостной сайт. Для более динамичных сайтов могут потребоваться изменения в конфигурации или полное его отключение.

### Как включить кэш FastCGI для моего пользовательского шаблона

Найдите блок, в котором вы вызываете `fastcgi_pass`:

```bash
location ~ [^/]\.php(/|$) {
fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
try_files $uri =404;
fastcgi_pass %backend_lsnr%;
fastcgi_index index.php;
include /usr/local/hestia/nginx-system/usr/local/hestia/nginx-system/usr/local/hestia/nginx-system/usr/local/hestia/nginx-system/usr/local/hestia/nginx-system/usr/local/hestia/nginx-system/usr/local/hestia/nginx-system/usr/local/hestia/nginx-system/usr/local/hestia/nginx-system/usr/local/hestia/nginx-system/etc/nginx/fastcgi_params;
}
```

Добавьте следующие строки под `include /usr/local/hestia/nginx-system/usr/local/hestia/nginx-system/etc/nginx/fastcgi_params;`:

```bash
include %home%/%user%/conf/web/%domain%/nginx.fastcgi_cache.conf*;

if ($request_uri ~* "/path/with/exceptions/regex/whatever") {
set $no_cache 1;
}
```

### Как очистить кэш?

Когда включен кэш FastCGI, на страницу **Изменить** веб-домена добавляется кнопка **<i class="fas fa-fw fa-trash"></i> Очистить кэш Nginx**. Вы также можете использовать API или следующую команду:

```bash
v-purge-nginx-cache user domain.tld
```

### Почему у меня нет возможности использовать кэш FastCGI

Кэш FastCGI доступен только для режима Nginx. Если вы используете Nginx + Apache2, вы можете выбрать шаблон кэширования прокси, и кэш прокси будет включен. Функционально это почти то же самое. Фактически, кэширование прокси также будет работать, если вы используете образ Docker или приложение Node.js.

Для написания пользовательских шаблонов кэширования используйте следующую схему именования:

`caching-yourname.tpl`, `caching-yourname.stpl` и `caching-yourname.sh`

### Поддерживает ли Hestia поддержку веб-сокетов

Да, Hestia отлично работает с веб-сокетами, однако наши шаблоны по умолчанию включают по умолчанию:

```bash
proxy_hide_header Upgrade
```

Это решило проблему с загрузкой веб-сайтов Safari.

Чтобы разрешить использование веб-сокетов, удалите эту строку. В противном случае веб-сокеты работать не будут