export const options = [
	{
		flag: 'port',
		label: 'Порт управления',
		description: 'Установите порт HTTPS панели Hestia. По умолчанию: 8083. Обязательный параметр!',
		type: 'text',
		required: 'true',
		default: '8083',
	},
	{
		flag: 'lang',
		label: 'Язык интерфейса панели',
		description:
			'Выберите язык веб-интерфейса. Если не выбирать, система будет использовать английский язык по умолчанию.',
		type: 'select',
		default: 'en',
		options: [
			{ label: 'Shqip (Albanian)', value: 'sq' },
			{ label: 'العربية (Arabic)', value: 'ar' },
			{ label: 'Հայերեն (Armenian)', value: 'hy' },
			{ label: 'Azərbaycan (Azerbaijani)', value: 'az' },
			{ label: 'বাংলা (Bengali)', value: 'bn' },
			{ label: 'Bosanski (Bosnian)', value: 'bs' },
			{ label: 'Български (Bulgarian)', value: 'bg' },
			{ label: 'Català (Catalan)', value: 'ca' },
			{ label: 'Hrvatski (Croatian)', value: 'hr' },
			{ label: 'Čeština (Czech)', value: 'cs' },
			{ label: 'Dansk (Danish)', value: 'da' },
			{ label: 'Nederlands (Dutch)', value: 'nl' },
			{ label: 'English', value: 'en' },
			{ label: 'Suomi (Finnish)', value: 'fi' },
			{ label: 'Français (French)', value: 'fr' },
			{ label: 'ქართული (Georgian)', value: 'ka' },
			{ label: 'Deutsch (German)', value: 'de' },
			{ label: 'Ελληνικά (Greek)', value: 'el' },
			{ label: 'Magyar (Hungarian)', value: 'hu' },
			{ label: 'Bahasa Indonesia (Indonesian)', value: 'id' },
			{ label: 'Italiano (Italian)', value: 'it' },
			{ label: '日本語 (Japanese)', value: 'ja' },
			{ label: '한국어 (Korean)', value: 'ko' },
			{ label: 'Kurdî (Sorani Kurdish)', value: 'ku' },
			{ label: 'Norsk (Norwegian)', value: 'no' },
			{ label: 'فارسی (Persian)', value: 'fa' },
			{ label: 'Polski (Polish)', value: 'pl' },
			{ label: 'Português (Portuguese)', value: 'pt' },
			{ label: 'Português do Brasil (Brazilian Portuguese)', value: 'pt-br' },
			{ label: 'Română (Romanian)', value: 'ro' },
			{ label: 'Русский (Russian)', value: 'ru' },
			{ label: 'Српски (Serbian)', value: 'sr' },
			{ label: '简体中文 (Chinese Simplified)', value: 'zh-cn' },
			{ label: 'Slovenčina (Slovak)', value: 'sk' },
			{ label: 'Español (Spanish)', value: 'es' },
			{ label: 'Svenska (Swedish)', value: 'sv' },
			{ label: 'ไทย (Thai)', value: 'th' },
			{ label: '繁體中文 (Chinese Traditional)', value: 'zh-tw' },
			{ label: 'Türkçe (Turkish)', value: 'tr' },
			{ label: 'Українська (Ukrainian)', value: 'uk' },
			{ label: 'اردو (Urdu)', value: 'ur' },
			{ label: 'Tiếng Việt (Vietnamese)', value: 'vi' },
		],
	},
	{
		flag: 'hostname',
		label: 'Имя хоста сервера',
		description:
			'Укажите веб-имя хоста сервера. Следуйте формату: demo.example.com. Обязательный параметр!',
		type: 'text',
		default: '',
	},
	{
		flag: 'email',
		label: 'Электронная почта',
		description:
			'Введите email администратора для уведомлений об异常 конфигурации сервера. Обязательный параметр!',
		type: 'text',
		default: '',
	},
	{
		flag: 'password',
		label: 'Пароль',
		description:
			'Установите пароль для учетной записи администратора. Если не указать, будет сгенерирован случайный пароль.',
		type: 'text',
		default: '',
	},
	{
		flag: 'nopublicip',
		label: 'Принудительно использовать локальный IP',
		description:
			'Использовать внутренний/локальный IP-адрес сервера в качестве адреса привязки, не пытаться получить публичный IP. Подходит для внутренних сетей, NAT-сетей, локальной разработки и тестирования, где не требуется публичный доступ.',
		default: 'no',
	},
	{
		flag: 'apache',
		label: 'Apache2',
		description:
			'Apache2 — мощный, высококонфигурируемый и широко поддерживаемый веб-сервер с открытым исходным кодом. Используется для хостинга веб-сайтов, поддержки веб-приложений, балансировки нагрузки и кэширования.',
		default: 'yes',
	},
	{
		flag: 'phpfpm',
		label: 'PHP-FPM',
		description: 'PHP-FPM — это менеджер процессов FastCGI для выполнения PHP-скриптов.',
		default: 'yes',
	},
	{
		flag: 'multiphp',
		label: 'MultiPHP',
		description:
			'При включении по умолчанию устанавливается PHP 8.2, а также появляется возможность установки нескольких версий PHP 7.4-8.5 в панели. При отключении устанавливается только стандартная версия PHP.',
		default: 'yes',
	},
	{
		flag: 'vsftpd',
		label: 'VSFTPD',
		description:
			'VSFTPD — это безопасный, быстрый и стабильный FTP-сервер. Особенно подходит для Linux-систем. Обеспечивает безопасную и быструю передачу файлов между сервером и пользователями.',
		default: 'yes',
	},
	{
		flag: 'proftpd',
		label: 'ProFTPD',
		description:
			'ProFTPD — это продвинутый модульный FTP-сервер. Поддерживает аутентификацию и авторизацию пользователей через LDAP.',
		default: 'no',
	},
	{
		flag: 'named',
		label: 'BIND',
		description:
			'BIND (Berkeley Internet Name Domain) — популярное DNS-программное обеспечение. Обязательный параметр для серверных кластеров, требующих настройки собственного DNS.',
		default: 'yes',
	},
	{
		flag: 'mysql',
		label: 'MariaDB',
		description:
			'MariaDB — это ветка MySQL, предоставляющая функции, совместимые с MySQL, а также некоторые дополнительные возможности и улучшения.',
		default: 'yes',
	},
	{
		flag: 'mysql-classic',
		label: 'MySQL 8',
		description:
			'MySQL 8 предлагает простоту настройки, управления и масштабирования. Обеспечивает повышенную безопасность, высокую доступность в пределах одного региона или с резервированием и гарантирует 99.99% уровень обслуживания (SLA).',
		default: 'no',
	},
	{
		flag: 'postgresql',
		label: 'PostgreSQL',
		description:
			'PostgreSQL — мощная объектно-реляционная система управления базами данных с открытым исходным кодом. Широко используется в финансовых услугах, обрабатывающей промышленности, розничной торговле, логистике и многих других областях.',
		default: 'no',
	},
	{
		flag: 'exim',
		label: 'Exim',
		description:
			'Exim — это агент передачи сообщений (MTA), используемый для маршрутизации, доставки и приема сообщений электронной почты. Позволяет отправлять электронные письма через SMTP из сети или от локальных программ.',
		default: 'yes',
	},
	{
		flag: 'dovecot',
		label: 'Dovecot',
		description:
			'Dovecot — это серверное программное обеспечение с открытым исходным кодом для IMAP и POP3. Обеспечивает почтовые услуги для Linux-систем. Известен своей безопасностью, простотой использования, скоростью и низким потреблением ресурсов.',
		default: 'yes',
	},
	{
		flag: 'sieve',
		label: 'Правила Sieve',
		description:
			'Включает поддержку правил фильтрации почты (Sieve), позволяя пользователям настраивать автоматическую сортировку, обработку спама, автоматические ответы и другие правила. Требует Dovecot и Exim.',
		default: 'no',
	},
	{
		flag: 'clamav',
		label: 'ClamAV',
		description:
			'ClamAV — это кроссплатформенное программное обеспечение с открытым исходным кодом для обеспечения безопасности электронной почты. Используется для обнаружения вирусов в электронных письмах и других файлах.',
		default: 'yes',
	},
	{
		flag: 'usemirrorclamav',
		label: 'Российское зеркало ClamAV',
		description:
			'Использовать российское зеркало для обновления вирусных баз ClamAV. Подходит для серверов, расположенных в России или соседних регионах, где загрузка с официального источника медленная или нестабильная. Базы будут загружаться с repo.brepo.ru, возможна задержка в несколько часов.',
		default: 'no',
	},
	{
		flag: 'spamassassin',
		label: 'SpamAssassin',
		description:
			'SpamAssassin — это инструмент с открытым исходным кодом для идентификации и фильтрации спама. Он анализирует заголовки, тело и информацию об отправителе письма, применяя ряд правил для оценки того, является ли письмо спамом.',
		default: 'yes',
	},
	{
		flag: 'firewall',
		label: 'Системный брандмауэр',
		description:
			'Использовать firewalld / nftables в качестве системного брандмауэра.<br>\n<br>⚠️ Внимание: Если после установки вы не можете получить доступ к панели через публичный IP (например, доступ только через localhost), это обычно означает, что порт 8083 не открыт в брандмауэре.\n\nРешение:\n\n<pre><code>firewall-cmd --permanent --add-port=8083/tcp\nfirewall-cmd --reload</code></pre>\n\nПри использовании nftables:\n\n<pre><code>nft add rule inet filter input tcp dport 8083 accept</code></pre>\n\nРекомендуется оставить брандмауэр включенным для повышения безопасности, возможна совместная работа с Fail2Ban для защиты от брутфорса.',
		default: 'yes',
	},
	{
		flag: 'bunkerweb',
		label: 'Межсетевой экран WAF Bunkerweb',
		description:
			'Bunkerweb — это межсетевой экран веб-приложений (WAF) с открытым исходным кодом, обеспечивающий защиту на основе основных правил OWASP, черные/белые списки IP, ограничение скорости, HTTP-заголовки безопасности и другие функции безопасности.',
		default: 'no',
	},
	{
		flag: 'uselocalphp',
		label: 'Использовать официальную сборку PHP от Hestia',
		description:
			'Использовать версию PHP из официального репозитория HestiaCP вместо стандартного источника операционной системы. При включении пакеты PHP будут загружаться из репозитория brepo, что обеспечивает единообразие версий и совместимость.',
		default: 'no',
	},
	{
		flag: 'fail2ban',
		label: 'Fail2Ban',
		description:
			'Fail2Ban может автоматически обнаруживать и блокировать пользователей, использующих недействительные данные аутентификации, например, при попытках взлома SSH, FTP и т.д.',
		default: 'yes',
	},
	{
		flag: 'quota',
		label: 'Дисковые квоты',
		description:
			'Установить квоты на дисковое пространство для системных пользователей, ограничивая использование дискового пространства.',
		default: 'no',
	},
	{
		flag: 'api',
		label: 'Hestia API',
		description:
			'Включить внутренний API Hestia, позволяющий другим системам или сервисам взаимодействовать с панелью.',
		default: 'yes',
	},
	{
		flag: 'interactive',
		label: 'Интерактивная установка',
		description:
			'Включить интерактивный режим во время установки, чтобы пользователь мог отвечать на запросы и выбирать опции.',
		default: 'yes',
	},
	{
		flag: 'force',
		label: 'Принудительная установка',
		description:
			'Принудительно перезаписать любые существующие конфигурации и файлы во время установки. В дистрибутивах семейства RHEL рекомендуется включить этот параметр. Перезаписывает конфигурацию администратора по умолчанию.',
		default: 'no',
	},
];
