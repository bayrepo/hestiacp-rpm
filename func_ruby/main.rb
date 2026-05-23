#!/opt/brepo/ruby33/bin/ruby

require "date"
require "envbash"
require "interface"
require "json"
require "csv"

date_internal = DateTime.now
di = date_internal.strftime("%d%m%Y%H%M")
# Internal variables
$HOMEDIR = "/home"
$BACKUP = "/backup"
$BACKUP_GZIP = 9
$BACKUP_DISK_LIMIT = 95
$BACKUP_LA_LIMIT = %x(cat /proc/cpuinfo | grep processor | wc -l)
$RRD_STEP = 300
$BIN = "#{$HESTIA}/bin"
$HESTIA_INSTALL_DIR = "#{$HESTIA}/install/rpm"
$HESTIA_COMMON_DIR = "#{$HESTIA}/install/common"
$HESTIA_BACKUP = "/root/hst_backups/#{di}"
$HESTIA_PHP = "#{$HESTIA}/php/bin/php"
$USER_DATA = "#{$HESTIA}/data/users/#{$user}"
$WEBTPL = "#{$HESTIA}/data/templates/web"
$MAILTPL = "#{$HESTIA}/data/templates/mail"
$DNSTPL = "#{$HESTIA}/data/templates/dns"
$RRD = "#{$HESTIA}/web/rrd"
$SENDMAIL = "#{$HESTIA}/web/inc/mail-wrapper.php"
$HESTIA_GIT_REPO = "https://dev.brepo.ru/bayrepo/hestiacp"
$HESTIA_THEMES = "#{$HESTIA}/web/css/themes"
$HESTIA_THEMES_CUSTOM = "#{$HESTIA}/web/css/themes/custom"
$SCRIPT = File.basename($PROGRAM_NAME)

# Return codes
OK = 0
E_ARGS = 1
E_INVALID = 2
E_NOTEXIST = 3
E_EXISTS = 4
E_SUSPENDED = 5
E_UNSUSPENDED = 6
E_INUSE = 7
E_LIMIT = 8
E_PASSWORD = 9
E_FORBIDEN = 10
E_DISABLED = 11
E_PARSING = 12
E_DISK = 13
E_LA = 14
E_CONNECT = 15
E_FTP = 16
E_DB = 17
E_RRD = 18
E_UPDATE = 19
E_RESTART = 20
E_PERMISSION = 21
E_MODULE = 22

$ARGUMENTS = ""
ARGV.each_with_index do |item, index|
  if !$HIDE.nil? && $HIDE == index
    $ARGUMENTS = "#{$ARGUMENTS} '******'"
  else
    $ARGUMENTS = "#{$ARGUMENTS} #{item}"
  end
end

class File
  class << self
    def append(path, content)
      File.open(path, "a") { |f| f << content }
    end

    def append!(path, content)
      File.open(path, "a") { |f| f << (content + "\n") }
    end
  end
end

def hestia_print_info_message_to_cli(error_message)
  puts "Info: #{error_message}"
end

def hestia_print_error_message_to_cli(error_message)
  puts "Error: #{error_message}"
end

def load_global_bash_variables(*scripts)
  local_arr = {}

  scripts.each do |script|
    EnvBash.load(script, into: local_arr) if File.exist? script
  end
  diff_arr = local_arr.reject { |key, _value| ENV.key? key }

  diff_arr.each do |key, val|
    e_val = val.gsub(/'/) { |_c| "\\'" }
    str_data = "$#{key}='#{e_val}'"
    eval str_data
  end
end

def new_timestamp()
  date = DateTime.now
  $time = date.strftime("%T")
  $date = date.strftime("%d-%m-%Y")
end

def log_event(error_string, args)
  if $time.nil?
    date = DateTime.now
    log_time = date.strftime("%Y-%m-%d %T")
    log_time = "#{log_time} #{File.basename($PROGRAM_NAME)}"
  else
    log_time = "#{$date} #{$time} #{File.basename($PROGRAM_NAME)}"
  end
  code_number = error_string.to_i
  if code_number.zero?
    File.append! "#{$HESTIA}/log/system.log", "#{log_time} #{args}" unless $HESTIA.nil?
  else
    File.append! "#{$HESTIA}/log/error.log", "#{log_time} #{args} [Error #{error_string}]" unless $HESTIA.nil?
  end
end

def check_result(error_code:, error_message:, custom_error: -1, silent: false, callback_func: nil)
  if error_code != OK
    loc_error = custom_error != -1 ? custom_error : error_code
    return callback_func(error_code, error_message) if callback_func

    hestia_print_error_message_to_cli error_message unless silent
    log_event loc_error, $ARGUMENTS
    exit error_code
  end
  OK
end

def check_args(req_params, params, usage)
  if req_params > params.length
    puts "Usage #{File.basename($PROGRAM_NAME)} #{usage}"
    check_result error_code: E_ARGS, error_message: "not enought arguments", silent: true
  else
    OK
  end
end

def check_hestia_demo_mode
  File.open("/usr/local/hestia/conf/hestia.conf") do |f|
    until f.eof?
      item = f.gets.strip
      conf_data = item.split("=").map(&:strip!)
      if conf_data.length > 1 && conf_data[0] == "DEMO_MODE" && conf_data[1].downcase == "yes"
        hestia_print_error_message_to_cli "Unable to perform operation due to security restrictions that are in place."
        exit(1)
      end
    end
  end
end

def hestia_check_privileged_user
  if Process.uid != 0
    hestia_print_error_message_to_cli "Script must run under privileged user"
    log_event E_PERMISSION, $ARGUMENTS
    exit(1)
  end
end

def hestia_format_cli_table(in_array)
  arr_max_len = {}
  in_array.each do |elem|
    elem.each_with_index do |item, index|
      arr_max_len[index] = item.to_s.length unless arr_max_len.key? index
      arr_max_len[index] = item.to_s.length if arr_max_len.key?(index) && (arr_max_len[index] < item.to_s.length)
    end
  end
  in_array.each do |elem|
    elem.each_with_index do |item, index|
      print " %s " % item.to_s.ljust(arr_max_len[index])
    end
    print "\n"
  end
end

def hestia_print_array_of_hashes(in_array = nil, format = "shell", header = nil)
  return if in_array.nil? && (format == "json" || format == "plain" || format == "csv")
  case format
  when "json"
    puts in_array.to_json
  when "plain"
    in_array.each do |item|
      data_wrapper = []
      item.each do |key, val|
        data_wrapper << val.to_s
      end
      puts data_wrapper.join("\t")
    end
  when "csv"
    data_wrapper = in_array.map do |row|
      row.values.to_csv
    end
    puts data_wrapper
  else
    headers = nil
    unless header.nil?
      headers = header.split(",").map(&:strip)
    end
    if !in_array.nil? && headers.nil?
      headers = []
      in_array.first.each_key do |key|
        headers << key.to_s
      end
    end
    data_out = []
    unless headers.nil?
      data_out << headers
      data_out << headers.map { |i| "-" * i.to_s.length }
    end
    unless in_array.nil?
      in_array.each do |val|
        row = []
        headers.each do |item|
          row << if val.key? item
            val[item]
          elsif val.key? item.to_sym
            val[item.to_sym]
          else
            ""
          end
        end
        data_out << row
      end
    end
    hestia_format_cli_table(data_out)
  end
end

def hestia_write_to_config_with_lock(config_file, values, perms = 0600)
  File.open(config_file, File::WRONLY | File::CREAT, perms) do |f|
    f.flock(File::LOCK_EX)
    f.truncate(0)
    values.each { |item| f.puts(item) }
    f.flush
  end
end

def hestia_read_config_with_lock(config_file)
  arr = []
  File.open(config_file, File::RDONLY) do |f|
    f.flock(File::LOCK_SH)
    f.each { |line| arr << line.strip }
  end
  arr
end

def hestia_get_file_key_pair(file, key)
  value = ""
  if File.exist?(file)
    File.open(file, File::RDONLY) do |f|
      f.flock(File::LOCK_SH)
      f.each do |line|
        result = line.strip.split("=", 2)
        if result.length > 1
          k = result[0].strip
          v = result[1].strip
          if k == key
            value = v
            break
          end
        end
      end
    end
  end
  value
end

def hestia_get_file_keys_value(file)
  value = Hash.new
  if File.exist?(file)
    File.open(file, File::RDONLY) do |f|
      f.flock(File::LOCK_SH)
      f.each do |line|
        result = line.strip.split("=", 2)
        if result.length > 1
          k = result[0].strip
          v = result[1].strip
          if k != ""
            value[k] = v
          end
        end
      end
    end
  end
  value
end

def hestia_save_file_key_pair(file, key, value)
  File.open(file, File::RDWR | File::CREAT, 0600) do |f|
    f.flock(File::LOCK_EX)
    f.rewind
    storage = {}
    f.each do |line|
      result = line.strip.split("=", 2)
      if result.length > 1
        k = result[0].strip
        v = result[1].strip
        storage[k] = v
      end
    end
    if value.strip == ""
      if storage.key?(key.strip)
        storage.delete(key.strip)
      end
    else
      storage[key.strip] = value.strip
    end
    f.rewind
    f.truncate(0)
    storage.each do |k, v|
      f.puts("#{k}=#{v}")
    end
  end
end

def hestia_change_sys_config_value(key, value)
  # Privileged access check
  hestia_check_privileged_user unless Process.uid == 0

  config_file = "/usr/local/hestia/conf/hestia.conf"

  if File.exist?(config_file)
    # First pass: read entire file to check if key exists and get all lines
    content = nil

    File.open(config_file, "r") do |f|
      content = f.read
    end

    if content
      lines = content.split("\n")

      # Check if key exists in the configuration file
      existing_line_index = -1

      lines.each_with_index do |line, idx|
        line_stripped = line.strip
        # Skip comment lines
        next if line_stripped.start_with?("#")
        next if line_stripped.empty?

        key_match = line_stripped.match(/^\s*#{Regexp.escape(key)}='\s*(.*?)\s*$/)
        if key_match
          existing_line_index = idx + 1
          break
        end
      end

      if existing_line_index.nil? || existing_line_index == -1
        # Key doesn't exist - append new line to file
        File.open(config_file, "a") do |append_f|
          append_f.puts("#{key}='#{value}'")
        end
        OK
      else
        # Key exists - update value using Ruby operators (in-place edit)
        # Use temporary file for safety and atomic replacement
        temp_file = "#{config_file}.tmp"

        # Second pass: rebuild the content with updated value
        new_lines = []

        lines.each do |line|
          line_stripped = line.strip
          # Skip comment lines
          next if line_stripped.start_with?("#")
          next if line_stripped.empty?

          # Match and replace the key-value pair
          if line.match(/^\s*#{Regexp.escape(key)}='[^']*'/)
            new_lines << "#{key}='#{value}'"
          else
            new_lines << line
          end
        end

        File.open(temp_file, "w") do |output_f|
          new_lines.each { |l| output_f.puts(l) }
        end

        # Atomic file replacement
        File.rename(temp_file, config_file)
        OK
      end
    else
      OK
    end
  else
    check_result error_code: E_NOTEXIST, error_message: "Configuration file #{config_file} does not exist"
  end
end
