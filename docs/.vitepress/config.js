import { defineConfig } from "vitepress";
import { version } from "../../package.json";

export default defineConfig({
  lang: "en-US",
  title: "Hestia Control Panel",
  description: "Open-source web server control panel.",

  lastUpdated: true,
  cleanUrls: false,

  head: [
    ["link", { rel: "icon", sizes: "any", href: "/favicon.ico" }],
    [
      "link",
      { rel: "icon", type: "image/svg+xml", sizes: "16x16", href: "/logo.svg" },
    ],
    [
      "link",
      {
        rel: "apple-touch-icon",
        sizes: "180x180",
        href: "/apple-touch-icon.png",
      },
    ],
    ["link", { rel: "manifest", href: "/site.webmanifest" }],
    ["meta", { name: "theme-color", content: "#b7236a" }],
  ],

  themeConfig: {
    logo: "/logo.svg",

    nav: nav(),

    socialLinks: [
      { icon: "github", link: "https://dev.brepo.ru/bayrepo/hestiacp" },
      { icon: "github", link: "https://github.com/bayrepo/hestiacp-rpm" },
      { icon: "github", link: "https://github.com/hestiacp/hestiacp" },
    ],

    sidebar: { "/docs/": sidebarDocs() },

    outline: [2, 3],

    footer: {
      message: "Выпущена под лицензией GPLv3.",
      copyright:
        "Copyright © 2019-present Hestia Control Panel и некоторые RPM based компоненты принадлежат bayrepo",
    },

    search: {
      provider: "local",
      options: {
        placeholder: "Поиск по документации",
        minMatchCharLength: 1,
        threshold: 0.2,
        distance: 5000,
        keys: ["title", "content", "headers"],
        tokenize: (text) => {
          const tokens = [];
          const chineseChars = text.match(/[\u4e00-\u9fa5]/g) || [];
          const englishWords = text.match(/[a-zA-Z0-9]+/g) || [];
          return [...chineseChars, ...englishWords];
        },
        translations: {
          button: { buttonText: "Поиск по документации" },
          modal: {
            noResultsText: "Ничего не найдено",
            resetButtonTitle: "Сбросить поиск",
            footer: {
              selectText: "выбрать",
              navigateText: "переключить",
              closeText: "закрыть",
            },
          },
        },
      },
    },
  },
});

/** @returns {import("vitepress").DefaultTheme.NavItem[]} */
function nav() {
  return [
    { text: "Характеристики", link: "/features.md" },
    { text: "Установка", link: "/install.md" },
    {
      text: "Документация",
      link: "/docs/introduction/getting-started.md",
      activeMatch: "/docs/",
    },
    { text: "Разработчики", link: "/team.md" },
    {
      text: `v${version}`,
      items: [
        {
          text: "Changelog",
          link: "https://dev.brepo.ru/bayrepo/hestiacp/src/branch/master/CHANGELOG.md",
        },
        {
          text: "Содействие в разработке",
          link: "https://dev.brepo.ru/bayrepo/hestiacp/src/branch/master/CONTRIBUTING.md",
        },
        {
          text: "Политика безопасности",
          link: "https://dev.brepo.ru/bayrepo/hestiacp/src/branch/master/SECURITY.md",
        },
      ],
    },
  ];
}
/** @returns {import("vitepress").DefaultTheme.SidebarItem[]} */
function sidebarDocs() {
  return [
    {
      text: "Знакомство",
      collapsed: false,
      items: [
        {
          text: "С чего начать",
          link: "/docs/introduction/getting-started.md",
        },
        { text: "Рекомендации", link: "/docs/introduction/best-practices.md" },
      ],
    },
    {
      text: "Инструкция пользователя",
      collapsed: false,
      items: [
        { text: "Аккаунт", link: "/docs/user-guide/account.md" },
        { text: "Резервные копии", link: "/docs/user-guide/backups.md" },
        { text: "Cron задачи", link: "/docs/user-guide/cron-jobs.md" },
        { text: "Базы данных", link: "/docs/user-guide/databases.md" },
        { text: "DNS", link: "/docs/user-guide/dns.md" },
        { text: "Менеджер файлов", link: "/docs/user-guide/file-manager.md" },
        { text: "Почтовые домены", link: "/docs/user-guide/mail-domains.md" },
        { text: "Оповещения", link: "/docs/user-guide/notifications.md" },
        { text: "Пакеты", link: "/docs/user-guide/packages.md" },
        { text: "Статистика", link: "/docs/user-guide/statistics.md" },
        { text: "Пользователи", link: "/docs/user-guide/users.md" },
        { text: "Веб домены", link: "/docs/user-guide/web-domains.md" },
      ],
    },
    {
      text: "Администрирование сервера",
      collapsed: false,
      items: [
        {
          text: "Создание резервных копий и восстановление",
          link: "/docs/server-administration/backup-restore.md",
        },
        {
          text: "Конфигурация",
          link: "/docs/server-administration/configuration.md",
        },
        {
          text: "Персональная настройка",
          link: "/docs/server-administration/customisation.md",
        },
        {
          text: "Базы данных и phpMyAdmin",
          link: "/docs/server-administration/databases.md",
        },
        {
          text: "DNS кластера & DNSSEC",
          link: "/docs/server-administration/dns.md",
        },
        { text: "Email", link: "/docs/server-administration/email.md" },
        {
          text: "Менеджер файлов",
          link: "/docs/server-administration/file-manager.md",
        },
        { text: "Firewall", link: "/docs/server-administration/firewall.md" },
        {
          text: "Обновления ОС",
          link: "/docs/server-administration/os-upgrades.md",
        },
        { text: "Rest API", link: "/docs/server-administration/rest-api.md" },
        {
          text: "SSL сертификаты",
          link: "/docs/server-administration/ssl-certificates.md",
        },
        {
          text: "Веб шаблоны и кэширование",
          link: "/docs/server-administration/web-templates.md",
        },
        {
          text: "Troubleshooting",
          link: "/docs/server-administration/troubleshooting.md",
        },
      ],
    },
    {
      text: "Содейтсвие в разработке",
      collapsed: false,
      items: [
        { text: "Сборка пакетов", link: "/docs/contributing/building.md" },
        { text: "Разработка", link: "/docs/contributing/development.md" },
        { text: "Документация", link: "/docs/contributing/documentation.md" },
        {
          text: "Установка приложений",
          link: "/docs/contributing/quick-install-app.md",
        },
        { text: "Тестирование", link: "/docs/contributing/testing.md" },
        { text: "Переводы", link: "/docs/contributing/translations.md" },
      ],
    },
    {
      text: "Сообщество",
      collapsed: false,
      items: [
        {
          text: "Hestia Nginx Cache",
          link: "/docs/community/hestia-nginx-cache.md",
        },
        {
          text: "Ioncube installer for Hestia",
          link: "/docs/community/ioncube-hestia-installer.md",
        },
        {
          text: "Генератор установочной команды",
          link: "/docs/community/install-script-generator.md",
        },
      ],
    },
    {
      text: "Ссылки",
      collapsed: false,
      items: [
        { text: "API", link: "/docs/reference/api.md" },
        { text: "CLI", link: "/docs/reference/cli.md" },
      ],
    },
    {
      text: "Дополнения",
      collapsed: false,
      items: [
        {
          text: "PHP cli селектор",
          link: "/docs/extensions/php-cli-selector.md",
        },
        {
          text: "Расширенные модули",
          link: "/docs/extensions/extended-modules.md",
        },
        { text: "Настройка Local PHP", link: "/docs/extensions/local-php.md" },
        {
          text: "nginx+mod_rewrite",
          link: "/docs/extensions/nginx-mod-rewrite.md",
        },
      ],
    },
  ];
}
