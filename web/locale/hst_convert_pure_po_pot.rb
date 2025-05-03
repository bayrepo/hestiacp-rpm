#!/usr/bin/ruby

if ARGV.length()<2
  puts "Use: #{$0} path_to_pure_po po|pot"
  exit 1
end

if ARGV[1] == "po"

  msgid_h = {}
  msgid_id = "111"
  msgid_tmp = ""
  pre_msgid = []

  # Соберем список привязок msgid к файлам
  IO.foreach("hestiacp.pot") do |line|
    pre_msgid << line if line =~ /^#/
    if line =~ /^msgid /
      msgid_tmp = line.split(' ', 2)[1]
      msgid_id = ""
    else
      if line =~ /^msg/
        if msgid_id == ""
          msgid_id = msgid_tmp
          msgid_h[msgid_id]=pre_msgid unless msgid_id == '""'
          pre_msgid=[]
        end
      else
        if msgid_id == ""
          msgid_tmp += line
        end
      end
    end
  end

  # Вставим привязки к файлам перед msgid
  pre_msgid_w = []
  msgid_id = "111"
  msgid_tmp = ""
  f = File.open("#{ARGV[0]}.new", "w")
  if f.nil?
    puts "Error opening file #{ARGV[0]}.new"
    exit 1
  end
  IO.foreach("#{ARGV[0]}") do |line|
    if line =~ /^msgid /
      msgid_tmp = line.split(' ', 2)[1]
      msgid_id = ""
      pre_msgid_w = []
      pre_msgid_w << line
    else
      if line =~ /^msg/
        if msgid_id == ""
          msgid_id = msgid_tmp
          if msgid_id != '""'
            if msgid_h[msgid_id] != nil 
              msgid_h[msgid_id].each do |item|
                f.puts item
              end
            end
          end
          pre_msgid_w.each do |item|
            f.puts item
          end
          f.puts line
        else
          f.puts line
        end
      else
        if msgid_id == ""
          msgid_tmp += line
          pre_msgid_w << line
        else
          f.puts line
        end
      end
    end
  end

  f.close()

else
  msgid_id = "111"
  msgid_tmp = ""
  post_msgid = {}

  # Соберем список привязок msgid к файлам
  IO.foreach("#{ARGV[0]}") do |line|
    if line =~ /^msgid /
      msgid_tmp = line.split(' ', 2)[1]
      msgid_id = ""
    else
      if line =~ /^msg/
        if msgid_id == ""
          msgid_id = msgid_tmp
        end
        if msgid_id != '""'
          if post_msgid[msgid_id].nil?
            post_msgid[msgid_id] = []
          end
          post_msgid[msgid_id] << line
        end
      else
        if msgid_id == ""
          msgid_tmp += line
        else
          if line.strip != ""
            post_msgid[msgid_id] << line
          else
            msgid_id = ""
            msgid_tmp = ""
          end
        end
      end
    end
  end

  # Вставим привязки к файлам перед msgid
  msgid_id = "111"
  msgid_tmp = ""
  msgid_check = {}
  f = File.open("#{ARGV[0]}.new", "w")
  if f.nil?
    puts "Error opening file #{ARGV[0]}.new"
    exit 1
  end
  IO.foreach("hestiacp.pot") do |line|
    if line =~ /^msgid /
      msgid_tmp = line.split(' ', 2)[1]
      msgid_id = ""
      f.puts line
    else
      if line =~ /^msgstr/
        if msgid_id == ""
          msgid_id = msgid_tmp
        end
        if msgid_check[msgid_id].nil?
          msgid_check[msgid_id]="1"
          if post_msgid[msgid_id].nil?
            f.puts line
          else
            if msgid_id.strip.gsub("\n", "") != "\"\""
              post_msgid[msgid_id].each do |item|
                f.puts item
              end
            end
          end
        end
      else
        if msgid_id == ""
          msgid_tmp += line
          f.puts line
        else
          f.puts line
        end
      end
    end
  end

  f.close()
end

exit 0