#!/usr/bin/env ruby

require 'json'
require 'net/http'
require 'uri'
require 'openssl'

class BunkerWebApiError < StandardError; end
class HestiaBunkerWebApi
  # Override puts to accumulate logs into @extra_info
  def puts(*args)
    @extra_info ||= ""
    @extra_info << args.join("\n") << "\n"
  end

  # Accessor for @extra_info
  def extra_info
    @extra_info || ""
  end
end

# Hook to wrap methods of HestiaBunkerWebApi to reset @extra_info at start
class Module
  alias_method :orig_method_added, :method_added
  def method_added(name)
    orig_method_added(name)
    # Skip wrapping for the overridden puts method
    return if name == :puts
    if self.name == 'HestiaBunkerWebApi'
      @__wrapping ||= false
      return if @__wrapping
      @__wrapping = true
      original = instance_method(name)
      define_method(name) do |*args, &block|
        @extra_info = ""
        original.bind(self).call(*args, &block)
      end
      @__wrapping = false
    end
  end
end
class HestiaBunkerWebApi
  # Retrieve API username and password from /etc/bunkerweb/api.env if available
  def get_api_user_password
    env_path = "/etc/bunkerweb/api.env"
    return nil unless File.file?(env_path)

    username = nil
    password = nil

    File.foreach(env_path) do |line|
      line.strip!
      next if line.empty? || line.start_with?('#')
      key, value = line.split('=', 2)
      next unless key && value
      case key
      when 'API_USERNAME'
        username = value
      when 'API_PASSWORD'
        password = value
      end
    end

    if username && password
      [username, password]
    else
      nil
    end
  end

  def initialize(api_url, username = nil, password = nil)
    @api_base = api_url
    if username.nil?
      result = get_api_user_password
      if result.nil?
        raise BunkerWebApiError.new("Authentication error: no username or password")
      else
        @username = result[0]
        @password = result[1]
      end
    else
      @username = username
      @password = password
    end
    @token = nil
    @extra_info = ""

    # Authenticate and get token
    authenticate!

    puts "[INFO] Successfully authenticated with BunkerWeb API"
  end

  def authenticate!
    uri = URI(@api_base)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")

    # Try both Basic Auth and JSON body with credentials
    request = Net::HTTP::Post.new("/auth")
    request.content_type = "application/json"
    request.body = { username: @username, password: @password }.to_json

    response = http.request(request)

    if response.code != '200'
      raise BunkerWebApiError.new("Authentication failed: #{response.code} - #{response.message}")
    end

    body = JSON.parse(response.body)

    unless body['token']
      raise BunkerWebApiError.new("Authentication succeeded but no token received")
    end

    @token = body['token']
  rescue => e
    raise BunkerWebApiError.new("Authentication error: #{e.message}")
  end

  def api_call(method, path, headers = {}, body = nil)
    uri = URI(@api_base + path)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")

    request = case method
              when "GET"
                Net::HTTP::Get.new(uri.path)
              when "POST"
                req = Net::HTTP::Post.new(uri.path)
                req.body = body if body
                req
              when "PATCH"
                req = Net::HTTP::Patch.new(uri.path)
                req.body = body if body
                req
              when "DELETE"
                Net::HTTP::Delete.new(uri.path)
              else
                raise BunkerWebApiError.new("Unsupported HTTP method: #{method}")
              end

    # Add Authorization header with token for most operations (except /auth)
    unless path == "/auth"
      headers["Authorization"] = "Bearer #{@token}" if @token
    end

    # Add Content-Type if not already set and we have a body
    if body && !headers.key?("Content-Type")
      headers["Content-Type"] = "application/json"
    end

    headers.each { |k, v| request[k] = v }

    response = http.request(request)
    parsed_body = begin
      JSON.parse(response.body)
    rescue => e
      nil
    end

    { status: response.code.to_i, body: parsed_body || {}, raw_body: response.body }
  rescue => e
    raise BunkerWebApiError.new("API call to #{path} failed: #{e.message}")
  end

  # === Service Operations ===

  def create_service(service_name, options = {})
    @extra_info = ""
    # Create a new service with the given configuration.
    #
    # Args:
    #   service_name (String): The domain name for this service (server_name)
    #   options (Hash): Service configuration including:
    #     - USE_TEMPLATE (default: "high")
    #     - USE_SSL (default: "no") - if not "no", you need CERTIFICATE and KEY paths
    #     - REVERSE_PROXY_HOST (optional)
    #     - REVERSE_PROXY_URL (optional, default: "~ ^/(.*)$")
    #     - Additional options like:
    #       - USE_REVERSE_PROXY (default: "yes" if REVERSE_PROXY_HOST is set)
    #       - USE_REAL_IP, REAL_IP_FROM
    #       - USE_MODSECURITY, USE_ANTIBOT
    #       - LISTEN_HTTP_PORT, LISTEN_HTTPS_PORT
    #     - CERTIFICATE_FILE_PATH (if USE_SSL != "no")
    #     - KEY_FILE_PATH (if USE_SSL != "no")
    # Returns: Hash with creation response

    variables = {
      "USE_TEMPLATE" => options[:use_template] || "high",
      "USE_REVERSE_PROXY" => options[:reverse_proxy_host].nil? ? "no" : "yes",
      "LIMIT_REQ_RATE" => options[:limit_req_rate] || "10r/s",
    }

    # SSL configuration - only if USE_SSL != "no"
    ssl_enabled = options[:ssl] && options[:ssl] != "no"
    variables["USE_CUSTOM_SSL"] = ssl_enabled ? "yes" : "no"

    if ssl_enabled
      unless options[:certificate_path] && options[:key_path]
        raise BunkerWebApiError.new("Certificate and Key paths are required when USE_SSL is enabled")
      end

      # Set certificate paths in variables
      variables["CUSTOM_SSL_CERT"] = options[:certificate_path]
      variables["CUSTOM_SSL_KEY"] = options[:key_path]

      variables["LISTEN_HTTPS_PORT"] = (options[:https_port] || "443").to_s
      variables["USE_REVERSE_PROXY_SSL"] = options[:reverse_proxy_ssl] || "yes"
    else
      # No SSL - HTTP only
      # API expects string "null", not nil/JSON null
      variables["LISTEN_HTTPS_PORT"] = "null"
      variables["LISTEN_HTTP_PORT"] = (options[:http_port] || "80").to_s
    end

    # Reverse proxy configuration if specified
    if options[:reverse_proxy_host]
      variables["REVERSE_PROXY_HOST"] = options[:reverse_proxy_host]
      variables["REVERSE_PROXY_URL"] = options[:reverse_proxy_url] || "~ ^(?!/challenge)(.*)$"

      # Real IP settings for reverse proxy
      unless options[:real_ip_from].nil?
        variables["USE_REAL_IP"] = "yes"
        variables["REAL_IP_FROM"] = options[:real_ip_from]
      end

      # Additional security settings from High template
      variables["USE_MODSECURITY"] = options[:use_modsecurity] || "yes"
      variables["USE_ANTIBOT"] = options[:anti_bot] || "captcha"
    end

    variables["ANTIBOT_IGNORE_URI"] = options[:anti_bot_ignore_uri] || "^/\.well-known/acme-challenge/.+$"
    variables["LETS_ENCRYPT_PASSTHROUGH"] = options[:lets_encrypt_passthrough] || "yes"


    service_body = {
      server_name: service_name,
      is_draft: false,
      variables: variables
    }

    response = api_call("POST", "/services", {}, JSON.generate(service_body))

    # Accept both 201 (Created) and 200 (OK) for successful creation
    if [201, 200].include?(response[:status])
      puts "[INFO] Service '#{service_name}' created successfully"
    elsif response[:status] == 409
      raise BunkerWebApiError.new("Service '#{service_name}' already exists")
    else
      raise BunkerWebApiError.new("Failed to create service: status=#{response[:status]}, body=#{response[:raw_body]}")
    end

    return response[:body] || {}
  end

  def update_service_ssl(service_name, certificate_path, key_path, https_port = nil)
    # Update or change the SSL certificate path for an existing service.
    #
    # Args:
    #   service_name (String): Name of the service to update
    #   certificate_path (String): Path to the SSL certificate file
    #   key_path (String): Path to the SSL private key file
    #   https_port (Integer, optional): HTTPS port (default 443)
    # Returns: Hash with update response

    @extra_info = ""

    # First get current service configuration to preserve existing settings
    get_service_response = api_call("GET", "/services/#{service_name}", {})

    if get_service_response[:status] != 200
      raise BunkerWebApiError.new("Service '#{service_name}' not found")
    end

    # Extract variables from config - API stores them in 'config' not 'variables'
    # Each variable is a hash with 'value' as the actual setting value
    current_vars = {}
    if get_service_response[:body]["config"]
      get_service_response[:body]["config"].each do |key, value_hash|
        if value_hash.is_a?(Hash) && value_hash.key?("value")
          current_vars[key] = value_hash["value"]
        else
          current_vars[key] = value_hash
        end
      end
    end

    # Update SSL settings
    updated_vars = {
      "USE_CUSTOM_SSL" => "yes",
      "CUSTOM_SSL_CERT" => certificate_path,
      "CUSTOM_SSL_KEY" => key_path,
      "LISTEN_HTTPS_PORT" => (https_port || "443").to_s,
      "USE_REVERSE_PROXY_SSL" => "yes"
    }

    # Merge with existing variables (keep non-SSL settings)
    final_vars = current_vars.merge(updated_vars)

    service_body = {
      server_name: nil,  # Not changing name
      is_draft: false,   # Keep as online
      variables: final_vars
    }

    response = api_call("PATCH", "/services/#{service_name}", {}, JSON.generate(service_body))

    if response[:status] == 200
      puts "[INFO] SSL configuration updated for service '#{service_name}'"
    else
      raise BunkerWebApiError.new("Failed to update SSL configuration: status=#{response[:status]}, body=#{response[:raw_body]}")
    end

    return response[:body] || {}
  end


  def set_alias(service_name, list_aliases)
    @extra_info = ""

    # First get current service configuration to preserve existing settings
    get_service_response = api_call("GET", "/services/#{service_name}", {})

    if get_service_response[:status] != 200
      raise BunkerWebApiError.new("Service '#{service_name}' not found")
    end

    # Save the entire current configuration (except server_name which will be replaced)
    current_config = get_service_response[:body]

    # Extract variables from config - API stores them in 'config' not 'variables'
    # Each variable is a hash with 'value' as the actual setting value
    current_vars = {}
    if current_config["config"]
      current_config["config"].each do |key, value_hash|
        if key != "SERVER_NAME"
          if value_hash.is_a?(Hash) && value_hash.key?("value")
            current_vars[key] = value_hash["value"]
          else
            current_vars[key] = value_hash
          end
        end
      end
    end

    # Clean the list_aliases string according to the rules
    cleaned_aliases = list_aliases.to_s

    # Replace commas (with or without space) with a single space
    cleaned_aliases.gsub!(/,\s?/, ' ')

    # Replace multiple spaces with a single space
    cleaned_aliases.gsub!(/\s{2,}/, ' ')

    # Strip leading/trailing whitespace
    cleaned_aliases.strip!

    # Ensure the main service name appears first in the alias list
    aliases_array = cleaned_aliases.split(' ')
    if aliases_array.include?(service_name)
      aliases_array.delete(service_name)
    end
    # Rebuild cleaned string
    cleaned_aliases = aliases_array.join(' ')
    current_vars["SERVER_NAME"]=cleaned_aliases

    # Step 1: Delete the old service
    delete_response = api_call("DELETE", "/services/#{service_name}")
    if delete_response[:status] != 200 && delete_response[:status] != 204
      raise BunkerWebApiError.new("Failed to delete service '#{service_name}': status=#{delete_response[:status]}")
    end
    puts "[INFO] Service '#{service_name}' deleted"

    # Step 2: Create a new service with the cleaned alias list as server_name
    # and preserve all existing configuration variables
    service_body = {
      server_name: service_name,  # Use the full alias list including service_name first
      is_draft: current_config["is_draft"] || false,
      variables: current_vars  # Preserve all existing variables from the original service
    }

    post_response = api_call("POST", "/services", {}, JSON.generate(service_body))

    if post_response[:status] == 200 || post_response[:status] == 201
      puts "[INFO] Service recreated successfully with aliases: #{cleaned_aliases}"
    elsif post_response[:status] == 409
      raise BunkerWebApiError.new("Service '#{service_name}' already exists")
    else
      raise BunkerWebApiError.new("Failed to create service: status=#{post_response[:status]}, body=#{post_response[:raw_body]}")
    end

    return post_response || {}
  end


  def delete_service_ssl(service_name)

    @extra_info = ""

    # First get current service configuration to preserve existing settings
    get_service_response = api_call("GET", "/services/#{service_name}", {})

    if get_service_response[:status] != 200
      raise BunkerWebApiError.new("Service '#{service_name}' not found")
    end

    # Extract variables from config - API stores them in 'config' not 'variables'
    # Each variable is a hash with 'value' as the actual setting value
    current_vars = {}
    if get_service_response[:body]["config"]
      get_service_response[:body]["config"].each do |key, value_hash|
        if value_hash.is_a?(Hash) && value_hash.key?("value")
          current_vars[key] = value_hash["value"]
        else
          current_vars[key] = value_hash
        end
      end
    end

    # Update SSL settings
    updated_vars = {
      "USE_CUSTOM_SSL" => "no",
      "CUSTOM_SSL_CERT" => "",
      "CUSTOM_SSL_KEY" => ""
    }

    # Merge with existing variables (keep non-SSL settings)
    final_vars = current_vars.merge(updated_vars)

    service_body = {
      server_name: nil,  # Not changing name
      is_draft: false,   # Keep as online
      variables: final_vars
    }

    response = api_call("PATCH", "/services/#{service_name}", {}, JSON.generate(service_body))

    if response[:status] == 200
      puts "[INFO] SSL configuration updated for service '#{service_name}'"
    else
      raise BunkerWebApiError.new("Failed to update SSL configuration: status=#{response[:status]}, body=#{response[:raw_body]}")
    end

    return response[:body] || {}
  end

  def delete_service(service_name)
    # Delete a service by its name.
    #
    # Args:
    #   service_name (String): Name of the service to delete
    # Returns: Hash with deletion response

    @extra_info = ""
    # Verify service exists first
    get_response = api_call("GET", "/services/#{service_name}", {})

    if get_response[:status] != 200
      raise BunkerWebApiError.new("Service '#{service_name}' not found")
    end

    response = api_call("DELETE", "/services/#{service_name}")

    if response[:status] == 200 || response[:status] == 204
      puts "[INFO] Service '#{service_name}' deleted successfully"
      return response[:body] || {}
    else
      raise BunkerWebApiError.new("Failed to delete service: status=#{response[:status]}, body=#{response[:raw_body]}")
    end
  end

  # === Additional Utility Methods ===

  def list_services(drafts = false)
    # List all services.
    #
    # Args:
    #   drafts (Boolean): Include draft services (default: false, set to true to include drafts)
    # Returns: Array of service objects

    @extra_info = ""
    response = api_call("GET", "/services")

    if response[:status] != 200
      raise BunkerWebApiError.new("Failed to list services: status=#{response[:status]}")
    end

    return response[:body] || []
  end

  def get_service(service_name)
    # Get details of a specific service.
    #
    # Args:
    #   service_name (String): Name of the service to retrieve
    # Returns: Hash with service configuration

    @extra_info = ""
    response = api_call("GET", "/services/#{service_name}")

    if response[:status] != 200
      raise BunkerWebApiError.new("Service '#{service_name}' not found")
    end

    return response[:body] || {}
  end

  def reload_instance(instance_hostname = nil)
    # Reload configuration on an instance.
    #
    # Args:
    #   instance_hostname (String, optional): Instance hostname to reload (if nil, reloads all instances)
    # Returns: Hash with reload response

    @extra_info = ""
    path = if instance_hostname.nil?
            "/instances/reload"
          else
            "/instances/#{instance_hostname}/reload"
          end

    response = api_call("POST", "#{path}?test=no")

    if response[:status] == 200 || response[:status] == 201
      puts "[INFO] Configuration reloaded successfully"
      return response[:body] || {}
    else
      raise BunkerWebApiError.new("Failed to reload configuration: status=#{response[:status]}")
    end
  end

  def list_instances()
    # List all registered instances.
    # Returns: Array of instance objects

    @extra_info = ""
    response = api_call("GET", "/instances")

    if response[:status] != 200
      raise BunkerWebApiError.new("Failed to list instances: status=#{response[:status]}")
    end

    return response[:body] || []
  end

  def create_instance(hostname, name = nil, port = 8888, https_port = nil)
    # Create/register a new BunkerWeb instance (worker node).
    #
    # Args:
    #   hostname (String): IP address or hostname of the worker node
    #   name (String, optional): Human-readable name for the instance
    #   port (Integer): API port on the worker node (default 8888)
    #   https_port (Integer, optional): HTTPS port
    # Returns: Hash with creation response

    @extra_info = ""
    instance_body = {
      hostname: hostname,
      name: name || "BunkerWeb Instance",
      port: port,
      listen_https: !https_port.nil?,
      https_port: https_port,
      server_name: hostname,
      method: "api"  # Using API deployment method
    }

    response = api_call("POST", "/instances", {}, JSON.generate(instance_body))

    if response[:status] == 201
      puts "[INFO] Instance '#{hostname}' registered successfully"
    elsif response[:status] == 409
      # Instance already exists - that's OK, we just want to use it
      puts "[INFO] Instance '#{hostname}' already exists, will be used for this service"
    else
      raise BunkerWebApiError.new("Failed to create instance: status=#{response[:status]}, body=#{response[:raw_body]}")
    end

    return response[:body] || {}
  end

  def delete_instance(hostname)
    """
    Delete a registered instance.

    Args:
        hostname (String): Hostname of the instance to delete
    """

    @extra_info = ""
    response = api_call("DELETE", "/instances/#{hostname}")

    if response[:status] == 200 || response[:status] == 204
      puts "[INFO] Instance '#{hostname}' deleted successfully"
      return true
    else
      raise BunkerWebApiError.new("Failed to delete instance: status=#{response[:status]}")
    end
  end
end

# === Example Usage (can be run as script) ===

if __FILE__ == $0
  # Example usage demonstration
  begin
    api = HestiaBunkerWebApi.new(
      "http://127.0.0.1:8888",
      "admin",
      "your_password"
    )

    puts ""
    puts "[INFO] Creating service 'example.my.domain'"
    result = api.create_service("example.my.domain", {
      reverse_proxy_host: "http://192.168.3.51:8078",
      ssl: "no",
      use_template: "high"
    })

    puts ""
    puts "[INFO] Listing services:"
    services = api.list_services()
    services.each { |s| puts "- #{s['server_name']}" }

  rescue BunkerWebApiError => e
    puts "[ERROR] #{e.message}"
    exit 1
  end
end
