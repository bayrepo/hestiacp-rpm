#!/opt/brepo/ruby33/bin/ruby

require 'pathname'
require 'fileutils'
require 'digest'

class UpdateWorker < Kernel::ModuleCoreWorker
  MODULE_ID = "update_module"

  def info
    {
      ID: 6,
      NAME: MODULE_ID,
      DESCR: "Module for updating HestiaCP data and templates",
      REQ: "",
      CONF: "yes",
    }
  end

  def file_changed?(new_file, old_file)
    return true unless File.exist?(old_file)
    new_hash = Digest::SHA256.file(new_file).hexdigest
    old_hash = Digest::SHA256.file(old_file).hexdigest
    new_hash != old_hash
  end

  def get_templates_map()
    { :templates=>
      [
        {:new=>"/usr/local/hestia/install/rpm/templates/web/awstats", :old=>"/usr/local/hestia/data/templates/web/awstats"},
        {:new=>"/usr/local/hestia/install/rpm/templates/web/httpd", :old=>"/usr/local/hestia/data/templates/web/httpd"},
        {:new=>"/usr/local/hestia/install/rpm/templates/web/nginx", :old=>"/usr/local/hestia/data/templates/web/nginx"},
        {:new=>"/usr/local/hestia/install/rpm/templates/web/php-fpm", :old=>"/usr/local/hestia/data/templates/web/php-fpm"}
      ]
    }
  end

  # New helper method to get list of changed template files
  def get_changed_template_files
    templates_map = get_templates_map()[:templates]
    result = []
    templates_map.each do |tpl|
      new_dir = tpl[:new]
      old_dir = tpl[:old]
      Dir.glob(File.join(new_dir, '**', '*')).each do |new_file|
        next if File.directory?(new_file)
        rel_path = Pathname.new(new_file).relative_path_from(Pathname.new(new_dir)).to_s
        old_file = File.join(old_dir, rel_path)
        result << [new_dir, new_file, old_file] if file_changed?(new_file, old_file)
      end
    end
    result
  end

  def command(args)
    return log_return("Not enough arguments. Needed command") if args.length < 1
    log_file = get_log

    m_command = args[0].strip
    case m_command
    when "synctemplates"
      result = get_changed_template_files
      result.each do |new_dir, new_file, old_file|
        if !File.exist?(old_file)
          FileUtils.cp(new_file, old_file)
        else
          stat = File.stat(old_file)
          uid = stat.uid
          gid = stat.gid
          mode = stat.mode & 0o7777
          FileUtils.cp(new_file, old_file)
          File.chown(uid, gid, old_file)
          File.chmod(mode, old_file)
        end
      end
      ACTION_OK
    when "listsynctemplates"
      format = (args[1].nil? ? "shell" : args[1].strip)
      list = get_changed_template_files
      result = []
      result = list.map do |new_dir, new_file, old_file|
        file_name = Pathname.new(new_file).relative_path_from(Pathname.new(new_dir)).to_s
        dir_name = File.basename(new_dir)
        relative_path = Pathname.new(new_file).relative_path_from(Pathname.new(new_dir)).to_s
        file_name = File.join(dir_name, relative_path)
        {
          "FILE_NAME" => file_name,
          "NEW_SIZE" => File.size(new_file),
          "OLD_SIZE" => File.exist?(old_file) ? File.size(old_file) : "-"
        }
      end

      hestia_print_array_of_hashes(result, format, "FILE_NAME,NEW_SIZE,OLD_SIZE")
      ACTION_OK
    when "help"
      puts "#{$0} update_module COMMAND [json|csv|plain]"
      puts "COMMANDS:"
      puts "  synctemplates - sync web templates"
      puts "  listsynctemplates - show changed web templates"
      puts "  help - help"
      ACTION_OK
    else
      log_return("Unknown command. #{args}")
    end
  end

  implements IPluginInterface
end

module UpdateModule
  def get_object
    Proc.new { UpdateWorker.new }
  end

  module_function :get_object
end

class Kernel::PluginConfiguration
  include UpdateModule

  @@loaded_plugins[UpdateWorker::MODULE_ID] = UpdateModule.get_object
end
