#!/opt/brepo/ruby33/bin/ruby

require 'shellwords'

class BunkerwebWorker < Kernel::ModuleCoreWorker
  MODULE_ID = "bunkerweb_module"

  def info
    {
      ID: 5,
      NAME: MODULE_ID,
      DESCR: "Bunkerweb enabling",
      REQ: "",
      CONF: "yes",
    }
  end

  def enable
    log_file = get_log
    f_inst_pp = get_module_paydata("bunkerweb_installer.yml")
    if !check
      inf = info
      log("Req error, needed #{inf[:REQ]}")
      "Req error, needed #{inf[:REQ]}"
    else
      begin
        log("install packages for bunkerweb support: /usr/bin/ansible-playbook -vv #{f_inst_pp}")
        result_action = `LC_ALL=C.UTF-8 /usr/bin/ansible-playbook -vv "#{f_inst_pp}" 2>&1`
        ex_status = $?.exitstatus
        if ex_status.to_i == 0 || ex_status.to_i == 2
          log(result_action)
          super
        end
      rescue => e
        log("module installation error #{e.message} #{e.backtrace.first}")
        "module installation error. See log #{log_file}"
      end
    end
  end

  def command(args)
    return log_return("Not enough arguments. Needed command") if args.length < 1
    log_file = get_log

    m_command = args[0].strip
    case m_command
    when "add"
      m_domain = args[1].strip unless args[1].nil?
      m_ip = args[2].strip unless args[2].nil?
      if m_domain.nil? || m_ip.nil?
        log_return("Domain and IP should be specified. #{args}")
      else

        log("add domain to bunkerweb protection")
        output = `/usr/local/hestia/bin/v-bunkerweb-module add #{m_domain} #{m_ip} shell`
        exit_status = $?.exitstatus
        if exit_status != 0
          log_return("Command failed with status #{exit_status}")
        else
          ACTION_OK
        end
      end
    when "delete"
      m_domain = args[1].strip unless args[1].nil?
      if m_domain.nil?
        log_return("Domain should be specified. #{args}")
      else

        log("add domain to bunkerweb protection")
        output = `/usr/local/hestia/bin/v-bunkerweb-module delete #{m_domain} shell`
        exit_status = $?.exitstatus
        if exit_status != 0
          log_return("Command failed with status #{exit_status}")
        else
          ACTION_OK
        end
      end
    when "addssl"
      m_domain = args[1].strip unless args[1].nil?
      m_ssl_cert = args[2].strip unless args[2].nil?
      m_ssl_key = args[3].strip unless args[3].nil?
      if m_domain.nil? || m_ssl_cert.nil? || m_ssl_key.nil? || m_ssl_cert.empty? || m_ssl_key.empty?
        log_return("Domain, SSL cert and SSL key must be specified. #{args}")
      else
        log("add ssl cert to bunkerweb protection")
        output = `/usr/local/hestia/bin/v-bunkerweb-module addssl #{m_domain} #{m_ssl_cert} #{m_ssl_key} shell`
        exit_status = $?.exitstatus
        if exit_status != 0
          log_return("Command failed with status #{exit_status}")
        else
          ACTION_OK
        end
      end
    when "updssl"
      m_domain = args[1].strip unless args[1].nil?
      m_ssl_cert = args[2].strip unless args[2].nil?
      m_ssl_key = args[3].strip unless args[3].nil?
      if m_domain.nil? || m_ssl_cert.nil? || m_ssl_key.nil? || m_ssl_cert.empty? || m_ssl_key.empty?
        log_return("Domain, SSL cert and SSL key must be specified. #{args}")
      else
        log("update ssl cert to bunkerweb protection")
        output = `/usr/local/hestia/bin/v-bunkerweb-module updssl #{m_domain} #{m_ssl_cert} #{m_ssl_key} shell`
        exit_status = $?.exitstatus
        if exit_status != 0
          log_return("Command failed with status #{exit_status}")
        else
          ACTION_OK
        end
      end
  when "deletessl"
    m_domain = args[1].strip unless args[1].nil?
    if m_domain.nil?
      log_return("Domain should be specified. #{args}")
    else

      log("delete ssl cert to bunkerweb protection")
      output = `/usr/local/hestia/bin/v-bunkerweb-module deletessl #{m_domain} shell`
      exit_status = $?.exitstatus
      if exit_status != 0
        log_return("Command failed with status #{exit_status}")
      else
        ACTION_OK
      end
    end
    when "list"
      format = (args[1].nil? ? "shell" : args[1].strip)
      log("list of services")
      output = `/usr/local/hestia/bin/v-bunkerweb-module list #{format}`
      exit_status = $?.exitstatus
      if exit_status != 0
        log_return("Command failed with status #{exit_status}")
      else
        puts output
        ACTION_OK
      end
    when "passwd"
      format = (args[1].nil? ? "shell" : args[1].strip)
      cred = {}
      api_file = "/etc/bunkerweb/api.env"
      if File.exist?(api_file)
        File.readlines(api_file).each do |line|
          line.strip!
          next if line.empty? || line.start_with?('#')
          key, value = line.split('=', 2)
          if %w[API_USERNAME API_PASSWORD].include?(key)
            cred[key] = value
          end
        end
      else
        cred["API_USERNAME"] = nil
        cred["API_PASSWORD"] = nil
      end
      cred["API_USERNAME"] ||= nil
      cred["API_PASSWORD"] ||= nil

      ui_file = "/etc/bunkerweb/ui.env"
      if File.exist?(ui_file)
        File.readlines(ui_file).each do |line|
          line.strip!
          next if line.empty? || line.start_with?('#')
          key, value = line.split('=', 2)
          if %w[ADMIN_USERNAME ADMIN_PASSWORD].include?(key)
            cred[key] = value
          end
        end
      else
        cred["ADMIN_USERNAME"] = nil
        cred["ADMIN_PASSWORD"] = nil
      end
      cred["ADMIN_USERNAME"] ||= nil
      cred["ADMIN_PASSWORD"] ||= nil

      result = []
      result << cred
      hestia_print_array_of_hashes(result, format, "API_USERNAME,API_PASSWORD,ADMIN_USERNAME,ADMIN_PASSWORD")
      ACTION_OK
    when "configure"
      param1 = args[1]
      param2 = args[2]
      if param1 && param2 && !param1.strip.empty? && !param2.strip.empty?
        cmd = "/usr/local/hestia/bin/v-bunkerweb-module-install #{Shellwords.escape(param1)} #{Shellwords.escape(param2)}"
      else
        cmd = "/usr/local/hestia/bin/v-bunkerweb-module-install"
      end
      output = `#{cmd} 2>&1`
      exit_status = $?.exitstatus
      if exit_status != 0
        log_return("#{output}\nCommand failed with status #{exit_status}")
      else
        puts output
        ACTION_OK
      end
    when "alias"
      m_domain = args[1].strip unless args[1].nil?
      m_alias = args[2].strip unless args[2].nil?
      if m_domain.nil?
        log_return("Domain should be specified. #{args}")
      else

        log("add alias #{m_alias} to domain #{m_domain} to bunkerweb protection")
        output = `/usr/local/hestia/bin/v-bunkerweb-module alias #{m_domain} "#{m_alias}" shell`
        exit_status = $?.exitstatus
        if exit_status != 0
          log_return("Command failed with status #{exit_status}")
        else
          ACTION_OK
        end
      end
    when "help"
      puts "#{$0} bunkerweb_module COMMAND [OPTIONS] [json|csv|plain]"
      puts "COMMANDS:"
      puts "  add domain - add domain to bunkerweb"
      puts "  delete domain - delete domain from bunkerweb"
      puts "  addssl domain [path_to_cert] [path_to_key] - add existsing certificate to bunkerweb domain"
      puts "  updssl domain [path_to_cert] [path_to_key] - update existsing certificate to bunkerweb domain"
      puts "  passwd - get ui and api passwd"
      puts "  configure [path_to_cert] [path_to_key] - start initial setup of bunkerweb should do only once"
      puts "  help - help"
      ACTION_OK
    else
      log_return("Unknown command. #{args}")
    end
  end

  implements IPluginInterface
end

module BunkerwebModule
  def get_object
    Proc.new { BunkerwebWorker.new }
  end

  module_function :get_object
end

class Kernel::PluginConfiguration
  include BunkerwebModule

  @@loaded_plugins[BunkerwebWorker::MODULE_ID] = BunkerwebModule.get_object
end
