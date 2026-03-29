#!/usr/bin/bash
# Adding php wrapper
user="$1"
domain="$2"
ip="$3"
home_dir="$4"
docroot="$5"
php_path="$6"

wrapper_script="#!$php_path -cphp5-cgi.ini"
wrapper_file="$home_dir/$user/web/$domain/cgi-bin/php"
wrapper_dir="/var/www/$user/$domain/cgi-bin"
wrapper_file2="$wrapper_dir/php"

echo "$wrapper_script" > $wrapper_file
chown $user:$user $wrapper_file
chmod -f 751 $wrapper_file

mkdir -p $wrapper_dir

echo "$wrapper_script" > $wrapper_file2
chown $user:$user $wrapper_file2
chown $user:$user $wrapper_dir
chmod -f 751 $wrapper_file2

exit 0
