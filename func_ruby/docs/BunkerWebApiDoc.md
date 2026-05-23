# HestiaBunkerWebApi - Ruby класс для работы с BunkerWeb API

## Описание

Класс `HestiaBunkerWebApi` предоставляет простой интерфейс для управления сервисами BunkerWeb через REST API. Класс реализует:

- **Аутентификацию** с получением токена
- **Управление сервисами** (создание, обновление, удаление)
- **Управление SSL сертификатами**
- **Управление instances** (worker nodes)
- **Полное исключение ошибок** при любых проблемах

## Установка и импорт

```bash
# Ruby 3.3+ рекомендуется
ruby --version
# ruby 3.3.x or later

# Класс использует стандартные библиотеки Ruby:
# - json (для JSON парсинга)
# - net/http (для HTTP запросов)
# - uri (для URL парсинга)
```

## Использование класса

### Базовое использование

```ruby
require_relative "HestiaBunkerWebApi.rb"

# Создаём экземпляр API с аутентификацией
api = HestiaBunkerWebApi.new(
  "http://127.0.0.1:8888",  # URL API (можно https://)
  "admin",                   # username
  "password"                 # password
)
# или
api = HestiaBunkerWebApi.new(
  "http://127.0.0.1:8888",  # URL API (можно https://)
)
# в этом случае пароль и логин читаются автоматически из файла /etc/bunkerweb/api.env


# При создании экземпляра автоматически происходит аутентификация
# Если ошибка - выбрасывается BunkerWebApiError с описанием проблемы
```

### Обработка ошибок

Все ошибки наследуются от `StandardError` через класс `BunkerWebApiError`:

```ruby
begin
  api.create_service("example.domain", options)
rescue BunkerWebApiError => e
  puts "[ERROR] Ошибка API: #{e.message}"
  
  # Примеры возможных ошибок:
  # - "Authentication failed: 401 - Unauthorized"
  # - "Service 'x' already exists"
  # - "Certificate and Key paths are required when USE_SSL is enabled"
  # - "Failed to create service: status=500, body={...}"
  
  exit 1
end
```

## Методы класса

### Конструктор

```ruby
HestiaBunkerWebApi.new(api_url, username, password)
```

**Параметры:**
- `api_url` - URL BunkerWeb API в формате `http://ip:port` или `https://ip:port`
- `username` - имя администратора для аутентификации
- `password` - пароль для аутентификации

**Действие:** При создании автоматически пытается аутентифицироваться через POST /auth и сохраняет токен.

### Создание сервиса

```ruby
api.create_service(service_name, options = {})
```

**Параметры:**
- `service_name` - имя домена/сервиса (например, "example.my.domain")
- `options` - хэш с конфигурацией:

| Параметр | Тип | Описание | Пример |
|----------|-----|----------|--------|
| `ssl` | String | "yes" для SSL, "no" для HTTP | `"no"` |
| `certificate_path` | String | Путь к SSL сертификату (если ssl="yes") | `"/etc/ssl/certs/example.crt"` |
| `key_path` | String | Путь к приватному ключу (если ssl="yes") | `"/etc/ssl/private/example.key"` |
| `use_template` | String | Безопасность шаблона | `"high"` (default) |
| `reverse_proxy_host` | String | Target reverse proxy | `"http://192.168.3.51:8078"` |
| `reverse_proxy_url` | String | URL трансформация | `"~ ^/(.*)$"` |
| `real_ip_from` | String | CIDR trusted network для RealIP | `"192.168.3.0/24"` |
| `use_modsecurity` | String | WAF включение | `"yes"` (default) |
| `anti_bot` | String | Bot protection | `"captcha"` (default) |
| `http_port` | Integer/nil | HTTP порт | `"80"` или `null` |
| `https_port` | Integer | HTTPS порт | `443` или `null` |

**Пример - создание reverse proxy сервиса без SSL:**
```ruby
result = api.create_service("example.my.domain", {
  ssl: "no",
  reverse_proxy_host: "http://192.168.3.51:8078"
})

# Генерирует variables:
# - USE_TEMPLATE: "high"
# - USE_SSL: "no"
# - LISTEN_HTTPS_PORT: "null"
# - LISTEN_HTTP_PORT: "80"
# - USE_REVERSE_PROXY: "yes"
# - REVERSE_PROXY_HOST: "http://192.168.3.51:8078"
```

**Пример - создание сервиса с SSL + reverse proxy:**
```ruby
result = api.create_service("example.my.domain", {
  ssl: "yes",                              # Включаем SSL
  
  certificate_path: "/etc/ssl/certs/example.crt",  # Путь к сертификату
  key_path: "/etc/ssl/private/example.key",        # Путь к ключу
  
  reverse_proxy_host: "http://192.168.3.51:8078",  # Reverse proxy target
  
  use_template: "high",
  anti_bot: "captcha"
})

# Генерирует variables:
# - USE_TEMPLATE: "high"
# - USE_SSL: "yes"
# - SSL_CERTIFICATE_FILE_PATH: "/etc/ssl/certs/example.crt"
# - SSL_KEY_FILE_PATH: "/etc/ssl/private/example.key"
# - LISTEN_HTTPS_PORT: "443"
# - LISTEN_HTTP_PORT: "80"
```

### Обновление SSL сертификата для существующего сервиса

```ruby
api.update_service_ssl(service_name, certificate_path, key_path, https_port = nil)
```

**Параметры:**
- `service_name` - имя уже созданного сервиса
- `certificate_path` - новый путь к SSL сертификату
- `key_path` - новый путь к приватному ключу
- `https_port` (optional) - HTTPS порт (default: 443)

**Пример:**
```ruby
api.update_service_ssl(
  "example.my.domain",
  "/etc/ssl/certs/example.crt",
  "/etc/ssl/private/example.key"
)

# Обновляет существующий сервис, сохраняя reverse proxy настройки
```

### Удаление сервиса

```ruby
api.delete_service(service_name)
```

**Параметры:**
- `service_name` - имя сервиса для удаления

**Пример:**
```ruby
api.delete_service("example.my.domain")
# Удаляет сервис и конфигурацию
```

### Получение списка всех сервисов

```ruby
api.list_services(drafts = false)
```

**Параметры:**
- `drafts` (optional) - включать draft сервисы (default: false)

**Возвращает:** Array of service objects

**Пример:**
```ruby
services = api.list_services()
services.each { |s| puts "- #{s['server_name']}" }
```

### Получение деталей конкретного сервиса

```ruby
api.get_service(service_name)
```

**Параметры:**
- `service_name` - имя сервиса для получения деталей

**Возвращает:** Hash with service configuration (variables, settings, etc.)

**Пример:**
```ruby
config = api.get_service("example.my.domain")
puts config.inspect
```

### Перезагрузка конфигурации на instance

```ruby
api.reload_instance(instance_hostname = nil)
```

**Параметры:**
- `instance_hostname` (optional) - hostname instance для перезагрузки (если nil, reloads all instances)

**Пример:**
```ruby
# Reload все instances
api.reload_instance()

# Reload конкретный instance
api.reload_instance("192.168.3.50")
```

### Получение списка всех instances

```ruby
api.list_instances()
```

**Возвращает:** Array of instance objects (hostname, name, port, etc.)

### Создание/регистрация BunkerWeb instance (worker node)

```ruby
api.create_instance(hostname, name = nil, port = 8888, https_port = nil)
```

**Параметры:**
- `hostname` - IP address или hostname worker node
- `name` (optional) - Human-readable имя instance
- `port` - API port на worker node (default: 8888)
- `https_port` (optional) - HTTPS port если есть

**Пример:**
```ruby
api.create_instance(
  "192.168.3.50",          # IP worker node
  "BunkerWeb Worker Node", # Optional name
  8888                      # API port
)

# Возвращает: { status: 201/409, body: {...} }
# Если статус 201 - instance создан
# Если статус 409 - instance уже существует (это OK)
```

### Удаление BunkerWeb instance

```ruby
api.delete_instance(hostname)
```

**Параметры:**
- `hostname` - hostname instance для удаления

## Примеры полного использования

### Пример 1: Создание и управление сервисом

```ruby
require_relative "HestiaBunkerWebApi.rb"

begin
  # 1. Подключаемся к API
  api = HestiaBunkerWebApi.new(
    "http://127.0.0.1:8888",
    "admin",
    "your_password"
  )
  
  # 2. Создаём reverse proxy сервис без SSL
  result = api.create_service("u4.my.brp", {
    ssl: "no",
    reverse_proxy_host: "http://192.168.3.51:8078"
  })
  
  puts "[INFO] Service created: #{result.inspect}"
  
  # 3. Добавляем SSL сертификат позже (если нужно)
  api.update_service_ssl(
    "u4.my.brp",
    "/etc/ssl/certs/u4.crt",
    "/etc/ssl/private/u4.key"
  )
  
  # 4. Проверяем список сервисов
  services = api.list_services()
  puts "[INFO] All services:"
  services.each { |s| puts "- #{s['server_name']}" }
  
  # 5. Удаление сервиса (при необходимости)
  api.delete_service("u4.my.brp")
  
rescue BunkerWebApiError => e
  puts "[ERROR] Ошибка API: #{e.message}"
  exit 1
end
```

### Пример 2: Управление несколькими сервисами

```ruby
require_relative "HestiaBunkerWebApi.rb"

api = HestiaBunkerWebApi.new("http://127.0.0.1:8888", "admin", "password")

# Создаём несколько сервисов с разными конфигурациями
services_to_create = [
  { name: "service1.domain", ssl: "no", reverse_proxy_host: "http://192.168.3.50:80" },
  { name: "service2.domain", ssl: "yes", certificate_path: "/certs/service2.crt", key_path: "/keys/service2.key", reverse_proxy_host: "http://192.168.3.51:8078" }
]

services_to_create.each do |opts|
  begin
    api.create_service(opts[:name], opts)
  rescue BunkerWebApiError => e
    puts "[ERROR] #{e.message}" if e.message.include?("already exists")
  end
end

# Reload конфигурации на instance
api.reload_instance("192.168.3.50")
```

### Пример 3: Обработка ошибок и логирование

```ruby
require_relative "HestiaBunkerWebApi.rb"

def safe_create_service(api_url, username, password, service_name, options)
  begin
    api = HestiaBunkerWebApi.new(api_url, username, password)
    
    result = api.create_service(service_name, options)
    return { success: true, data: result }
    
  rescue BunkerWebApiError => e
    if e.message.include?("Authentication")
      puts "[FATAL] Authentication failed: #{e.message}"
    elsif e.message.include?("already exists")
      begin
        existing = api.get_service(service_name)
        return { success: false, already_exists: true, service: existing }
      rescue => get_error
        return { success: false, error: "Can't retrieve service: #{get_error.message}" }
    else
      return { success: false, error: e.message }
    end
  end
  
  { success: false, error: "Unknown error" }
end

# Использование
result = safe_create_service("http://127.0.0.1:8888", "admin", "password", "example.domain", { ssl: "yes" })

if result[:success]
  puts "[SUCCESS] Service created"
elsif result[:already_exists]
  puts "[INFO] Service exists:"
  puts JSON.generate(result[:service])
else
  puts "[FAILED] #{result[:error]}"
end
```

## Ошибки и их обработка

### Типичные ошибки:

| Код ответа | Описание | Пример сообщения |
|------------|----------|------------------|
| **401** | Authentication failed | "Authentication failed: 401 - Unauthorized" |
| **200 (no token)** | Auth passed but no token | "Authentication succeeded but no token received" |
| **Connection error** | API недоступен | "Authentication error: Connection refused" |
| **409 Conflict** | Service already exists | "Service 'x' already exists" |
| **422 Unprocessable Entity** | Invalid data (например, LISTEN_HTTPS_PORT = nil) | "Failed to create service: status=422..." |
| **429 Too Many Requests** | Rate limit exceeded | "Rate limit exceeded: 10 per 1 minute" |

### Решение проблем с rate limiting

Если получаете ошибку `429` (rate limit), нужно отключить или увеличить лимит в `/etc/bunkerweb/api.env`:

```bash
# Откройте конфиг и найдите секцию Rate limiting
nano /etc/bunkerweb/api.env

# Добавьте/измените:
API_RATE_LIMIT_ENABLED=no          # Отключение rate limiting
# или
API_RATE_LIMIT=1000/minute         # Увеличение лимита до 1000/m
```

Затем перезагрузите API service:

```bash
systemctl reload bunkerweb-api.service
```

## Особенности реализации

### 1. SSL сертификатные пути

Когда `ssl: "no"` - API ожидает `"LISTEN_HTTPS_PORT" => "null"` (строка), а не JSON null (`nil`):

```ruby
# ❌ Ошибка:
variables["LISTEN_HTTPS_PORT"] = nil  # → 422 error

# ✅ Правильно:
variables["LISTEN_HTTPS_PORT"] = "null"  # → 200 OK
```

### 2. Статусы ответа для создания сервиса

BunkerWeb API возвращает **200 OK** вместо стандартного **201 Created**:

```ruby
# Класс принимает оба статуса как успех:
if [201, 200].include?(response[:status])
  puts "[INFO] Service created successfully"
end
```

### 3. Поддержка HTTP методов

Класс поддерживает все основные HTTP методы для API операций:
- **GET** - получение данных (services, instances)
- **POST** - создание (services, instances, auth)
- **PATCH** - обновление (services)
- **DELETE** - удаление (services, instances)

## Совместимость

- **Ruby**: 3.0+
- **BunkerWeb API**: 1.6.x и выше
- **ZooKeeper/Redis**: не требуются для этого класса (работает через HTTP API напрямую)

## Дополнительные ресурсы

- [Документация BunkerWeb API](https://docs.bunkerweb.io/api.md)
- [API Swagger docs at /docs](http://127.0.0.1:8888/docs)
- [OpenAPI schema](http://127.0.0.1:8888/openapi.json)
