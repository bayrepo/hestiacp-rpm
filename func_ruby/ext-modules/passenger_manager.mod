#!/opt/brepo/ruby33/bin/ruby

require "shell"

class PassengerWorker < Kernel::ModuleCoreWorker
  MODULE_ID = "passenger_manager"

  def check_domains_with_passenger
    dom_file = get_module_conf("domains.conf")
    val = hestia_get_file_keys_value(dom_file)
    if val.empty?
      true
    else
      false
    end
  end

  def info
    {
      ID: 2,
      NAME: MODULE_ID,
      DESCR: "Added passenger support for nginx",
      REQ: "",
      CONF: "yes",
    }
  end

  def enable
    log_file = get_log
    f_inst_pp = get_module_paydata("passenger_installer.yml")
    f_uninst_pp = get_module_paydata("passenger_uninstaller.yml")
    if !check
      inf = info
      log("Req error, needed #{inf[:REQ]}")
      "Req error, needed #{inf[:REQ]}"
    else
      begin
        prepare_default_ruby_conf
        log("install packages for passenger + nginx support: /usr/bin/ansible-playbook -vv #{f_inst_pp}")
        result_action = `LC_ALL=C.UTF-8 /usr/bin/ansible-playbook -vv "#{f_inst_pp}" 2>&1`
        ex_status = $?.exitstatus
        if ex_status.to_i == 0 || ex_status.to_i == 2
          log(result_action)
          super
        else
          log(result_action)
          log("Try to disable action: /usr/bin/ansible-playbook -vv #{f_uninst_pp}")
          result_action = `LC_ALL=C.UTF-8 /usr/bin/ansible-playbook -vv "#{f_uninst_pp}" 2>&1`
          "module installation error. See log #{log_file}"
        end
      rescue => e
        log("module installation error #{e.message} #{e.backtrace.first}")
        "module installation error. See log #{log_file}"
      end
    end
  end

  def disable
    log_file = get_log
    f_uninst_pp = get_module_paydata("passenger_uninstaller.yml")
    if !check_domains_with_passenger
      return log_return("Presents domains with passenger support disable it first")
    end
    begin
      log("uninstall packages for passenger + nginx support")
      log("Try to disable action: /usr/bin/ansible-playbook -vv #{f_uninst_pp}")
      result_action = `LC_ALL=C.UTF-8 /usr/bin/ansible-playbook -vv "#{f_uninst_pp}" 2>&1`
      ex_status = $?.exitstatus
      if ex_status.to_i == 0 || ex_status.to_i == 2
        log(result_action)
        super
      else
        log(result_action)
        "module installation error. See log #{log_file}"
      end
    rescue => e
      log("module installation error #{e.message} #{e.backtrace.first}")
      "module installation error. See log #{log_file}"
    end
  end

  def prepare_default_ruby_conf
    ruby_conf_rubys = get_module_conf("rubys.conf")
    return if File.exist?(ruby_conf_rubys)

    arr = ["/usr/bin/ruby", "/opt/brepo/ruby33/bin/ruby"]
    hestia_write_to_config_with_lock(ruby_conf_rubys, arr)
  end

  def return_rubys_from_conf
    arr = []
    ruby_conf_rubys = get_module_conf("rubys.conf")
    return arr unless File.exist?(ruby_conf_rubys)

    hestia_read_config_with_lock(ruby_conf_rubys)
  end

  def command(args)
    return log_return("Not enough arguments. Needed command") if args.length < 1

    m_command = args[0].strip
    case m_command
    when "get_rubys"
      result = return_rubys_from_conf.map { |item| { "RUBY" => item } }
      format = (args[1].nil? ? "shell" : args[1].strip)
      hestia_print_array_of_hashes(result, format, "RUBY")
      ACTION_OK
    when "add_ruby"
      path = args[1]
      if path.nil?
        log_return("Path to ruby should be specified. #{args}")
      else
        path = path.strip
        if File.exist?(path)
          rubys = return_rubys_from_conf
          unless rubys.include? path
            rubys << path
            ruby_conf_rubys = get_module_conf("rubys.conf")
            hestia_write_to_config_with_lock(ruby_conf_rubys, rubys)
          end
          ACTION_OK
        else
          log_return("File #{path} doesn't exists")
        end
      end
    when "del_ruby"
      path = args[1]
      if path.nil?
        log_return("Path to ruby should be specified. #{args}")
      else
        path = path.strip
        rubys = return_rubys_from_conf
        if rubys.include? path
          rubys.delete(path)
          ruby_conf_rubys = get_module_conf("rubys.conf")
          hestia_write_to_config_with_lock(ruby_conf_rubys, rubys)
        end
        ACTION_OK
      end
    when "set_user_ruby"
      domain = args[1]
      ruby_ver = args[2]
      log_mod = args[3]
      if domain.nil? || ruby_ver.nil?
        log_return("Domain or ruby version should be specified. #{args}")
      else
        if File.exist?(ruby_ver)
          dom_file = get_module_conf("domains.conf")
          if !log_mod.nil? && log_mod.to_s.strip == "on"
            ruby_ver = "#{ruby_ver}|on"
          end
          hestia_save_file_key_pair(dom_file, domain, ruby_ver)
          ACTION_OK
        else
          log_return("Ruby path doesn't exists. #{ruby_ver}. Args #{args}")
        end
      end
    when "disable_user"
      domain = args[1]
      if domain.nil?
        log_return("Domain should be specified. #{args}")
      else
        dom_file = get_module_conf("domains.conf")
        hestia_save_file_key_pair(dom_file, domain, "")
        ACTION_OK
      end
    when "get_user_ruby"
      domain = args[1]
      if domain.nil?
        log_return("Domain should be specified. #{args}")
      else
        dom_file = get_module_conf("domains.conf")
        format = (args[2].nil? ? "shell" : args[2].strip)
        val = hestia_get_file_key_pair(dom_file, domain)
        val_spl = val.split("|", 2)
        result = Hash.new
        result["RUBY"] = val_spl[0]
        result["LOG"] = (val_spl.length > 1 ? val_spl[1] : "off")
        a_result = []
        a_result << result
        hestia_print_array_of_hashes(a_result, format, "RUBY,LOG")
        ACTION_OK
      end
    when "list_users_ruby"
      dom_file = get_module_conf("domains.conf")
      format = (args[1].nil? ? "shell" : args[1].strip)
      val = hestia_get_file_keys_value(dom_file)
      result = Array.new
      val.each do |key, value|
        vv = value.split("|", 2)
        result << { "DOMAIN" => key, "RUBY" => vv[0], "LOG" => (vv.length > 1 ? vv[1] : "off") }
      end
      hestia_print_array_of_hashes(result, format, "DOMAIN,RUBY,LOG")
      ACTION_OK
    when "get_tpl_path"
      result = [{ "RUBY_TPL" => get_module_paydata_dir }]
      format = (args[1].nil? ? "shell" : args[1].strip)
      hestia_print_array_of_hashes(result, format, "RUBY_TPL")
      ACTION_OK
    when "help"
      puts "#{$0} passenger_manager COMMAND [OPTIONS] [json|csv|plain]"
      puts "COMMANDS:"
      puts "  get_rubys - list all available rubys pathes"
      puts "  add_ruby [full_path_to_ruby_binary] - add ruby to list"
      puts "  del_ruby [full_path_to_ruby] - delete ruby from list"
      puts "  set_user_ruby [domain] [full_path_to_ruby_binary] [logging on or mpty] - set ruby for domain"
      puts "  disable_user [domain] - delete ruby for domain"
      puts "  get_user_ruby [domain] - show ruby path for domain or empty if not set"
      puts "  list_users_ruby - show rubys for all domains"
      puts "  get_tpl_path - show path for module's templates"
      puts "  help - help"
      ACTION_OK
    else
      log_return("Unknown command. #{args}")
    end
  end

  implements IPluginInterface
end

module PassengerModule
  def get_object
    Proc.new { PassengerWorker.new }
  end

  module_function :get_object
end

class Kernel::PluginConfiguration
  include PassengerModule

  @@loaded_plugins[PassengerWorker::MODULE_ID] = PassengerModule.get_object
end
