#!/opt/brepo/ruby33/bin/ruby

require 'json'

# Файл конфигурации Hestia
config_file = '/usr/local/hestia/conf/hestia.conf'

# Проверяем наличие строки LOCAL_PHP и её значение. Если она отсутствует или не равна 'yes', добавляем или заменяем её.
def ensure_local_php_enabled(config_file)
  if File.exist?(config_file)
    lines = File.readlines(config_file)
    found = false

    # Обрабатываем каждую строку
    new_lines = lines.map do |line|
      if line.strip.start_with?("LOCAL_PHP=")
        found = true
        "LOCAL_PHP='yes'"
      else
        line
      end
    end

    # Если строки LOCAL_PHP не было найдено, добавляем её в конец файла
    unless found
      new_lines << "LOCAL_PHP='yes'\n"
    end

    # Записываем изменения обратно в файл
    File.open(config_file, 'w') do |file|
      file.puts new_lines
    end
  else
    # Если файла не существует, создаём его и добавляем строку LOCAL_PHP='yes'
    File.write(config_file, "LOCAL_PHP='yes'\n")
  end
end

# Вызываем утилиту и разбираем JSON-ответ для получения списка установленных версий PHP
def get_installed_php_versions
  output = `v-list-web-templates-backend json`
  json_data = JSON.parse(output)
  json_data.select { |version| version.start_with?("PHP-") }
end

# Вызываем утилиту и разбираем JSON-ответ для получения списка пользователей
def get_hestia_users
  output = `v-list-users json`
  json_data = JSON.parse(output)
  json_data.keys # Возвращаем только ключи (имена пользователей)
end

# Вызываем утилиту и разбираем JSON-ответ для получения списка доменов пользователя
def get_user_domains(user)
  output = `v-list-web-domains #{user} json`
  json_data = JSON.parse(output)
  json_data # Возвращаем весь хэш с доменами
end

# Функция для получения корректной версии PHP
def get_correct_php_version(system_php_version)
  if system_php_version.length < 2
    "8.2"
  else
    "#{system_php_version[0]}.#{system_php_version[1]}"
  end
end


# Основная часть программы
begin
  system_php_version = `php -r "echo str_replace('.', '', substr(phpversion(), 0, 3));"`

  ensure_local_php_enabled(config_file)

  INSTALLED_PHP_LIST = get_installed_php_versions
  puts "Установленные версии PHP: #{INSTALLED_PHP_LIST.join(', ')}"

  # Обрабатываем каждый элемент массива INSTALLED_PHP_LIST
  INSTALLED_PHP_LIST.each do |php_version|
    # Удаляем префикс 'PHP-' и остаёмся только с цифрами
    version_number = php_version.gsub(/^PHP-/, '')
    
    # Вызываем команду v-add-web-php с номером версии PHP
    puts "Выполняем команду: v-add-web-php #{version_number}"
    system("v-add-web-php", version_number)
  end

  # Получаем список пользователей Hestia
  HESTIA_USERS_LIST = get_hestia_users
  puts "Список пользователей Hestia: #{HESTIA_USERS_LIST.join(', ')}"

  # Для каждого пользователя из списка выполняем действия с доменами
  HESTIA_USERS_LIST.each do |user|
    puts "Обрабатываем пользователя: #{user}"
    
    # Получаем список доменов для текущего пользователя
    user_domains = get_user_domains(user)
    
    # Обрабатываем каждый домен и изменяем шаблон бэкенда
    user_domains.each do |domain, details|
      current_domain = domain
      current_backend = details['BACKEND']
      
      puts "Обрабатываем домен: #{current_domain}, текущий бэкенд: #{current_backend}"
      
      # Вызываем команду для изменения шаблона бэкенда
      command = ["v-change-web-domain-backend-tpl", user, current_domain, current_backend]
      puts "Выполняем команду: #{command.join(' ')}"
      system(*command)
    end
  end
  
  # Перенастраиваем alternatives для новго PHP
  correct_php_version = get_correct_php_version(system_php_version)
  puts "Перенастраиваем PHP на новый путь командой: v-change-sys-php #{correct_php_version}"
  system("v-change-sys-php", system_php_version)

  # Список регулярных выражений для поиска пакетов, которые нужно удалить
  patterns_to_remove = [
    /^php\d{2}-runtime-.*$/,
    /^php\d{2}-php/
  ]

  # Получаем список установленных пакетов на системе
  installed_packages = `yum list installed | grep remi`.split("\n").map { |line| line.split.first }

  # Фильтруем подходящие пакеты для удаления
  packages_to_remove = []

  patterns_to_remove.each do |pattern|
    installed_packages.each do |package|
      if package.match?(pattern)
        packages_to_remove << package
      end
    end
  end

  if packages_to_remove.empty?
    puts "Нет подходящих пакетов для удаления."
  else
    puts "Следующие пакеты будут удалены:"
    packages_to_remove.each_with_index { |package, index| puts "#{index + 1}. #{package}" }

    print "\nВы уверены, что хотите удалить эти пакеты? (y/n): "
    response = gets.chomp.downcase

    if response == 'y'
      # Формируем команду для удаления всех пакетов одной командой
      remove_command = "yum remove -y #{packages_to_remove.join(' ')}"
      system(remove_command)
      puts "\nОперация завершена. Пакеты были успешно удалены."
    else
      puts "\nУдаление отменено пользователем."
    end
  end
  
  # Перезапустим все PHP-FPM
  INSTALLED_PHP_LIST.each do |php_version|
    # Удаляем префикс 'PHP-' и остаёмся только с цифрами
    version_number = php_version.gsub(/^PHP-/, '')

    puts "Выполняем команду: systemctl restart brepo-php-fpm#{version_number}"
    system("systemctl", "restart", "brepo-php-fpm#{version_number}")
  end

rescue => e
  puts "Произошла ошибка: #{e.message}"
end
