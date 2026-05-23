#!/opt/brepo/ruby33/bin/ruby

class PHPWorker < Kernel::ModuleCoreWorker
  MODULE_ID = "php_brepo_modules"

  def info
    {
      ID: 4,
      NAME: MODULE_ID,
      DESCR: "Module for managing of php modules for php's from brepo repository",
      REQ: "",
      CONF: "yes",
    }
  end

  def enable
    if $LOCAL_PHP == "yes"
      super
    else
      log_return("PHP from brepo repository not enabled")
    end
  end

  def get_list_of_installed_php
    php_list = []
    lst = Dir["/opt/brepo/php*/etc/php.ini"]
    if lst.length.positive?
      php_list = lst.select do |item|
        %r{/opt/brepo/php\d+/etc/php\.ini} =~ item
      end.map do |item|
        res = item.match %r{/opt/brepo/php(?<ver>\d+)/etc/php\.ini}
        res[:ver]
      end
    end
    php_list
  end

  def get_list_of_installed_php_modules(php_ver)
    php_modules = {}
    php_list = get_list_of_installed_php
    if php_list.include? php_ver
      lst = Dir["/opt/brepo/php#{php_ver}/etc/mod-installed/*.ini"]
      php_list_m = lst.map { |item| File.basename(item, ".ini") }.select { |item| item.strip != "" && !(item =~ %r{ioncube_loader_lin_}) }
      lst_enabled = Dir["/opt/brepo/php#{php_ver}/etc/php.d/*.ini"]
      php_list_i = {}
      lst_enabled.each do |item|
        fname = File.basename(item, ".ini")
        if fname.strip != ""
          if File.symlink? item
            fname_n = File.readlink(item)
            fname_n = File.basename(fname_n, ".ini")
            php_list_i[fname_n] = fname unless fname_n.strip == ""
          end
        end
      end
      php_list_m.each do |item|
        php_modules[item] = "disabled"
        php_modules[item] = php_list_i[item] unless php_list_i[item].nil?
      end
    end
    php_modules
  end

  def get_php_module_description(module_name)
    case module_name
    when "bcmath"
      "Модуль математических операций с числами произвольной точности"
    when "curl"
      "Поддержка curl функций из библиотеки libcurl"
    when "dba"
      "Эти функции — основа для доступа к базам данных наподобие Berkeley DB"
    when "dom"
      "Модуль DOM разрешает работать в PHP с XML- и HTML-документами через DOM API"
    when "gd"
      "Функции работы с изображениями"
    when "imap"
      "Эти функции позволяют работать с протоколом IMAP, а также NNTP, POP3 и локальными методами доступа к почтовому ящику."
    when "intl"
      "Модуль интернационализации"
    when "ioncube"
      "Модуль котрый производит деобфускацию кода, написанного на языке php и закодированного утилитами из набора ioncube"
    when "ioncube_loader_lin_7.4"
      "Модуль котрый производит деобфускацию кода, написанного на языке php и закодированного утилитами из набора ioncube"
    when "json"
      "Поддержка json в  PHP"
    when "ldap"
      "Поддержка работы с LDAP в PHP"
    when "mbstring"
      "Поддержка работы с многобайтовыми строками"
    when "memcache"
      "Модуль Memcache предоставляет удобный процедурный и объектно-ориентированный интерфейс к memcached, высокоэффективному кеширующему демону, который был специально разработан для снижения нагрузки на базу данных в динамических веб приложениях"
    when "mysqli"
      "Модуль mysqli позволяет вам получить доступ к функциональности, которую предоставляет MySQL версии 4.1 и выше"
    when "mysqlnd"
      "Встроенный драйвер MySQL"
    when "odbc"
      "В дополнение к обычной поддержке ODBC, функции Unified ODBC в PHP позволяют получить доступ к нескольким базам данных, которые позаимствовали семантику ODBC API для реализации своего собственного API."
    when "opcache"
      "Модуль OPcache сохраняет предкомпилированный байт-код скриптов в разделяемой памяти. Кеширование операционного PHP-кода повышает производительность и помогает избегать загрузки и анализа скриптов при каждом запросе."
    when "pdo"
      "Модуль PDO определяет легковесный и непротиворечивый интерфейс доступа к базам данных в PHP."
    when "pdo_dblib"
      "PDO_DBLIB: драйвер модуля PDO для СУБД Microsoft SQL Server и Sybase"
    when "pdo_mysql"
      "PDO_MYSQL: драйвер модуля PDO для СУБД MySQL"
    when "pdo_odbc"
      "PDO_ODBC: драйвер модуля PDO для СУБД ODBC и DB2"
    when "pdo_pgsql"
      "PDO_PGSQL: драйвер модуля PDO для СУБД PostgreSQL"
    when "pdo_sqlite"
      "PDO_SQLITE: драйвер модуля PDO для СУБД SQLite"
    when "pgsql"
      "Модуль поддержки взаимодействия PHP с PostgreSQL"
    when "phar"
      "Модуль phar предоставляет возможность поместить целое PHP-приложение в один-единственный файл c именем phar (PHP Archive) для простого распространения и установки"
    when "posix"
      "Этот модуль содержит интерфейс к функциям, определённым в стандарте IEEE 1003.1 (POSIX.1), которые не доступны с помощью других средств."
    when "pspell"
      "Функции позволяют проверять правописание слова и предлагают варианты исправления."
    when "snmp"
      "Модуль SNMP предоставляет простой и удобный набор инструментов для управления удалёнными устройствами через Simple Network Management Protocol (простой протокол управления сетями)"
    when "soap"
      "Модуль SOAP может использоваться для написания как серверной, так и клиентской части. Он реализует спецификации » SOAP 1.1, » SOAP 1.2 и » WSDL 1.1."
    when "sodium"
      "Sodium — современная, простая в работе программная библиотека для шифрования и дешифрования данных, выполнения операций с подписями, хеширования паролей и других криптографических целей"
    when "sysvmsg"
      "Модуль поддержки сообщений System V"
    when "sysvsem"
      "Поддержка семафоров"
    when "sysvshm"
      "Поддержка разделяемой памяти"
    when "tidy"
      "Модуль коррекции разметки tidy"
    when "xmlreader"
      "Модуль XMLReader — синтаксический анализатор XML-документов"
    when "xmlrpc"
      "Функции модуля помогают писать клиентский или серверный код по правилам стандарта XML-RPC"
    when "xmlwriter"
      "Модуль XMLWriter оборачивает API-интерфейс парсера xmlWriter, который входит в состав модуля libxml."
    when "xsl"
      "Модуль XSL реализует XSL-стандарт путём XSLT-преобразований, которые выполняет через библиотеку libxslt"
    when "zip"
      "Модуль позволяет легко читать и записывать как в сами сжатые ZIP-архивы, так и в файлы внутри них"
    else
      "нет описания"
    end
  end

  def disable_module(php_ver, module_name)
    php_mods = get_list_of_installed_php_modules(php_ver)
    return if php_mods[module_name].nil?

    if File.exist? ("/opt/brepo/php#{php_ver}/etc/php.d/#{php_mods[module_name]}.ini")
      File.unlink("/opt/brepo/php#{php_ver}/etc/php.d/#{php_mods[module_name]}.ini")
    end
  end

  def enable_module(php_ver, module_name)
    php_mods = get_list_of_installed_php_modules(php_ver)
    return if php_mods[module_name].nil?

    if php_mods[module_name] == "disabled"
      case module_name
      when "opcache"
        File.symlink("/opt/brepo/php#{php_ver}/etc/mod-installed/#{module_name}.ini", "/opt/brepo/php#{php_ver}/etc/php.d/10-#{module_name}.ini")
      when "mysqli", "pdo_mysql", "xmlreader", "zip"
        File.symlink("/opt/brepo/php#{php_ver}/etc/mod-installed/#{module_name}.ini", "/opt/brepo/php#{php_ver}/etc/php.d/30-#{module_name}.ini")
      else
        File.symlink("/opt/brepo/php#{php_ver}/etc/mod-installed/#{module_name}.ini", "/opt/brepo/php#{php_ver}/etc/php.d/20-#{module_name}.ini")
      end
    end
  end

  def command(args)
    return log_return("Not enough arguments. Needed command") if args.length < 1

    m_command = args[0].strip
    case m_command
    when "php_list"
      result = get_list_of_installed_php.map { |item| { "PHPVER" => item } }
      format = (args[1].nil? ? "shell" : args[1].strip)
      hestia_print_array_of_hashes(result, format, "PHPVER")
      ACTION_OK
    when "php_modules"
      vers = args[1]
      if vers.nil?
        log_return("Verssion should be specified. #{args}")
      else
        vers = vers.strip
        modules_list = get_list_of_installed_php_modules(vers)
        m_keys = modules_list.keys.sort
        result = []
        m_keys.each do |kk|
          tmp_hash = {}
          tmp_hash["PHPVER"] = vers
          tmp_hash["MODNAME"] = kk
          tmp_hash["STATE"] = modules_list[kk]
          tmp_hash["DESCR"] = get_php_module_description(kk)
          result << tmp_hash
        end
        format = (args[2].nil? ? "shell" : args[2].strip)
        hestia_print_array_of_hashes(result, format, "PHPVER,MODNAME,STATE,DESCR")
        ACTION_OK
      end
    when "php_enable"
      vers = args[1]
      mod_n = args[2]
      if vers.nil? || mod_n.nil?
        log_return("Verssion and module name should be specified. #{args}")
      else
        vers = vers.strip
        mod_n = mod_n.strip
        enable_module(vers, mod_n)
        ACTION_OK
      end
    when "php_disable"
      vers = args[1]
      mod_n = args[2]
      if vers.nil? || mod_n.nil?
        log_return("Verssion and module name should be specified. #{args}")
      else
        vers = vers.strip
        mod_n = mod_n.strip
        disable_module(vers, mod_n)
        ACTION_OK
      end
    when "help"
      puts "#{$0} php_brepo_modules COMMAND [OPTIONS] [json|csv|plain]"
      puts "COMMANDS:"
      puts "  php_list - list all local php installed"
      puts "  php_modules [php_ver] - list available php module"
      puts "  php_enable [php_ver] [module_name] - enable php module"
      puts "  php_disable [php_ver] [module_name] - disable php module"
      puts "  help - help"
      ACTION_OK
    else
      log_return("Unknown command. #{args}")
    end
  end

  implements IPluginInterface
end

module PHPModule
  def get_object
    Proc.new { PHPWorker.new }
  end

  module_function :get_object
end

class Kernel::PluginConfiguration
  include PHPModule

  @@loaded_plugins[PHPWorker::MODULE_ID] = PHPModule.get_object
end
