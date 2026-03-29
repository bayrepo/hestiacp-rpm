# Расширенные модули

## Что такое модули

Модули расширения панели позволяют расширять функционал панели.

## Как управлять модулями

Для доступа к модулям расширения необходимо из-под пользователя `admin` перейти в `Настройки сервера`:

![ext_modules_step1](/images/ext_modules_step1.png)

Далее в строке выбора настроек выбрать `Доп. модули`:

![ext_modules_step2](/images/ext_modules_step2.png)

Далее откроется страинца достпных модулей и их сотояния.

Пример страницы с демонстрационными модулями приведен ниже:

![ext_modules_step3](/images/ext_modules_step3.png)

Данная страница содержит следующую информацию:

- **ID модуля** - числовой идентификатор модуля
- **Имя модуля** - сивольный идентификатор модуля
- **Описание модуля** - краткая ифнормация о модуле
- **Состояние** - включен(enabled) или выключен(disabled)
- **Зависимости** - список модулей, которые должны быть включены для работы текущего модуля
- **Конфигурация** - дополнительные настройки модуля (при наличии)

Если модуль выключен, его состояние отображается как disabled.

Для включения модуля необходимо нажать на кнопку <i class="fas fa-play"></i>, для выключения модуля необходимо нажать на кнопку <i class="fas fa-stop"></i>.

## Список предустановленных модулей

- **puppet_installer** - установить puppet, для большинства модулей требуется puppet для изменения конфигурации системы, поэтому требуется, чтоб этот модуль был включен, при включении он установит puppet в систему.
- **empty_module** - пустой модуль, его включение или выключение не начто не влияет, является примером написания модулей
- **passenger_manager** - модуль по установке и настройке passenger в систему.
- **php_brepo_modules** - модуль по управлению расширениями Local PHP. [Описание интерфейса](/docs/extensions/local-php.md)

## Управление модулями из командной строки

Для управления модулями используется утилита `v-ext-modules`.

Доступные команды:

- **list** - вывести список доступных модулей
- **enable module_name** - включить модуль
- **disable module_name** - выключить модуль
- **state module_name** - состояние модуля

Примеры:

```
# v-ext-modules list csv
1,puppet_installer,"Added puppet support, needed for another modules","","",enabled
2,passenger_manager,Added passenger support for nginx,puppet_installer,yes,enabled
3,empty_module,Just empty module for storing max module id,"","",disabled
```

```
# v-ext-modules state passenger_manager
 ID  NAME               DESCR                              STATE    REQ               CONF 
 --  ----               -----                              -----    ---               ---- 
 2   passenger_manager  Added passenger support for nginx  enabled  puppet_installer  yes 
```

## passenger_manager

Модуль, для добавления поддержки passenger+nginx для запуска (пока что только) ruby приложений.

### passenger_manager настройка

Для настройки модуля нажмите на ссылку `Изменить`:

![ext_modules_step4](/images/ext_modules_step4.png)

Откроется страница вида:

![ext_modules_step5](/images/ext_modules_step5.png)

- **Добавить новый путь ruby** - добавить путь к бинарному файлу интерпретатору ruby, если его еще нет в списке ниже
- **Ruby list** - список достпных для выбора ruby интерпретаторов. Для удаления ruby из списка необходимо нажать на значек <i class="fas fa-trash-can"></i>.

При активации `passenger_manager` в меню настройки домена для пользователя появляется кнопка `Настройки passenger`:

![ext_modules_step6](/images/ext_modules_step6.png)

При нажатии на которую открывается форма:

![ext_modules_step7](/images/ext_modules_step7.png)

Где можно активировать passenger для домена установкой галочки `Включить passenger для домена`, а так же выбрать из списка ruby.

Галочка `Включить логирование в браузер`, активирует вывод лога ошибки приложения в браузер, рекомендуется ее включать только при настройке приложения.

Пример установки приложения:

пусть есть пользователь `test2` и домен `ttt142.my.brp`, для него активируется passenger.

Для него генерируются следующие настройки:

```
location / {
	passenger_base_uri /;
    passenger_app_root /home/test2/web/ttt142.my.brp/private;
    passenger_document_root /home/test2/web/ttt142.my.brp/public_html;
    passenger_startup_file config.rb;
	passenger_app_type rack;
}
```

В `config.rb` необходимо поместить инструкции запуска приложения:

```
# encoding: UTF-8
require './test'
run Sinatra::Application
```

и соновное приложение разметсить в каталоге `/home/test2/web/ttt142.my.brp/private`.

Остальная логика будет размещена в `test.rb`, для примера вот так:

```
!/usr/bin/env ruby

require 'sinatra'
get '/' do
  "Hello #{Process.uid}"
end
```

Статические файлы располагать в каталоге `/home/test2/web/ttt142.my.brp/public_html`, а так же из этого каталога удалить файл `index.html` создаваемый как заглушка для пустого сайта.

Так же создать файл `Gemfile` в каталоге `/home/test2/web/ttt142.my.brp/private` и выполнить от пользователя:

```
bundle config set --local path 'vendor'
bundle install
```

или по старому:

```
bundle install --path=vendor
```

для установки пользователю необходимых гемов локально.
