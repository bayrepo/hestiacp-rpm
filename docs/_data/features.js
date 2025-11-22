/** @typedef {{ text: string, items?: { text: string }[] }} FeatureListItem */

/** @type {FeatureListItem[]} */
export const users = [
	{ text: 'Поддержка SFTP chroot изоляции' },
	{ text: 'Поддержка двухфакторной авторизации' },
	{ text: 'SSH ключи для входа по SFTP и SSH' },
];

/** @type {FeatureListItem[]} */
export const webDomains = [
	{ text: 'Поддержка Nginx FastCGI кэш Nginx + PHP-FPM' },
	{ text: 'Поддержка Nginx Proxy кэш для Nginx + Apache2' },
	{ text: 'TLS сертификация для каждого веб домена' },
	{ text: 'Поддержка MultiIP для Web/Mail/DNS' },
	{
		text: 'Поддержка MultiPHP',
		items: [
			{ text: "PHP 7.4 (<a href='https://www.php.net/supported-versions.php'>EOL</a>)" },
			{ text: 'PHP 8.0' },
			{ text: 'PHP 8.1' },
			{ text: 'PHP 8.2' },
			{ text: 'PHP 8.3' },
			{ text: 'PHP 8.4' },
			{ text: 'PHP 8.5' },
		],
	},
];

/** @type {FeatureListItem[]} */
export const mail = [
	{
		text: 'Для каждого домена TLS сертификаты для входящей и исходящей почты (Exim 4, Dovecot, Webmail)',
	},
	{ text: 'Настройка ретрансляции SMTP для Exim на случай, если провайдер заблокирует порт 25' },
	{ text: 'Ограничение скорости настраивается для каждого пользователя или учетной записи электронной почты' },
	{ text: 'Поддержка Let’s Encrypt для почтовых доменов' },
	{ text: 'Последняя версия Roundcube' },
	{ text: 'Дополнительная установка SnappyMail' },
];

/** @type {FeatureListItem[]} */
export const dns = [
	{ text: 'Создавайте свои собственные NS' },
	{ text: 'Легкая установка DNS кластера' },
	{ text: 'Поддержка DNSSEC для длменов' },
];

/** @type {FeatureListItem[]} */
export const databases = [
	{ text: 'Поддержка MariaDB 10.2 -> 10.11 с 10.11 по-умолчанию' },
	{ text: 'Поддержка MySQL 8' },
	{ text: 'Поддержка PostgreSQL' },
	{ text: 'Последняя версия phpMyAdmin и phpPgAdmin' },
];

/** @type {FeatureListItem[]} */
export const serverAdmin = [
	{
		text: "Автоматическое резервное копирование на SFTP, FTP и посредством Rclone с 50+ <a href='https://rclone.org/overview/'>Cloud storage providers</a>",
	},
];
