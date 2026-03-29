#!/bin/bash

# ======================================================== #
#
# Hestia Control Panel Installer for RHEL based OS
# https://hestiadocs.brepo.ru/
#
# Currently Supported Versions:
# Red Hat Enterprise Linux based distros
#
# ======================================================== #

#----------------------------------------------------------#
#                  Variables&Functions                     #
#----------------------------------------------------------#
export PATH=$PATH:/sbin
VERSION='rhel'
HESTIA='/usr/local/hestia'
LOG="/root/hst_install_backups/hst_install-$(date +%d%m%Y%H%M).log"
memory=$(grep 'MemTotal' /proc/meminfo | tr ' ' '\n' | grep [0-9])
hst_backups="/root/hst_install_backups/$(date +%d%m%Y%H%M)"
spinner="/-\|"
os='rhel'
arch="$(arch)"
type=$(grep "^ID=" /etc/os-release | cut -f 2 -d '"')
VERSION=$type

# TODO: Not sure if condition below is required
if [[ "$type" =~ ^(rhel|almalinux|eurolinux|ol|rocky|centos|msvsphere)$ ]]; then
	release=$(rpm --eval='%rhel')
fi

if [ "$release" -lt 8 ]; then
  echo "Unsupported version of OS"
fi
HESTIA_INSTALL_DIR="$HESTIA/install/rpm"
HESTIA_COMMON_DIR="$HESTIA/install/common"
VERBOSE='no'

# Define software versions
HESTIA_INSTALL_VER='1.9.6.rpm-alpha'

# Dependencies
mariadb_v="10.11"
multiphp_v=("74" "80" "81" "82" "83" "84" "85")

# default PHP version
php_v="82"

php_modules_install="mysqlnd mysqli pdo_mysql pgsql pdo sqlite pdo_sqlite pdo_pgsql imap ldap zip opcache xmlwriter xmlreader gd intl pspell"
php_modules_disable=""
mod_php="enable"

software="nginx
  httpd.${arch} httpd-tools httpd-itk mod_fcgid mod_suphp mod_ssl
  MariaDB-client MariaDB-common MariaDB-server
  mysql.${arch} mysql-common mysql-server
  postgresql-server postgresql sqlite.${arch}
  vsftpd proftpd bind
  exim clamd clamav spamassassin dovecot dovecot-pigeonhole
  hestia hestia-nginx hestia-php
  rrdtool quota e2fsprogs fail2ban dnsutils util-linux cronie expect perl-Mail-DKIM unrar vim acl sysstat
  rsyslog openssh-clients util-linux ipset zstd systemd-timesyncd jq awstats perl-Switch net-tools mc flex
  whois git idn2 unzip zip sudo bc ftp lsof unzip"


installer_dependencies="gnupg2 policycoreutils wget ca-certificates"

# Defining help function
help() {
	echo "Usage: $0 [OPTIONS]
  -a, --apache            Install Apache             [yes|no]   default: yes
  -w, --phpfpm            Install PHP-FPM            [yes|no]   default: yes
  -o, --multiphp          Install Multi-PHP          [yes|no]   default: no
  -v, --vsftpd            Install Vsftpd             [yes|no]   default: yes
  -j, --proftpd           Install ProFTPD            [yes|no]   default: no
  -k, --named             Install Bind               [yes|no]   default: yes
  -m, --mysql             Install MariaDB            [yes|no]   default: yes
  -M, --mysql-classic     Install MySQL 8            [yes|no]   default: no
  -g, --postgresql        Install PostgreSQL         [yes|no]   default: no
  -x, --exim              Install Exim               [yes|no]   default: yes
  -z, --dovecot           Install Dovecot            [yes|no]   default: yes
  -Z, --sieve             Install Sieve              [yes|no]   default: no
  -c, --clamav            Install ClamAV             [yes|no]   default: no
  -t, --spamassassin      Install SpamAssassin       [yes|no]   default: yes
  -i, --firewall          Install Iptables           [yes|no]   default: yes
  -b, --fail2ban          Install Fail2ban           [yes|no]   default: yes
  -q, --quota             Filesystem Quota           [yes|no]   default: no
  -d, --api               Activate API               [yes|no]   default: yes
  -r, --port              Change Backend Port                   default: 8083
  -l, --lang              Default language                      default: en
  -y, --interactive       Interactive install        [yes|no]   default: yes
  -I, --nopublicip        Use local ip               [yes|no]   default: yes
  -u, --uselocalphp       Use PHP from local repo    [yes|no]   default: no
  -C, --usemirrorclamav   Use mirrored clamav        [yes|no]   default: no
  -s, --hostname          Set hostname
  -e, --email             Set admin email
  -p, --password          Set admin password
  -R, --with-rpms         Path to Hestia rpms
  -f, --force             Force installation         [yes|no]   default: no
  -D, --devel             Install Hestia from devel repo
  -h, --help              Print this help

  Example: bash $0 -e demo@hestiacp.com -p p4ssw0rd --multiphp yes"
	exit 1
}

# Defining file download function
download_file() {
	wget $1 -q --show-progress --progress=bar:force
}

# Defining password-gen function
gen_pass() {
	matrix=$1
	length=$2
	if [ -z "$matrix" ]; then
		matrix="A-Za-z0-9"
	fi
	if [ -z "$length" ]; then
		length=16
	fi
	head /dev/urandom | tr -dc $matrix | head -c$length
}

# Defining return code check function
check_result() {
	if [ $1 -ne 0 ]; then
		echo "Error: $2"
		exit $1
	fi
}

# Defining function to set default value
set_default_value() {
	eval variable=\$$1
	if [ -z "$variable" ]; then
		eval $1=$2
	fi
	if [ "$variable" != 'yes' ] && [ "$variable" != 'no' ]; then
		eval $1=$2
	fi
}

# Defining function to set default language value
set_default_lang() {
	if [ -z "$lang" ]; then
		eval lang=$1
	fi
	lang_list="sq ar az bg bn bs ca cs da de el en es fa fi fr hr hu id it ja ka ku ko nl no pl pt pt-br ro ru sk sr sv th tr uk ur vi zh-cn zh-tw"
	if ! (echo $lang_list | grep -w $lang > /dev/null 2>&1); then
		eval lang=$1
	fi
}

# Define the default backend port
set_default_port() {
	if [ -z "$port" ]; then
		eval port=$1
	fi
}

# Write configuration KEY/VALUE pair to $HESTIA/conf/hestia.conf
write_config_value() {
	local key="$1"
	local value="$2"
	if [ -e $HESTIA/conf/hestia.conf ]; then
		echo "$key='$value'" >> $HESTIA/conf/hestia.conf
	fi
}

# Sort configuration file values
# Write final copy to $HESTIA/conf/hestia.conf for active usage
# Duplicate file to $HESTIA/conf/defaults/hestia.conf to restore known good installation values
sort_config_file() {
	sort $HESTIA/conf/hestia.conf -o /tmp/updconf
	mv $HESTIA/conf/hestia.conf $HESTIA/conf/hestia.conf.bak
	mv /tmp/updconf $HESTIA/conf/hestia.conf
	rm -f $HESTIA/conf/hestia.conf.bak
	if [ ! -d "$HESTIA/conf/defaults/" ]; then
		mkdir -p "$HESTIA/conf/defaults/"
	fi
	cp $HESTIA/conf/hestia.conf $HESTIA/conf/defaults/hestia.conf
}

# Validate hostname according to RFC1178
validate_hostname() {
	# remove extra .
	servername=$(echo "$servername" | sed -e "s/[.]*$//g")
	servername=$(echo "$servername" | sed -e "s/^[.]*//")
	if [[ $(echo "$servername" | grep -o "\." | wc -l) -gt 1 ]] && [[ ! $servername =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
		# Hostname valid
		return 1
	else
		# Hostname invalid
		return 0
	fi
}

validate_email() {
	if [[ ! "$email" =~ ^[A-Za-z0-9._%+-]+@[[:alnum:].-]+\.[A-Za-z]{2,63}$ ]]; then
		# Email invalid
		return 0
	else
		# Email valid
		return 1
	fi
}

get_link_name(){
    str_result=""
    ext_name=$1
    pattern=("01-ioncube.ini" "10-opcache.ini" "20-bcmath.ini" "20-bz2.ini" "20-calendar.ini" "20-ctype.ini" "20-curl.ini" "20-dba.ini" "20-dom.ini" "20-enchant.ini" "20-exif.ini" "20-ffi.ini" "20-fileinfo.ini" "20-ftp.ini" "20-gd.ini" "20-gettext.ini" "20-gmp.ini" "20-iconv.ini" "20-imap.ini" "20-intl.ini" "20-ldap.ini" "20-mbstring.ini" "20-mysqlnd.ini" "20-odbc.ini" "20-pdo.ini" "20-phar.ini" "20-posix.ini" "20-pspell.ini" "20-shmop.ini" "20-simplexml.ini" "20-sockets.ini" "20-sqlite3.ini" "20-sysvmsg.ini" "20-sysvsem.ini" "20-sysvshm.ini" "20-tokenizer.ini" "20-xml.ini" "20-xmlwriter.ini" "20-xsl.ini" "30-mysqli.ini" "30-pdo_dblib.ini" "30-pdo_firebird.ini" "30-pdo_mysql.ini" "30-pdo_odbc.ini" "30-pdo_sqlite.ini" "30-xmlreader.ini" "30-zip.ini" "40-apcu.ini" "40-ast.ini" "40-bolt.ini" "40-brotli.ini" "40-geos.ini" "40-imagick.ini" "40-libvirt-php.ini" "40-lz4.ini" "40-pdlib.ini")
    check="^[0-9]+-${ext_name}.ini"
    for str in ${pattern[@]}; do
	if [[ $str =~ $check ]]; then
	    str_result="$str"
	    break
	fi
    done
    if [ -z "$str_result" ]; then
	echo "50-${ext_name}.ini"
    else
	echo "$str_result"
    fi
}


enable_local_php_extension(){
	vers=$1
	ext_name=$2
	ext_nm=$(get_link_name "$ext_name")
	if [ -e "/opt/brepo/php${vers}/etc/php.d/" ]; then
		if [ ! -e "/opt/brepo/php${vers}/etc/php.d/${ext_nm}" -a -e "/opt/brepo/php${vers}/etc/mod-installed/${ext_name}.ini" ]; then
			pushd "/opt/brepo/php${vers}/etc/php.d/"
			ln -s ../mod-installed/${ext_name}.ini /opt/brepo/php${vers}/etc/php.d/${ext_nm}
			popd
		fi
	fi
}

disable_local_php_extension(){
	vers=$1
	ext_name=$2
	ext_nm=$(get_link_name "$ext_name")
	if [ -e "/opt/brepo/php${vers}/etc/php.d/" ]; then
		if [ -e "/opt/brepo/php${vers}/etc/php.d/${ext_nm}" ]; then
			rm -f "/opt/brepo/php${vers}/etc/php.d/${ext_nm}"
		fi
	fi
}

enable_mod_php(){
	vers=$1
	if [ -e "/etc/httpd/conf.d.prep/php${vers}.conf" ]; then
		ln -s /etc/httpd/conf.d.prep/php${vers}.conf /etc/httpd/conf.h.d/mod_php${vers}.conf
	fi
}

#----------------------------------------------------------#
#                    Verifications                         #
#----------------------------------------------------------#

# Creating temporary file
tmpfile=$(mktemp -p /tmp)

# Translating argument to --gnu-long-options
for arg; do
	delim=""
	case "$arg" in
		--apache) args="${args}-a " ;;
		--phpfpm) args="${args}-w " ;;
		--vsftpd) args="${args}-v " ;;
		--proftpd) args="${args}-j " ;;
		--named) args="${args}-k " ;;
		--mysql) args="${args}-m " ;;
		--mysql-classic) args="${args}-M " ;;
		--postgresql) args="${args}-g " ;;
		--exim) args="${args}-x " ;;
		--dovecot) args="${args}-z " ;;
		--sieve) args="${args}-Z " ;;
		--clamav) args="${args}-c " ;;
		--usemirrorclamav) args="${args}-C " ;;
		--spamassassin) args="${args}-t " ;;
		--firewall) args="${args}-i " ;;
		--fail2ban) args="${args}-b " ;;
		--multiphp) args="${args}-o " ;;
		--quota) args="${args}-q " ;;
		--port) args="${args}-r " ;;
		--lang) args="${args}-l " ;;
		--interactive) args="${args}-y " ;;
		--api) args="${args}-d " ;;
		--hostname) args="${args}-s " ;;
		--email) args="${args}-e " ;;
		--password) args="${args}-p " ;;
		--force) args="${args}-f " ;;
		--with-debs) args="${args}-D " ;;
		--help) args="${args}-h " ;;
		--nopublicip) args="${args}-I " ;;
		--uselocalphp) args="${args}-u" ;;
		--devel) args="${args}-D" ;;
		*)
			[[ "${arg:0:1}" == "-" ]] || delim="\""
			args="${args}${delim}${arg}${delim} "
			;;
	esac
done
eval set -- "$args"

use_devel=""

# Parsing arguments
while getopts "u:I:a:w:v:j:k:m:M:g:d:x:z:Z:c:C:t:i:b:r:o:q:l:y:s:e:p:R:f:Dh" Option; do
	case $Option in
		a) apache=$OPTARG ;;       # Apache
		w) phpfpm=$OPTARG ;;       # PHP-FPM
		o) multiphp=$OPTARG ;;     # Multi-PHP
		v) vsftpd=$OPTARG ;;       # Vsftpd
		j) proftpd=$OPTARG ;;      # Proftpd
		k) named=$OPTARG ;;        # Named
		m) mysql=$OPTARG ;;        # MariaDB
		M) mysqlclassic=$OPTARG ;; # MySQL
		g) postgresql=$OPTARG ;;   # PostgreSQL
		x) exim=$OPTARG ;;         # Exim
		z) dovecot=$OPTARG ;;      # Dovecot
		Z) sieve=$OPTARG ;;        # Sieve
		c) clamd=$OPTARG ;;        # ClamAV
		C) clamdm="yes"  ;;        # ClamAV Mirrored
		t) spamd=$OPTARG ;;        # SpamAssassin
		i) iptables=$OPTARG ;;     # Iptables
		b) fail2ban=$OPTARG ;;     # Fail2ban
		q) quota=$OPTARG ;;        # FS Quota
		r) port=$OPTARG ;;         # Backend Port
		l) lang=$OPTARG ;;         # Language
		d) api=$OPTARG ;;          # Activate API
		y) interactive=$OPTARG ;;  # Interactive install
		s) servername=$OPTARG ;;   # Hostname
		e) email=$OPTARG ;;        # Admin email
		p) vpass=$OPTARG ;;        # Admin password
		R) withrpms=$OPTARG ;;     # Hestia rpms path
		f) force=$OPTARG ;;          # Force install
		h) help ;;                 # Help
		I) nopublicip=$OPTARG ;;   # NoPublicIP
		u) uselocalphp=$OPTARG ;;  # UseLocalPHP
		D) use_devel="y" ;;
		*) help ;;                 # Print help (default)
	esac
done

# Defining default software stack
set_default_value 'nginx' 'yes'
set_default_value 'apache' 'yes'
set_default_value 'phpfpm' 'yes'
set_default_value 'multiphp' 'no'
set_default_value 'vsftpd' 'yes'
set_default_value 'proftpd' 'no'
set_default_value 'named' 'yes'
set_default_value 'mysql' 'yes'
set_default_value 'mysql8' 'no'
set_default_value 'postgresql' 'no'
set_default_value 'exim' 'yes'
set_default_value 'dovecot' 'yes'
set_default_value 'sieve' 'no'
if [ $memory -lt 1500000 ]; then
	set_default_value 'clamd' 'no'
	set_default_value 'spamd' 'no'
elif [ $memory -lt 3000000 ]; then
	set_default_value 'clamd' 'no'
	set_default_value 'spamd' 'yes'
else
	set_default_value 'clamd' 'no'
	set_default_value 'spamd' 'yes'
fi
set_default_value 'iptables' 'yes'
set_default_value 'fail2ban' 'yes'
set_default_value 'quota' 'no'
set_default_value 'interactive' 'yes'
set_default_value 'api' 'yes'
set_default_value 'nopublicip' 'no'
set_default_port '8083'
set_default_lang 'en'
set_default_value 'uselocalphp' 'no'

if [ "$force" != "yes" ]; then
	force="no"
fi

# Checking software conflicts
if [ "$proftpd" = 'yes' ]; then
	vsftpd='no'
fi
if [ "$exim" = 'no' ]; then
	clamd='no'
	spamd='no'
	dovecot='no'
fi
if [ "$dovecot" = 'no' ]; then
	sieve='no'
fi
if [ "$iptables" = 'no' ]; then
	fail2ban='no'
fi
if [ "$apache" = 'no' ]; then
	phpfpm='yes'
fi
if [ "$mysql" = 'yes' ] && [ "$mysql8" = 'yes' ]; then
	mysql='no'
fi

# Checking root permissions
if [ "x$(id -u)" != 'x0' ]; then
	check_result 1 "Script can be run executed only by root"
fi

if [ -d "/usr/local/hestia" ] || rpm -q hestia &>/dev/null; then
	check_result 1 "Hestia install detected. Unable to continue"
    exit 1
fi

# Checking admin user account
if [ -n "$(grep ^admin: /etc/passwd /etc/group)" ] && [ -z "$force" ]; then
	echo 'Please remove admin user account before proceeding.'
	echo 'If you want to do it automatically run installer with -f option:'
	echo -e "Example: bash $0 --force\n"
	check_result 1 "User admin exists"
fi


# Clear the screen once launch permissions have been verified
clear

# Welcome message
echo "Welcome to the Hestia Control Panel installer!"
echo
echo "Please wait, the installer is now checking for missing dependencies..."
echo

# DNF config-manager plugin isn't installed by defaut
dnf -qy install dnf-plugins-core

# enable dev repo
if [ $release -eq 8 ]; then
  dnf config-manager --set-enabled powertools
else
  dnf config-manager --set-enabled crb
fi
# Install EPEL Repo
dnf install -y epel-release

# Creating backup directory
mkdir -p "$hst_backups"

# Pre-install packages
echo "[ * ] Installing dependencies..."
dnf -y install $installer_dependencies >> $LOG
check_result $? "Package installation failed, check log file for more details."

# Disable SELinux
if [ -e /etc/selinux/config ]; then
    sed 's/^SELINUX=.*/SELINUX=disabled/' -i /etc/selinux/config
    grubby --update-kernel ALL --args selinux=0
fi
setenforce 0

# Check installed packages
tmpfile=$(mktemp -p /tmp)
dnf list installed > $tmpfile
conflicts_pkg="exim mariadb-server httpd nginx hestia postfix"

# Drop postfix from the list if exim should not be installed
if [ "$exim" = 'no' ]; then
	conflicts_pkg=$(echo $conflicts_pkg | sed 's/postfix//g' | xargs)
fi

for pkg in $conflicts_pkg; do
	if [ -n "$(grep $pkg $tmpfile)" ]; then
		conflicts="$pkg* $conflicts"
	fi
done
rm -f $tmpfile
if [ -n "$conflicts" ] && [ -z "$force" ]; then
	echo '!!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!!'
	echo
	echo 'WARNING: The following packages are already installed'
	echo "$conflicts"
	echo
	echo 'It is highly recommended that you remove them before proceeding.'
	echo
	echo '!!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!!'
	echo
	read -p 'Would you like to remove the conflicting packages? [y/n] ' answer
	if [ "$answer" = 'y' ] || [ "$answer" = 'Y' ]; then
		dnf remove $conflicts -y
		check_result $? 'dnf remove failed'
		unset $answer
	else
		check_result 1 "Hestia Control Panel should be installed on a clean server."
	fi
fi

case $arch in
	x86_64)
		ARCH="amd64"
		;;
	aarch64)
		ARCH="arm64"
		;;
	*)
		echo
		echo -e "\e[91mInstallation aborted\e[0m"
		echo "===================================================================="
		echo -e "\e[33mERROR: $arch is currently not supported!\e[0m"
		echo -e "\e[33mPlease verify the achitecture used is currenlty supported\e[0m"
		echo ""
		echo -e "\e[33mhttps://raw.githubusercontent.com/bayrepo/hestiacp-rpm/refs/heads/rhel-version/README.md\e[0m"
		echo ""
		check_result 1 "Installation aborted"
		;;
esac

#----------------------------------------------------------#
#                       Brief Info                         #
#----------------------------------------------------------#

install_welcome_message() {
	DISPLAY_VER=$(echo $HESTIA_INSTALL_VER | sed "s|-alpha||g" | sed "s|-beta||g")
	echo
	echo '          _   _           _   _        ____ ____                        '
	echo '         | | | | ___  ___| |_(_) __ _ / ___|  _ \   _  _ .  .           '
	echo '         | |_| |/ _ \/ __| __| |/ _` | |   | |_) | | \| \|\/|           '
	echo '         |  _  |  __/\__ \ |_| | (_| | |___|  __/  |_/|_/|  |           '
	echo '         |_| |_|\___||___/\__|_|\__,_|\____|_|     | \|  |  |           '
	echo "                                                                        "
	echo "                  Hestia Control Panel(rpm edition)                     "
	if [[ "$HESTIA_INSTALL_VER" =~ "beta" ]]; then
		echo "                              BETA RELEASE                          "
	fi
	if [[ "$HESTIA_INSTALL_VER" =~ "alpha" ]]; then
		echo "                          DEVELOPMENT SNAPSHOT                      "
		echo "                          USE AT YOUR OWN RISK                      "
	fi
	echo "                                  ${DISPLAY_VER}                        "
	echo "                          hestiadocs.brepo.ru                           "
	echo "                  Original: www.hestiacp.com                            "
	echo
	echo "========================================================================"
	echo
	echo "Thank you for downloading Hestia Control Panel! In a few moments,"
	echo "we will begin installing the following components on your server:"
	echo
}

# Printing nice ASCII logo
clear
install_welcome_message

# Web stack
echo '   - NGINX Web / Proxy Server'
if [ "$apache" = 'yes' ]; then
	echo '   - Apache Web Server (as backend)'
fi
if [ "$phpfpm" = 'yes' ] && [ "$multiphp" = 'no' ]; then
	echo '   - PHP-FPM Application Server'
fi
if [ "$multiphp" = 'yes' ]; then
	phpfpm='yes'
	echo '   - Multi-PHP Environment'
fi

# DNS stack
if [ "$named" = 'yes' ]; then
	echo '   - Bind DNS Server'
	# RHEL 8 hack for bind9.16 conflict
	if [ "$release" = "8" ]; then
		dnf remove -y bind-utils
	fi
fi

# Mail stack
if [ "$exim" = 'yes' ]; then
	echo -n '   - Exim Mail Server'
	if [ "$clamd" = 'yes' ] || [ "$spamd" = 'yes' ]; then
		echo -n ' + '
		if [ "$clamd" = 'yes' ]; then
			echo -n 'ClamAV '
		fi
		if [ "$spamd" = 'yes' ]; then
			if [ "$clamd" = 'yes' ]; then
				echo -n '+ '
			fi
			echo -n 'SpamAssassin'
		fi
	fi
	echo
	if [ "$dovecot" = 'yes' ]; then
		echo -n '   - Dovecot POP3/IMAP Server'
		if [ "$sieve" = 'yes' ]; then
			echo -n '+ Sieve'
		fi
	fi
fi

echo

# Database stack
if [ "$mysql" = 'yes' ]; then
	echo '   - MariaDB Database Server'
fi
if [ "$mysql8" = 'yes' ]; then
	echo '   - MySQL8 Database Server'
fi
if [ "$postgresql" = 'yes' ]; then
	echo '   - PostgreSQL Database Server'
fi

# FTP stack
if [ "$vsftpd" = 'yes' ]; then
	echo '   - Vsftpd FTP Server'
fi
if [ "$proftpd" = 'yes' ]; then
	echo '   - ProFTPD FTP Server'
fi

# Firewall stack
if [ "$iptables" = 'yes' ]; then
	echo -n '   - Firewall (iptables)'
fi
if [ "$iptables" = 'yes' ] && [ "$fail2ban" = 'yes' ]; then
	echo -n ' + Fail2Ban Access Monitor'
fi
echo -e "\n"
echo "========================================================================"
echo -e "\n"

# Asking for confirmation to proceed
if [ "$interactive" = 'yes' ]; then
	read -p 'Would you like to continue with the installation? [Y/N]: ' answer
	if [ "$answer" != 'y' ] && [ "$answer" != 'Y' ]; then
		echo 'Goodbye'
		exit 1
	fi
fi

# Validate Email / Hostname even when interactive = no
# Asking for contact email
if [ -z "$email" ]; then
	while validate_email; do
		echo -e "\nPlease use a valid emailadress (ex. info@domain.tld)."
		read -p 'Please enter admin email address: ' email
	done
else
	if validate_email; then
		echo "Please use a valid emailadress (ex. info@domain.tld)."
		exit 1
	fi
fi

# Asking to set FQDN hostname
if [ -z "$servername" ]; then
	# Ask and validate FQDN hostname.
	read -p "Please enter FQDN hostname [$(hostname -f)]: " servername

	# Set hostname if it wasn't set
	if [ -z "$servername" ]; then
		servername=$(hostname -f)
	fi

	# Validate Hostname, go to loop if the validation fails.
	while validate_hostname; do
		echo -e "\nPlease use a valid hostname according to RFC1178 (ex. hostname.domain.tld)."
		read -p "Please enter FQDN hostname [$(hostname -f)]: " servername
	done
else
	# Validate FQDN hostname if it is preset
	if validate_hostname; then
		echo "Please use a valid hostname according to RFC1178 (ex. hostname.domain.tld)."
		exit 1
	fi
fi

# Generating admin password if it wasn't set
displaypass="The password you chose during installation."
if [ -z "$vpass" ]; then
	vpass=$(gen_pass)
	displaypass=$vpass
fi

# Set FQDN if it wasn't set
mask1='(([[:alnum:]](-?[[:alnum:]])*)\.)'
mask2='*[[:alnum:]](-?[[:alnum:]])+\.[[:alnum:]]{2,}'
if ! [[ "$servername" =~ ^${mask1}${mask2}$ ]]; then
	if [[ -n "$servername" ]]; then
		servername="$servername.example.com"
	else
		servername="example.com"
	fi
	echo "127.0.0.1 $servername" >> /etc/hosts
fi

if [[ -z $(grep -i "$servername" /etc/hosts) ]]; then
	echo "127.0.0.1 $servername" >> /etc/hosts
fi

# Set email if it wasn't set
if [[ -z "$email" ]]; then
	email="admin@$servername"
fi

# Defining backup directory
echo -e "Installation backup directory: $hst_backups"

# Print Log File Path
echo "Installation log file: $LOG"

# Print new line
echo

#----------------------------------------------------------#
#                      Checking swap                       #
#----------------------------------------------------------#

# Checking swap on small instances
if [ -z "$(swapon -s)" ] && [ "$memory" -lt 1000000 ]; then
	fallocate -l 1G /swapfile
	chmod 600 /swapfile
	mkswap /swapfile
	swapon /swapfile
	echo "/swapfile   none    swap    sw    0   0" >> /etc/fstab
fi

#----------------------------------------------------------#
#                   Install repository                     #
#----------------------------------------------------------#

# Create new folder if not all-ready exists
mkdir -p /root/.gnupg/ && chmod 700 /root/.gnupg/

# Updating system
echo "Adding required repositories to proceed with installation:"
echo

# Installing Nginx repo

echo "[ * ] NGINX"
#dnf config-manager --add-repo https://dev.brepo.ru/bayrepo/hestiacp/raw/branch/master/install/rpm/nginx/nginx.repo
#nginx will be installed from hestia.repo

# Installing Remi PHP repo
echo "[ * ] PHP"
php_pkgs_lst=""
if [ "$uselocalphp" == "yes" ]; then
	write_config_value "LOCAL_PHP" "yes"
	php_pkgs_lst="brepo-php${php_v} brepo-php${php_v}-mod-apache"
else
	write_config_value "LOCAL_PHP" "no"
	php_pkgs_lst="php${php_v}-php php${php_v}-php-cgi php${php_v}-php-mysqlnd php${php_v}-php-pgsql
  php${php_v}-php-pdo php${php_v}-php-common php${php_v}-php-pecl-imagick php${php_v}-php-imap php${php_v}-php-ldap
  php${php_v}-php-pecl-apcu php${php_v}-php-pecl-zip php${php_v}-php-cli php${php_v}-php-opcache php${php_v}-php-xml
  php${php_v}-php-gd php${php_v}-php-intl php${php_v}-php-mbstring php${php_v}-php-pspell php${php_v}-php-readline"
	dnf install -y https://rpms.remirepo.net/enterprise/remi-release-$release.rpm
fi
software="$software $php_pkgs_lst"

# Installing MariaDB repo
if [ "$mysql" = 'yes' ]; then
	echo "[ * ] MariaDB"
	if [ -n "$use_devel" ];then
		dnf config-manager --add-repo https://dev.brepo.ru/bayrepo/hestiacp/raw/branch/master/install/rpm/mysql/mariadb-$(arch).repo
	else
		dnf config-manager --add-repo https://raw.githubusercontent.com/bayrepo/hestiacp-rpm/refs/heads/rhel-version/install/rpm/mysql/mariadb-$(arch).repo
	fi
fi

# Enabling MySQL module
if [ "$mysql8" = 'yes' ]; then
	echo "[ * ] MySQL 8"
	if [ "$release" -eq 8 ]; then
		dnf -y module enable mysql:8.0
	fi
fi

# Installing HestiaCP repo
echo "[ * ] Hestia Control Panel"
if [ -n "$use_devel" ];then
	dnf config-manager --add-repo https://dev.brepo.ru/bayrepo/hestiacp/raw/branch/master/install/rpm/hestia/hestia.repo
else
	dnf config-manager --add-repo https://raw.githubusercontent.com/bayrepo/hestiacp-rpm/refs/heads/rhel-version/install/rpm/hestia/hestia.repo
fi
rpm --import https://repo.brepo.ru/hestia/brepo_projects-gpg-key
check_result $? "rpm import brepo.ru GPG key failed"
mkdir /var/cache/hestia-nginx/

# Installing PostgreSQL repo
if [ "$postgresql" = 'yes' ]; then
	echo "[ * ] PostgreSQL"
	dnf -y module enable postgresql:15
fi

# Echo for a new line
echo

# Updating system
echo -ne "Updating currently installed packages, please wait... "
dnf -y upgrade >> $LOG &
BACK_PID=$!

# Check if package installation is done, print a spinner
spin_i=1
while kill -0 $BACK_PID > /dev/null 2>&1; do
	printf "\b${spinner:spin_i++%${#spinner}:1}"
	sleep 0.5
done

# Do a blank echo to get the \n back
echo

# Check Installation result
wait $BACK_PID
check_result $? 'dnf upgrade failed'

#----------------------------------------------------------#
#                         Backup                           #
#----------------------------------------------------------#

# Creating backup directory tree
mkdir -p $hst_backups
cd $hst_backups
mkdir nginx httpd php vsftpd proftpd bind exim dovecot clamd
mkdir spamassassin mysql postgresql hestia

# Backup nginx configuration
systemctl stop nginx > /dev/null 2>&1
cp -r /etc/nginx/* $hst_backups/nginx > /dev/null 2>&1

# Backup Apache configuration
systemctl stop httpd > /dev/null 2>&1
cp -r /etc/httpd/* $hst_backups/httpd > /dev/null 2>&1
rm -f /etc/httpd/conf.h.d/* > /dev/null 2>&1

# Backup PHP-FPM configuration
systemctl stop php*-fpm > /dev/null 2>&1
cp -r /etc/php/* $hst_backups/php/ > /dev/null 2>&1

# Backup Bind configuration
systemctl stop named > /dev/null 2>&1
cp -r /etc/named/* $hst_backups/named > /dev/null 2>&1

# Backup Vsftpd configuration
systemctl stop vsftpd > /dev/null 2>&1
cp /etc/vsftpd.conf $hst_backups/vsftpd > /dev/null 2>&1

# Backup ProFTPD configuration
systemctl stop proftpd > /dev/null 2>&1
cp /etc/proftpd/* $hst_backups/proftpd > /dev/null 2>&1

# Backup Exim configuration
systemctl stop exim > /dev/null 2>&1
cp -r /etc/exim/* $hst_backups/exim > /dev/null 2>&1

# Backup ClamAV configuration
systemctl stop clamav-daemon > /dev/null 2>&1
cp -r /etc/clamav/* $hst_backups/clamav > /dev/null 2>&1

# Backup SpamAssassin configuration
systemctl stop spamassassin > /dev/null 2>&1
cp -r /etc/spamassassin/* $hst_backups/spamassassin > /dev/null 2>&1

# Backup Dovecot configuration
systemctl stop dovecot > /dev/null 2>&1
cp /etc/dovecot.conf $hst_backups/dovecot > /dev/null 2>&1
cp -r /etc/dovecot/* $hst_backups/dovecot > /dev/null 2>&1

# Backup MySQL/MariaDB configuration and data
systemctl stop mysql > /dev/null 2>&1
killall -9 mysqld > /dev/null 2>&1
mv /var/lib/mysql $hst_backups/mysql/mysql_datadir > /dev/null 2>&1
cp -r /etc/mysql/* $hst_backups/mysql > /dev/null 2>&1
mv -f /root/.my.cnf $hst_backups/mysql > /dev/null 2>&1

# Backup Hestia
systemctl stop hestia > /dev/null 2>&1
cp -r $HESTIA/* $hst_backups/hestia > /dev/null 2>&1
dnf -y remove hestia hestia-nginx hestia-php > /dev/null 2>&1
rm -rf $HESTIA > /dev/null 2>&1

#----------------------------------------------------------#
#                     Package Includes                     #
#----------------------------------------------------------#

if [ "$phpfpm" = 'yes' ]; then
	if [ "$uselocalphp" == "yes" ]; then
		fpm="brepo-php${php_v}-fpm"
	else
		fpm="php${php_v}-php-fpm php${php_v}-php-cgi.${arch} php${php_v}-php-mysqlnd.${arch} php${php_v}-php-pgsql.${arch}
			php${php_v}-php-pdo php${php_v}-php-common php${php_v}-php-pecl-imagick php${php_v}-php-imap php${php_v}-php-ldap
			php${php_v}-php-pecl-apcu php${php_v}-php-pecl-zip php${php_v}-php-cli php${php_v}-php-opcache php${php_v}-php-xml
			php${php_v}-php-gd php${php_v}-php-intl php${php_v}-php-mbstring php${php_v}-php-pspell php${php_v}-php-readline"
	fi
	software="$software $fpm"
fi

#----------------------------------------------------------#
#                     Package Excludes                     #
#----------------------------------------------------------#

# Excluding packages
if [ "$apache" = 'no' ]; then
	software=$(echo "$software" | sed -e "s/httpd.${arch}//")
	software=$(echo "$software" | sed -e "s/httpd-tools//")
	software=$(echo "$software" | sed -e "s/httpd-itk//")
	software=$(echo "$software" | sed -e "s/mod_suphp//")
	software=$(echo "$software" | sed -e "s/mod_fcgid//")
	software=$(echo "$software" | sed -e "s/mod_ssl//")
	software=$(echo "$software" | sed -e "s/php${php_v}-php//")
	software=$(echo "$software" | sed -e "s/brepo-php${php_v}-mod-apache//")
	mod_php="disable"
fi
if [ "$vsftpd" = 'no' ]; then
	software=$(echo "$software" | sed -e "s/vsftpd//")
fi
if [ "$proftpd" = 'no' ]; then
	software=$(echo "$software" | sed -e "s/proftpd//")
fi
if [ "$named" = 'no' ]; then
	software=$(echo "$software" | sed -e "s/bind//")
fi
if [ "$exim" = 'no' ]; then
	software=$(echo "$software" | sed -e "s/exim//")
	software=$(echo "$software" | sed -e "s/dovecot//")
	software=$(echo "$software" | sed -e "s/clamd//")
	software=$(echo "$software" | sed -e "s/clamav//")
	software=$(echo "$software" | sed -e "s/spamassassin//")
	software=$(echo "$software" | sed -e "s/dovecot-pigeonhole//")
fi
if [ "$clamd" = 'no' ]; then
	software=$(echo "$software" | sed -e "s/clamd//")
	software=$(echo "$software" | sed -e "s/clamav//")
fi
if [ "$spamd" = 'no' ]; then
	software=$(echo "$software" | sed -e "s/spamassassin//")
fi
if [ "$dovecot" = 'no' ]; then
	software=$(echo "$software" | sed -e "s/dovecot//")
fi
if [ "$sieve" = 'no' ]; then
	software=$(echo "$software" | sed -e "s/dovecot-pigeonhole//")
fi
if [ "$mysql" = 'no' ]; then
	software=$(echo "$software" | sed -e "s/MariaDB-server//")
	software=$(echo "$software" | sed -e "s/MariaDB-client//")
	software=$(echo "$software" | sed -e "s/MariaDB-common//")
fi
if [ "$mysql8" = 'no' ]; then
	software=$(echo "$software" | sed -e "s/mysql.${arch}//")
	software=$(echo "$software" | sed -e "s/mysql-server//")
	software=$(echo "$software" | sed -e "s/mysql-common//")
fi
if [ "$mysql" = 'no' ] && [ "$mysql8" = 'no' ]; then
	software=$(echo "$software" | sed -e "s/php${php_v}-php-mysql//")
fi
if [ "$postgresql" = 'no' ]; then
	software=$(echo "$software" | sed -e "s/postgresql-server//")
	software=$(echo "$software" | sed -e "s/php${php_v}-php-pgsql//")
	software=$(echo "$software" | sed -e "s/phppgadmin//")
	php_modules_install=$(echo "$php_modules_install" | sed -e "s/pgsql//")
	php_modules_install=$(echo "$php_modules_install" | sed -e "s/pdo_pgsql//")
	php_modules_disable="$php_modules_disable pgsql pdo_pgsql"
fi
if [ "$fail2ban" = 'no' ]; then
	software=$(echo "$software" | sed -e "s/fail2ban//")
fi
if [ "$iptables" = 'no' ]; then
	software=$(echo "$software" | sed -e "s/ipset//")
	software=$(echo "$software" | sed -e "s/fail2ban//")
fi
if [ "$phpfpm" = 'yes' ]; then
	software=$(echo "$software" | sed -e "s/php${php_v}-php-cgi//")
	software=$(echo "$software" | sed -e "s/httpd-itk//")
	software=$(echo "$software" | sed -e "s/mod_ruid2 //")
	software=$(echo "$software" | sed -e "s/mod_suphp//")
	software=$(echo "$software" | sed -e "s/mod_fcgid//")
	software=$(echo "$software" | sed -e "s/php${php_v}-php//")
	software=$(echo "$software" | sed -e "s/brepo-php${php_v}-mod-apache//")
	mod_php="disable"
fi
if [ -d "$withrpms" ]; then
	software=$(echo "$software" | sed -e "s/hestia-nginx//")
	software=$(echo "$software" | sed -e "s/hestia-php//")
	software=$(echo "$software" | sed -e "s/hestia//")
fi

#----------------------------------------------------------#
#                     Install packages                     #
#----------------------------------------------------------#

if [ "$iptables" = 'yes' ]; then
	dnf install iptables-nft -y
	systemctl stop firewalld
	systemctl disable firewalld
	systemctl enable nftables --now
else
	systemctl stop firewalld
	systemctl disable firewalld
fi

# Installing rpm packages
echo "The installer is now downloading and installing all required packages."
echo -ne "NOTE: This process may take 10 to 15 minutes to complete, please wait... "
echo

dnf -y install $software >> $LOG &
BACK_PID=$!

# Check if package installation is done, print a spinner
spin_i=1
while kill -0 $BACK_PID > /dev/null 2>&1; do
	printf "\b${spinner:spin_i++%${#spinner}:1}"
	sleep 0.5
done

# Do a blank echo to get the \n back
echo

# Check Installation result
wait $BACK_PID
check_result $? "dnf install failed"

echo
echo "========================================================================"
echo

# Create PHP symlink
if [ "$uselocalphp" == "yes" ]; then
	alternatives --install /usr/bin/php php /opt/brepo/php${php_v}/bin/php 1
	echo "[ * ] Configuring php settings..."
	for mod in $php_modules_install; do
		enable_local_php_extension "${php_v}" "$mod"
	done
	for mod in $php_modules_disable; do
		disable_local_php_extension "${php_v}" "$mod"
	done
	if [ "$mod_php" == "enable" ]; then
		enable_mod_php "${php_v}"
	fi
else
	alternatives --install /usr/bin/php php /opt/remi/php${php_v}/root/usr/bin/php 1
fi

# Install Hestia packages from local folder
if [ -n "$withrpms" ] && [ -d "$withrpms" ]; then
	echo "[ * ] Installing local package files..."
	echo "    - hestia core package"
	rpm -i $withrpms/hestia_*.rpm > /dev/null 2>&1

	if [ -z $(ls $withrpms/hestia-php_*.rpm 2> /dev/null) ]; then
		echo "    - hestia-php backend package (from dnf)"
		dnf -y install hestia-php > /dev/null 2>&1
	else
		echo "    - hestia-php backend package"
		rpm -i $withrpms/hestia-php_*.rpm > /dev/null 2>&1
	fi

	if [ -z $(ls $withrpms/hestia-nginx_*.deb 2> /dev/null) ]; then
		echo "    - hestia-nginx backend package (from dnf)"
		dnf -y install hestia-nginx > /dev/null 2>&1
	else
		echo "    - hestia-nginx backend package"
		rpm -i $withrpms/hestia-nginx_*.rpm > /dev/null 2>&1
	fi
fi


#----------------------------------------------------------#
#                     Configure system                     #
#----------------------------------------------------------#

echo "[ * ] Configuring system settings..."

# Enable SFTP subsystem for SSH
sftp_subsys_enabled=$(grep -iE "^#?.*subsystem.+(sftp )?sftp-server" /etc/ssh/sshd_config)
if [ -n "$sftp_subsys_enabled" ]; then
	sed -i -E "s/^#?.*Subsystem.+(sftp )?sftp-server/Subsystem sftp internal-sftp/g" /etc/ssh/sshd_config
fi

# Reduce SSH login grace time
sed -i "s/[#]LoginGraceTime [[:digit:]]m/LoginGraceTime 1m/g" /etc/ssh/sshd_config

# Restart SSH daemon
systemctl restart sshd

# Disable AWStats cron
rm -f /etc/cron.d/awstats
# Replace awstatst function
mkdir -p /etc/logrotate.d/httpd-prerotate
cp -f $HESTIA_INSTALL_DIR/logrotate/httpd-prerotate/* /etc/logrotate.d/httpd-prerotate/

# Set directory color
if [ -z "$(grep 'LS_COLORS="$LS_COLORS:di=00;33"' /etc/profile)" ]; then
	echo 'LS_COLORS="$LS_COLORS:di=00;33"' >> /etc/profile
fi

# Register /sbin/nologin and /usr/sbin/nologin
if [ -z "$(grep ^/sbin/nologin /etc/shells)" ]; then
	echo "/sbin/nologin" >> /etc/shells
fi

if [ -z "$(grep ^/usr/sbin/nologin /etc/shells)" ]; then
	echo "/usr/sbin/nologin" >> /etc/shells
fi

# Configuring NTP
sed -i 's/#NTP=/NTP=pool.ntp.org/' /etc/systemd/timesyncd.conf
systemctl enable systemd-timesyncd
systemctl start systemd-timesyncd

# Restrict access to /proc fs
# - Prevent unpriv users from seeing each other running processes
mount -o remount,defaults,hidepid=2 /proc > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Info: Cannot remount /proc (LXC containers require additional perm added to host apparmor profile)"
else
	echo "@reboot root sleep 5 && mount -o remount,defaults,hidepid=2 /proc" > /etc/cron.d/hestia-proc
fi

#----------------------------------------------------------#
#                     Configure Hestia                     #
#----------------------------------------------------------#

echo "[ * ] Configuring Hestia Control Panel..."
# Installing sudo configuration
mkdir -p /etc/sudoers.d
cp -f $HESTIA_INSTALL_DIR/sudo/admin /etc/sudoers.d/
chmod 440 /etc/sudoers.d/admin

# Add Hestia global config
if [[ ! -e /etc/hestiacp/hestia.conf ]]; then
	mkdir -p /etc/hestiacp
	echo -e "# Do not edit this file, will get overwritten on next upgrade, use /etc/hestiacp/local.conf instead\n\nexport HESTIA='/usr/local/hestia'\n\n[[ -f /etc/hestiacp/local.conf ]] && source /etc/hestiacp/local.conf" > /etc/hestiacp/hestia.conf
fi

# Configuring system env
echo "export HESTIA='$HESTIA'" > /etc/profile.d/hestia.sh
echo 'PATH=$PATH:'$HESTIA'/bin' >> /etc/profile.d/hestia.sh
echo 'export PATH' >> /etc/profile.d/hestia.sh
chmod 755 /etc/profile.d/hestia.sh
source /etc/profile.d/hestia.sh

# Configuring logrotate for Hestia logs
cp -f $HESTIA_INSTALL_DIR/logrotate/hestia /etc/logrotate.d/hestia

# Create log path and symbolic link
rm -f /var/log/hestia
mkdir -p /var/log/hestia
ln -s /var/log/hestia $HESTIA/log

# Building directory tree and creating some blank files for Hestia
mkdir -p $HESTIA/conf $HESTIA/ssl $HESTIA/data/ips \
	$HESTIA/data/queue $HESTIA/data/users $HESTIA/data/firewall \
	$HESTIA/data/sessions
touch $HESTIA/data/queue/backup.pipe $HESTIA/data/queue/disk.pipe \
	$HESTIA/data/queue/webstats.pipe $HESTIA/data/queue/restart.pipe \
	$HESTIA/data/queue/traffic.pipe $HESTIA/data/queue/daily.pipe $HESTIA/log/system.log \
	$HESTIA/log/nginx-error.log $HESTIA/log/auth.log $HESTIA/log/backup.log
chmod 750 $HESTIA/conf $HESTIA/data/users $HESTIA/data/ips $HESTIA/log
chmod -R 750 $HESTIA/data/queue
chmod 660 /var/log/hestia/*
chmod 770 $HESTIA/data/sessions

# Generating Hestia configuration
rm -f $HESTIA/conf/hestia.conf > /dev/null 2>&1
touch $HESTIA/conf/hestia.conf
chmod 660 $HESTIA/conf/hestia.conf

# Write default port value to hestia.conf
# If a custom port is specified it will be set at the end of the installation process.
if [ -n "$use_devel" ];then
	write_config_value "USE_DEVEL" "devel"
fi

write_config_value "BACKEND_PORT" "8083"

if [ "$uselocalphp" == "yes" ]; then
	write_config_value "LOCAL_PHP" "yes"
else
	write_config_value "LOCAL_PHP" "no"
fi

# Web stack
if [ "$apache" = 'yes' ]; then
	write_config_value "WEB_SYSTEM" "httpd"
	write_config_value "WEB_RGROUPS" "apache"
	write_config_value "WEB_PORT" "8080"
	write_config_value "WEB_SSL_PORT" "8443"
	write_config_value "WEB_SSL" "mod_ssl"
	write_config_value "PROXY_SYSTEM" "nginx"
	write_config_value "PROXY_PORT" "80"
	write_config_value "PROXY_SSL_PORT" "443"
	write_config_value "STATS_SYSTEM" "awstats"
fi
if [ "$apache" = 'no' ]; then
	write_config_value "WEB_SYSTEM" "nginx"
	write_config_value "WEB_PORT" "80"
	write_config_value "WEB_SSL_PORT" "443"
	write_config_value "WEB_SSL" "openssl"
	write_config_value "STATS_SYSTEM" "awstats"
fi
if [ "$phpfpm" = 'yes' ]; then
	write_config_value "WEB_BACKEND" "php-fpm"
fi

# Database stack
if [ "$mysql" = 'yes' ] || [ "$mysql8" = 'yes' ]; then
	installed_db_types='mysql'
fi
if [ "$postgresql" = 'yes' ]; then
	installed_db_types="$installed_db_types,pgsql"
fi
if [ -n "$installed_db_types" ]; then
	db=$(echo "$installed_db_types" \
		| sed "s/,/\n/g" \
		| sort -r -u \
		| sed "/^$/d" \
		| sed ':a;N;$!ba;s/\n/,/g')
	write_config_value "DB_SYSTEM" "$db"
fi

# FTP stack
if [ "$vsftpd" = 'yes' ]; then
	write_config_value "FTP_SYSTEM" "vsftpd"
fi
if [ "$proftpd" = 'yes' ]; then
	write_config_value "FTP_SYSTEM" "proftpd"
fi

# DNS stack
if [ "$named" = 'yes' ]; then
	write_config_value "DNS_SYSTEM" "named"
fi

# Mail stack
if [ "$exim" = 'yes' ]; then
	write_config_value "MAIL_SYSTEM" "exim"
	if [ "$clamd" = 'yes' ]; then
		write_config_value "ANTIVIRUS_SYSTEM" "clamav-daemon"
	fi
	if [ "$spamd" = 'yes' ]; then
		write_config_value "ANTISPAM_SYSTEM" "spamassassin"
	fi
	if [ "$dovecot" = 'yes' ]; then
		write_config_value "IMAP_SYSTEM" "dovecot"
	fi
	if [ "$sieve" = 'yes' ]; then
		write_config_value "SIEVE_SYSTEM" "yes"
	fi
fi

# Cron daemon
write_config_value "CRON_SYSTEM" "crond"

# Firewall stack
if [ "$iptables" = 'yes' ]; then
	write_config_value "FIREWALL_SYSTEM" "iptables"
fi
if [ "$iptables" = 'yes' ] && [ "$fail2ban" = 'yes' ]; then
	write_config_value "FIREWALL_EXTENSION" "fail2ban"
fi

# Disk quota
if [ "$quota" = 'yes' ]; then
	write_config_value "DISK_QUOTA" "yes"
else
	write_config_value "DISK_QUOTA" "no"
fi

# Backups
write_config_value "BACKUP_SYSTEM" "local"
write_config_value "BACKUP_GZIP" "4"
write_config_value "BACKUP_MODE" "zstd"

# Language
write_config_value "LANGUAGE" "$lang"

# Login in screen
write_config_value "LOGIN_STYLE" "default"

# Theme
write_config_value "THEME" "dark"

# Inactive session timeout
write_config_value "INACTIVE_SESSION_TIMEOUT" "60"

# Version & Release Branch
write_config_value "VERSION" "${HESTIA_INSTALL_VER}"
write_config_value "RELEASE_BRANCH" "release"

# Email notifications after upgrade
write_config_value "UPGRADE_SEND_EMAIL" "true"
write_config_value "UPGRADE_SEND_EMAIL_LOG" "false"

# Installing hosting packages
cp -rf $HESTIA_COMMON_DIR/packages $HESTIA/data/

# Update nameservers in hosting package
IFS='.' read -r -a domain_elements <<< "$servername"
if [ -n "${domain_elements[-2]}" ] && [ -n "${domain_elements[-1]}" ]; then
	serverdomain="${domain_elements[-2]}.${domain_elements[-1]}"
	sed -i s/"domain.tld"/"$serverdomain"/g $HESTIA/data/packages/*.pkg
fi

# Installing templates
cp -rf $HESTIA_INSTALL_DIR/templates $HESTIA/data/
cp -rf $HESTIA_COMMON_DIR/templates/web/ $HESTIA/data/templates
cp -rf $HESTIA_COMMON_DIR/templates/dns/ $HESTIA/data/templates

mkdir -p /var/www/html
mkdir -p /var/www/document_errors

# Install default success page
cp -rf $HESTIA_COMMON_DIR/templates/web/unassigned/index.html /var/www/html/
cp -rf $HESTIA_COMMON_DIR/templates/web/skel/document_errors/* /var/www/document_errors/

# Installing firewall rules
cp -rf $HESTIA_COMMON_DIR/firewall $HESTIA/data/
rm -f $HESTIA/data/firewall/ipset/blacklist.sh $HESTIA/data/firewall/ipset/blacklist.ipv6.sh

# Installing apis
cp -rf $HESTIA_COMMON_DIR/api $HESTIA/data/

# Configuring server hostname
$HESTIA/bin/v-change-sys-hostname $servername > /dev/null 2>&1

# Generating SSL certificate
echo "[ * ] Generating default self-signed SSL certificate..."
$HESTIA/bin/v-generate-ssl-cert $(hostname) '' 'RU' 'Moscow' \
	'Moscow' 'Hestia Control Panel' 'IT' > /tmp/hst.pem

# Parsing certificate file
crt_end=$(grep -n "END CERTIFICATE-" /tmp/hst.pem | cut -f 1 -d:)
key_start=$(grep -n "BEGIN PRIVATE KEY" /tmp/hst.pem | cut -f 1 -d:)
key_end=$(grep -n "END PRIVATE KEY" /tmp/hst.pem | cut -f 1 -d:)

# Adding SSL certificate
echo "[ * ] Adding SSL certificate to Hestia Control Panel..."
cd $HESTIA/ssl
sed -n "1,${crt_end}p" /tmp/hst.pem > certificate.crt
sed -n "$key_start,${key_end}p" /tmp/hst.pem > certificate.key
chown root:mail $HESTIA/ssl/*
chmod 660 $HESTIA/ssl/*
rm /tmp/hst.pem

# Install dhparam.pem
cp -f $HESTIA_INSTALL_DIR/ssl/dhparam.pem /etc/pki/tls/

# Deleting old admin user
if [ -n "$(grep ^admin: /etc/passwd)" ] && [ "$force" = 'yes' ]; then
	chattr -i /home/admin/conf > /dev/null 2>&1
	userdel -f admin > /dev/null 2>&1
	chattr -i /home/admin/conf > /dev/null 2>&1
	mv -f /home/admin $hst_backups/home/ > /dev/null 2>&1
	rm -f /tmp/sess_* > /dev/null 2>&1
fi
if [ -n "$(grep ^admin: /etc/group)" ] && [ "$force" = 'yes' ]; then
	groupdel admin > /dev/null 2>&1
fi

# Enabling sftp jail
echo "[ * ] Enable SFTP jail..."
$HESTIA/bin/v-add-sys-sftp-jail > /dev/null 2>&1
check_result $? "can't enable sftp jail"

# Adding Hestia admin account
echo "[ * ] Create default admin account..."
$HESTIA/bin/v-add-user admin $vpass $email "system" "System Administrator"
check_result $? "can't create admin user"
$HESTIA/bin/v-change-user-shell admin nologin
$HESTIA/bin/v-change-user-role admin admin
$HESTIA/bin/v-change-user-language admin $lang
$HESTIA/bin/v-change-sys-config-value 'POLICY_SYSTEM_PROTECTED_ADMIN' 'yes'
chown admin:admin /var/cache/hestia-nginx/

locale-gen "en_US.utf8" > /dev/null 2>&1

#----------------------------------------------------------#
#                     Configure Nginx                      #
#----------------------------------------------------------#

echo "[ * ] Configuring NGINX..."
rm -f /etc/nginx/conf.d/*.conf
cp -f $HESTIA_INSTALL_DIR/nginx/nginx.conf /etc/nginx/
cp -f $HESTIA_INSTALL_DIR/nginx/status.conf /etc/nginx/conf.d/
cp -f $HESTIA_INSTALL_DIR/nginx/0rtt-anti-replay.conf /etc/nginx/conf.d/
cp -f $HESTIA_INSTALL_DIR/nginx/agents.conf /etc/nginx/conf.d/
cp -f $HESTIA_INSTALL_DIR/nginx/phpmyadmin.inc /etc/nginx/conf.d/
cp -f $HESTIA_INSTALL_DIR/nginx/phppgadmin.inc /etc/nginx/conf.d/
cp -f $HESTIA_INSTALL_DIR/logrotate/nginx /etc/logrotate.d/
mkdir -p /etc/nginx/conf.d/domains
mkdir -p /etc/nginx/modules-enabled
mkdir -p /var/log/nginx/domains
mkdir -p /etc/nginx/conf.d/main

# Update dns servers in nginx.conf
for nameserver in $(grep -is '^nameserver' /etc/resolv.conf | cut -d' ' -f2 | tr '\r\n' ' ' | xargs); do
	if [[ "$nameserver" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
		if [ -z "$resolver" ]; then
			resolver="$nameserver"
		else
			resolver="$resolver $nameserver"
		fi
	fi
done
if [ -n "$resolver" ]; then
	sed -i "s/1.1.1.1 8.8.8.8/$resolver/g" /etc/nginx/nginx.conf
fi

# https://github.com/ergin/nginx-cloudflare-real-ip/
CLOUDFLARE_FILE_PATH='/etc/nginx/conf.d/cloudflare.inc'
echo "#Cloudflare" > $CLOUDFLARE_FILE_PATH
echo "" >> $CLOUDFLARE_FILE_PATH

echo "# - IPv4" >> $CLOUDFLARE_FILE_PATH
for i in $(curl -s -L https://www.cloudflare.com/ips-v4); do
	echo "set_real_ip_from $i;" >> $CLOUDFLARE_FILE_PATH
done
echo "" >> $CLOUDFLARE_FILE_PATH
echo "# - IPv6" >> $CLOUDFLARE_FILE_PATH
for i in $(curl -s -L https://www.cloudflare.com/ips-v6); do
	echo "set_real_ip_from $i;" >> $CLOUDFLARE_FILE_PATH
done

echo "" >> $CLOUDFLARE_FILE_PATH
echo "real_ip_header CF-Connecting-IP;" >> $CLOUDFLARE_FILE_PATH

systemctl enable nginx --now >> $LOG
check_result $? "nginx start failed"

#----------------------------------------------------------#
#                    Configure Apache                      #
#----------------------------------------------------------#

if [ "$apache" = 'yes' ]; then
	echo "[ * ] Configuring Apache Web Server..."

	mkdir -p /etc/httpd/conf.h.d
	mkdir -p /etc/httpd/conf.h.d/domains

	# Copy configuration files
	cp -f $HESTIA_INSTALL_DIR/httpd/httpd.conf /etc/httpd/conf/
	cp -f $HESTIA_INSTALL_DIR/httpd/status.conf /etc/httpd/conf.h.d/hestia-status.conf
	cp -f $HESTIA_INSTALL_DIR/logrotate/httpd /etc/logrotate.d/
	cp -f $HESTIA_INSTALL_DIR/httpd/hestiacp-httpd.conf /usr/lib/systemd/system/httpd.service.d/

	# Enable needed modules
	if [ "$nginx" = "no" ]; then
		dnf install -y mod_ssl mod_http2
	fi

	# IDK why those modules still here, but ok. if they are disabled by default

	if [ "$phpfpm" = 'yes' ]; then
    	if [ -e /etc/httpd/conf.modules.d/01-suexec.conf ]; then
    		sed 's/^LoadModule suexec_module/#LoadModule suexec_module/' -i /etc/httpd/conf.modules.d/01-suexec.conf
    	fi
    	if [ -e /etc/httpd/conf.modules.d/10-fcgid.conf ]; then
    		sed 's/^LoadModule fcgid_module/#LoadModule fcgid_module/' -i /etc/httpd/conf.modules.d/10-fcgid.conf
    	fi
    else
        cp -f $HESTIA_INSTALL_DIR/httpd/01-mpm-itk.conf /etc/httpd/conf.modules.d/
        if [ -e /etc/httpd/conf.modules.d/01-suexec.conf ]; then
       		sed 's/#LoadModule suexec_module/LoadModule suexec_module/' -i /etc/httpd/conf.modules.d/01-suexec.conf
       	fi
        echo "LoadModule suphp_module modules/mod_suphp.so" > /etc/httpd/conf.modules.d/10-suphp.conf
       	if [ -e /etc/httpd/conf.modules.d/10-fcgid.conf ]; then
       		sed 's/#LoadModule fcgid_module/LoadModule fcgid_module/' -i /etc/httpd/conf.modules.d/10-fcgid.conf
       	fi
        if [ -e /etc/httpd/conf.d/fcgid.conf ]; then
            cp /etc/httpd/conf.d/fcgid.conf /etc/httpd/conf.h.d/fcgid.conf
        fi
        if [ -e /etc/httpd/conf.dmod_suphp.conf ]; then
            cp /etc/httpd/conf.d/mod_suphp.conf /etc/httpd/conf.h.d/mod_suphp.conf
        fi
        if [ -e "/etc/httpd/conf.d.prep/php${php_v}.conf" ]; then
            ln -s "/etc/httpd/conf.d.prep/php${php_v}.conf" /etc/httpd/conf.modules.d/09-mod-php.conf
        fi

	fi

	# Switch status loader to custom one
	if [ -e /etc/httpd/conf.modules.d/00-base.conf ]; then
		sed 's/^LoadModule status_module/#LoadModule status_module/' -i /etc/httpd/conf.modules.d/00-base.conf
	fi
	echo 'LoadModule status_module modules/mod_status.so' > /etc/httpd/conf.modules.d/00-hestia-status.conf

	if [ "$phpfpm" = 'yes' ]; then
		# Disable prefork and php, enable event
		sed 's/LoadModule mpm_prefork_module/#LoadModule mpm_prefork_module/' -i /etc/httpd/conf.modules.d/00-mpm.conf
		sed 's/#LoadModule mpm_event_module/LoadModule mpm_event_module/' -i /etc/httpd/conf.modules.d/00-mpm.conf
		cp -f $HESTIA_INSTALL_DIR/httpd/hestia-event.conf /etc/httpd/conf.h.d/
	else
        sed 's/LoadModule mpm_worker_module/#LoadModule mpm_worker_module/' -i /etc/httpd/conf.modules.d/00-mpm.conf
        sed 's/LoadModule mpm_event_module/#LoadModule mpm_event_module/' -i /etc/httpd/conf.modules.d/00-mpm.conf
        sed 's/#LoadModule mpm_prefork_module/LoadModule mpm_prefork_module/' -i /etc/httpd/conf.modules.d/00-mpm.conf
	fi

	if [ ! -d /etc/httpd/sites-available ]; then
	    mkdir -p /etc/httpd/sites-available
	fi
	echo "# Powered by hestia" > /etc/httpd/sites-available/default
	echo "# Powered by hestia" > /etc/httpd/sites-available/default-ssl
	echo "# Powered by hestia" > /etc/httpd/conf/ports.conf
	# echo -e "/home\npublic_html/cgi-bin" > /etc/httpd/suexec/www-data
	touch /var/log/httpd/access.log /var/log/httpd/error.log
	mkdir -p /var/log/httpd/domains
	chmod a+x /var/log/httpd
	chmod 640 /var/log/httpd/access.log /var/log/httpd/error.log
	chmod 751 /var/log/httpd/domains

	systemctl enable httpd --now >> $LOG
	check_result $? "httpd start failed"
else
	systemctl disable httpd --now > /dev/null 2>&1
fi

#----------------------------------------------------------#
#                     Configure PHP-FPM                    #
#----------------------------------------------------------#

if [ "$uselocalphp" == "no" ]; then
	multiphp_v=("74" "80" "81" "82" "83" "84")
fi

if [ "$phpfpm" = "yes" ]; then
	if [ "$multiphp" = 'yes' ]; then
		for v in "${multiphp_v[@]}"; do
			echo "[ * ] Installing PHP $v..."
			$HESTIA/bin/v-add-web-php "$v" > /dev/null 2>&1
		done
	else
		echo "[ * ] Installing  PHP $php_v..."
		$HESTIA/bin/v-add-web-php "$php_v" > /dev/null 2>&1
	fi

	echo "[ * ] Configuring PHP $php_v..."
	# Create www.conf for webmail and php(*)admin
	if [ "$uselocalphp" == "yes" ]; then
		cp -f $HESTIA_INSTALL_DIR/php-fpm/www.conf /opt/brepo/php${php_v}/etc/php-fpm.d
		systemctl enable brepo-php-fpm${php_v}.service --now >> $LOG
		check_result $? "php-fpm start failed"
		# Set default php version to $php_v
		alternatives --install /usr/bin/php php /opt/brepo/php${php_v}/bin/php 1 > /dev/null 2>&1
		alternatives --set php /opt/brepo/php${php_v}/bin/php > /dev/null 2>&1
	else
		cp -f $HESTIA_INSTALL_DIR/php-fpm/www.conf /etc/opt/remi/php${php_v}/php-fpm.d
		systemctl enable php${php_v}-php-fpm --now >> $LOG
		check_result $? "php-fpm start failed"
		# Set default php version to $php_v
		alternatives --install /usr/bin/php php /usr/bin/php$php_v 1 > /dev/null 2>&1
		alternatives --set php /usr/bin/php$php_v > /dev/null 2>&1
	fi
fi

#----------------------------------------------------------#
#                     Configure PHP                        #
#----------------------------------------------------------#

echo "[ * ] Configuring PHP..."
# Set system php for selector
hestiacp-php-admin system "$php_v"

ZONE=$(timedatectl > /dev/null 2>&1 | grep Timezone | awk '{print $2}')
if [ -z "$ZONE" ]; then
	ZONE='UTC'
fi
if [ "$uselocalphp" == "yes" ]; then
	for pconf in $(find /opt/brepo/php* -name php.ini); do
		sed -i "s%;date.timezone =%date.timezone = $ZONE%g" $pconf
		sed -i 's%_open_tag = Off%_open_tag = On%g' $pconf
	done
else
	for pconf in $(find /etc/opt/remi/php* -name php.ini); do
		sed -i "s%;date.timezone =%date.timezone = $ZONE%g" $pconf
		sed -i 's%_open_tag = Off%_open_tag = On%g' $pconf
	done
fi

# Cleanup php session files not changed in the last 7 days (60*24*7 minutes)
echo '#!/bin/sh' > /etc/cron.daily/php-session-cleanup
echo "find -O3 /home/*/tmp/ -ignore_readdir_race -depth -mindepth 1 -name 'sess_*' -type f -cmin '+10080' -delete > /dev/null 2>&1" >> /etc/cron.daily/php-session-cleanup
echo "find -O3 $HESTIA/data/sessions/ -ignore_readdir_race -depth -mindepth 1 -name 'sess_*' -type f -cmin '+10080' -delete > /dev/null 2>&1" >> /etc/cron.daily/php-session-cleanup
chmod 755 /etc/cron.daily/php-session-cleanup

#----------------------------------------------------------#
#                    Configure Vsftpd                      #
#----------------------------------------------------------#

if [ "$vsftpd" = 'yes' ]; then
	echo "[ * ] Configuring Vsftpd server..."
	cp -f $HESTIA_INSTALL_DIR/vsftpd/vsftpd.conf /etc/
	touch /var/log/vsftpd.log
	chown root:adm /var/log/vsftpd.log
	chmod 640 /var/log/vsftpd.log
	touch /var/log/xferlog
	chown root:adm /var/log/xferlog
	chmod 640 /var/log/xferlog
	systemctl enable vsftpd --now
	check_result $? "vsftpd start failed"
fi

#----------------------------------------------------------#
#                    Configure ProFTPD                     #
#----------------------------------------------------------#

if [ "$proftpd" = 'yes' ]; then
	echo "[ * ] Configuring ProFTPD server..."
	echo "127.0.0.1 $servername" >> /etc/hosts
	cp -f $HESTIA_INSTALL_DIR/proftpd/proftpd.conf /etc/proftpd/
	cp -f $HESTIA_INSTALL_DIR/proftpd/tls.conf /etc/proftpd/

	systemctl enable proftpd --now >> $LOG
	check_result $? "proftpd start failed"

fi

#----------------------------------------------------------#
#               Configure MariaDB / MySQL                  #
#----------------------------------------------------------#

if [ "$mysql" = 'yes' ] || [ "$mysql8" = 'yes' ]; then
	[ "$mysql" = 'yes' ] && mysql_type="MariaDB" || mysql_type="MySQL"
	echo "[ * ] Configuring $mysql_type database server..."
	mycnf="my-small.cnf"
	if [ $memory -gt 1200000 ]; then
		mycnf="my-medium.cnf"
	fi
	if [ $memory -gt 3900000 ]; then
		mycnf="my-large.cnf"
	fi

	if [ "$mysql_type" = 'MariaDB' ]; then
		# Run mysql_install_db
		mysql_install_db >> $LOG
	fi

	mkdir /var/log/mysql/
	chown mysql:mysql /var/log/mysql/

	# Remove symbolic link
	rm -f /etc/my.cnf
	# Configuring MariaDB
	cp -f $HESTIA_INSTALL_DIR/mysql/$mycnf /etc/my.cnf

	# Switch MariaDB inclusions to the MySQL
	if [ "$mysql_type" = 'MySQL' ]; then
		sed -i '/query_cache_size/d' /etc/my.cnf
		sed -i 's|mariadb.conf.d|mysql.conf.d|g' /etc/my.cnf
	fi

	# MariaDB-server package has a compatibility symlink, so there is no need for conditions
	systemctl enable mysqld --now >> $LOG
	check_result $? "${mysql_type,,} start failed"

	# Securing MariaDB/MySQL installation
	mpass=$(gen_pass)
	echo -e "[client]\npassword='$mpass'\n" > /root/.my.cnf
	chmod 600 /root/.my.cnf

	# Alter root password
	mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$mpass'; FLUSH PRIVILEGES;"
	if [ "$mysql_type" = 'MariaDB' ]; then
		# Allow mysql access via socket for startup
		mysql -e "UPDATE mysql.global_priv SET priv=json_set(priv, '$.password_last_changed', UNIX_TIMESTAMP(), '$.plugin', 'mysql_native_password', '$.authentication_string', 'invalid', '$.auth_or', json_array(json_object(), json_object('plugin', 'unix_socket'))) WHERE User='root';"
		# Disable anonymous users
		mysql -e "DELETE FROM mysql.global_priv WHERE User='';"
	else
		mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$mpass';"
		mysql -e "DELETE FROM mysql.user WHERE User='';"
		mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
	fi
	# Drop test database
	mysql -e "DROP DATABASE IF EXISTS test"
	mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
	# Flush privileges
	mysql -e "FLUSH PRIVILEGES;"
fi

#----------------------------------------------------------#
#                    Configure phpMyAdmin                  #
#----------------------------------------------------------#

# Source upgrade.conf with phpmyadmin versions
# shellcheck source=/usr/local/hestia/install/upgrade/upgrade.conf
source $HESTIA/install/upgrade/upgrade.conf

if [ "$mysql" = 'yes' ] || [ "$mysql8" = 'yes' ]; then
	# Display upgrade information
	echo "[ * ] Installing phpMyAdmin version v$pma_v..."

	# Download latest phpmyadmin release
	wget --quiet --retry-connrefused https://data.brepo.ru/hestiacp/phpMyAdmin/$pma_v/phpMyAdmin-$pma_v-all-languages.zip

	# Unpack files
	unzip phpMyAdmin-$pma_v-all-languages.zip

	# Create folders
	mkdir -p /usr/share/phpmyadmin
	mkdir -p /etc/phpmyadmin
	mkdir -p /etc/phpmyadmin/conf.d/
	mkdir /usr/share/phpmyadmin/tmp

	# Configuring Apache2 for PHPMYADMIN
	if [ "$apache" = 'yes' ]; then
		touch /etc/httpd/conf.h.d/phpmyadmin.inc
	fi

	# Overwrite old files
	cp -rf phpMyAdmin-$pma_v-all-languages/* /usr/share/phpmyadmin

	# Create copy of config file
	cp -f $HESTIA_COMMON_DIR/phpmyadmin/config.inc.php /etc/phpmyadmin/
	mkdir -p /var/lib/phpmyadmin/tmp
	chmod 770 /var/lib/phpmyadmin/tmp
	chown root:apache /usr/share/phpmyadmin/tmp

	# Set config and log directory
	sed -i "s|'configFile' => ROOT_PATH . 'config.inc.php',|'configFile' => '/etc/phpmyadmin/config.inc.php',|g" /usr/share/phpmyadmin/libraries/vendor_config.php

	# Create temporary folder and change permission
	chmod 770 /usr/share/phpmyadmin/tmp
	chown root:apache /usr/share/phpmyadmin/tmp

	# Generate blow fish
	blowfish=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)
	sed -i "s|%blowfish_secret%|$blowfish|" /etc/phpmyadmin/config.inc.php

	# Clean Up
	rm -fr phpMyAdmin-$pma_v-all-languages
	rm -f phpMyAdmin-$pma_v-all-languages.tar.gz

	write_config_value "DB_PMA_ALIAS" "phpmyadmin"
	$HESTIA/bin/v-change-sys-db-alias 'pma' "phpmyadmin"

	# Special thanks to Pavel Galkin (https://skurudo.ru)
	# https://github.com/skurudo/phpmyadmin-fixer
	# shellcheck source=/usr/local/hestia/install/deb/phpmyadmin/pma.sh
	source $HESTIA_COMMON_DIR/phpmyadmin/pma.sh > /dev/null 2>&1

	# limit access to /etc/phpmyadmin/
	chown -R root:apache /etc/phpmyadmin/
	chmod -R 640 /etc/phpmyadmin/*
	chmod 750 /etc/phpmyadmin/conf.d/
fi

#----------------------------------------------------------#
#                   Configure PostgreSQL                   #
#----------------------------------------------------------#

if [ "$postgresql" = 'yes' ]; then
    echo "[ * ] Configuring PostgreSQL database server..."
    dnf install -y postgresql-server postgresql-contrib policycoreutils-python-utils > /dev/null 2>&1

    # Initialize the database
    if [ ! -f /var/lib/pgsql/data/PG_VERSION ]; then
        sudo postgresql-setup initdb > /dev/null 2>&1
    fi

    ppass=$(gen_pass)
    # Fixed the change to the default path of the PostgreSQL configuration file to the RHEL path
    cp -f $HESTIA_INSTALL_DIR/postgresql/pg_hba.conf /var/lib/pgsql/data/
    systemctl enable --now postgresql
    sudo -iu postgres psql -c "ALTER USER postgres WITH PASSWORD '$ppass'" > /dev/null 2>&1

    mkdir -p /etc/phppgadmin/
    mkdir -p /usr/share/phppgadmin/

    wget --retry-connrefused --quiet https://github.com/hestiacp/phppgadmin/releases/download/v$pga_v/phppgadmin-v$pga_v.tar.gz
    tar xzf phppgadmin-v$pga_v.tar.gz -C /usr/share/phppgadmin/ --no-same-owner

    cp -f $HESTIA_INSTALL_DIR/pga/config.inc.php /etc/phppgadmin/

    ln -s /etc/phppgadmin/config.inc.php /usr/share/phppgadmin/conf/
    # Fixed the Apache configuration file path to RHEL standard path
    if [ "$apache" = 'yes' ]; then
        cp -f $HESTIA_INSTALL_DIR/pga/phppgadmin.conf /etc/httpd/conf.d/phppgadmin.conf
    fi
    cp -f $HESTIA_INSTALL_DIR/pga/config.inc.php /etc/phppgadmin/

    rm phppgadmin-v$pga_v.tar.gz
    write_config_value "DB_PGA_ALIAS" "phppgadmin"
    $HESTIA/bin/v-change-sys-db-alias 'pga' "phppgadmin"
    setsebool -P httpd_can_network_connect_db 1
fi

#----------------------------------------------------------#
#                      Configure Bind                      #
#----------------------------------------------------------#

if [ "$named" = 'yes' ]; then
	echo "[ * ] Configuring Bind DNS server..."
	cp -f $HESTIA_INSTALL_DIR/bind/named.conf /etc/named/
	cp -f $HESTIA_INSTALL_DIR/bind/named.conf.options /etc/named/
	chown root:named /etc/named/named.conf
	chown root:named /etc/named/named.conf.options
	chmod 640 /etc/named/named.conf
	chmod 640 /etc/named/named.conf.options
	systemctl enable named --now
	check_result $? "bind start failed"

	# Workaround for OpenVZ/Virtuozzo
	if [ -e "/proc/vz/veinfo" ] && [ -e "/etc/rc.local" ]; then
		sed -i "s/^exit 0/systemctl restart named\nexit 0/" /etc/rc.local
	fi
fi

#----------------------------------------------------------#
#                      Configure Exim                      #
#----------------------------------------------------------#

if [ "$exim" = 'yes' ]; then
	echo "[ * ] Configuring Exim mail server..."

	exim_version=$(exim --version | head -1 | awk '{print $3}' | cut -f -2 -d .)
	cp -f $HESTIA_INSTALL_DIR/exim/exim.conf.template /etc/exim/
	cp -f $HESTIA_INSTALL_DIR/exim/dnsbl.conf /etc/exim/
	cp -f $HESTIA_INSTALL_DIR/exim/spam-blocks.conf /etc/exim/
	cp -f $HESTIA_INSTALL_DIR/exim/limit.conf /etc/exim/
	cp -f $HESTIA_INSTALL_DIR/exim/system.filter /etc/exim/
	touch /etc/exim/white-blocks.conf

	if [ "$spamd" = 'yes' ]; then
		sed -i "s/#SPAM/SPAM/g" /etc/exim/exim.conf.template
	fi
	if [ "$clamd" = 'yes' ]; then
		sed -i "s/#CLAMD/CLAMD/g" /etc/exim/exim.conf.template
	fi

	chmod 640 /etc/exim/exim.conf.template
	rm -rf /etc/exim/domains
	mkdir -p /etc/exim/domains

	alternatives --install /usr/sbin/sendmail mta /usr/sbin/exim 1
	alternatives --set mta /usr/sbin/exim

	systemctl disable sendmail --now > /dev/null 2>&1
	systemctl disable postfix --now > /dev/null 2>&1
	systemctl enable exim --now
	check_result $? "exim start failed"
fi

#----------------------------------------------------------#
#                     Configure Dovecot                    #
#----------------------------------------------------------#

if [ "$dovecot" = 'yes' ]; then
	echo "[ * ] Configuring Dovecot POP/IMAP mail server..."
	gpasswd -a dovecot mail > /dev/null 2>&1
	cp -rf $HESTIA_INSTALL_DIR/dovecot /etc/
	cp -f $HESTIA_INSTALL_DIR/logrotate/dovecot /etc/logrotate.d/
	chown -R root:root /etc/dovecot*
	rm -f /etc/dovecot/conf.d/15-mailboxes.conf


	systemctl enable dovecot --now
	check_result $? "dovecot start failed"
fi

#----------------------------------------------------------#
#                     Configure ClamAV                     #
#----------------------------------------------------------#

if [ "$clamd" = 'yes' ]; then
    useradd clamav -m -d /var/lib/clamavnew -r -s /sbin/nologin
	gpasswd -a clamav mail > /dev/null 2>&1
	gpasswd -a clamav exim > /dev/null 2>&1
	cp -f $HESTIA_INSTALL_DIR/clamav/clamd.conf /etc/clamd.d/daemon.conf
	cp -f $HESTIA_INSTALL_DIR/clamav/clamd.tmpfiles /etc/tmpfiles.d/clamav.conf
	if [ -n "$clamdm" ]; then
		cp -f $HESTIA_INSTALL_DIR/clamav/freshclam.conf /etc/freshclam.conf
	else
		cp -f $HESTIA_INSTALL_DIR/clamav/freshclam_orig.conf /etc/freshclam.conf
	fi
	touch /var/log/freshclam.log
	chown clamav:clamav /var/log/freshclam.log
	rm -f /var/lib/clamav/freshclam.dat
	mkdir -p /var/log/clamav
    systemd-tmpfiles --create

	echo -ne "[ * ] Installing ClamAV anti-virus definitions... "
	/usr/bin/freshclam >> $LOG &
	BACK_PID=$!
	spin_i=1
	while kill -0 $BACK_PID > /dev/null 2>&1; do
		printf "\b${spinner:spin_i++%${#spinner}:1}"
		sleep 0.5
	done
	echo
	systemctl enable clamd@daemon --now
	check_result $? "clamav-daemon start failed"
fi

#----------------------------------------------------------#
#                  Configure SpamAssassin                  #
#----------------------------------------------------------#

if [ "$spamd" = 'yes' ]; then
	echo "[ * ] Configuring SpamAssassin..."

	systemctl enable spamassassin --now >> $LOG
	check_result $? "spamassassin start failed"
fi

#----------------------------------------------------------#
#                    Configure Fail2Ban                    #
#----------------------------------------------------------#

if [ "$fail2ban" = 'yes' ]; then
	echo "[ * ] Configuring fail2ban access monitor..."
	cp -rf $HESTIA_INSTALL_DIR/fail2ban /etc/
	if [ "$dovecot" = 'no' ]; then
		fline=$(cat /etc/fail2ban/jail.local | grep -n dovecot-iptables -A 2)
		fline=$(echo "$fline" | grep enabled | tail -n1 | cut -f 1 -d -)
		sed -i "${fline}s/true/false/" /etc/fail2ban/jail.local
	fi
	if [ "$exim" = 'no' ]; then
		fline=$(cat /etc/fail2ban/jail.local | grep -n exim-iptables -A 2)
		fline=$(echo "$fline" | grep enabled | tail -n1 | cut -f 1 -d -)
		sed -i "${fline}s/true/false/" /etc/fail2ban/jail.local
	fi
	if [ "$vsftpd" = 'yes' ]; then
		#Create vsftpd Log File
		if [ ! -f "/var/log/vsftpd.log" ]; then
			touch /var/log/vsftpd.log
		fi
		fline=$(cat /etc/fail2ban/jail.local | grep -n vsftpd-iptables -A 2)
		fline=$(echo "$fline" | grep enabled | tail -n1 | cut -f 1 -d -)
		sed -i "${fline}s/false/true/" /etc/fail2ban/jail.local
	fi

	if [ -f /etc/fail2ban/jail.d/00-firewalld.conf ]; then
		cat /dev/null > /etc/fail2ban/jail.d/00-firewalld.conf
	fi

	sed -i "s/^backend[ ]*=[ ]*auto/backend = systemd/gi" /etc/fail2ban/jail.conf

	systemctl enable fail2ban --now
	check_result $? "fail2ban start failed"
fi

# Configuring MariaDB/MySQL host
if [ "$mysql" = 'yes' ] || [ "$mysql8" = 'yes' ]; then
	$HESTIA/bin/v-add-database-host mysql localhost root $mpass
fi

# Configuring PostgreSQL host
if [ "$postgresql" = 'yes' ]; then
	$HESTIA/bin/v-add-database-host pgsql localhost postgres $ppass
fi

#----------------------------------------------------------#
#                       Install Roundcube                  #
#----------------------------------------------------------#

# Min requirements Dovecot + Exim + Mysql
if ([ "$mysql" == 'yes' ] || [ "$mysql8" == 'yes' ]) && [ "$dovecot" == "yes" ]; then
	echo "[ * ] Install Roundcube..."
	$HESTIA/bin/v-add-sys-roundcube
	write_config_value "WEBMAIL_ALIAS" "webmail"
else
	write_config_value "WEBMAIL_ALIAS" ""
	write_config_value "WEBMAIL_SYSTEM" ""
fi

#----------------------------------------------------------#
#                     Install Sieve                        #
#----------------------------------------------------------#

# Min requirements Dovecot + Exim + Mysql + Roundcube
if [ "$sieve" = 'yes' ]; then
	# Folder paths
	RC_INSTALL_DIR="/var/lib/roundcube"
	RC_CONFIG_DIR="/etc/roundcube"

	echo "[ * ] Install Sieve..."

	# dovecot.conf install
	sed -i "s/namespace/service stats \{\n  unix_listener stats-writer \{\n    group = mail\n    mode = 0660\n    user = dovecot\n  \}\n\}\n\nnamespace/g" /etc/dovecot/dovecot.conf

	# Dovecot conf files
	#  10-master.conf
	sed -i -E -z "s/  }\n  user = dovecot\n}/  \}\n  unix_listener auth-master \{\n    group = mail\n    mode = 0660\n    user = dovecot\n  \}\n  user = dovecot\n\}/g" /etc/dovecot/conf.d/10-master.conf
	#  15-lda.conf
	sed -i "s/\#mail_plugins = \\\$mail_plugins/mail_plugins = \$mail_plugins quota sieve\n  auth_socket_path = \/run\/dovecot\/auth-master/g" /etc/dovecot/conf.d/15-lda.conf
	#  20-imap.conf
	sed -i "s/mail_plugins = quota imap_quota/mail_plugins = quota imap_quota imap_sieve/g" /etc/dovecot/conf.d/20-imap.conf

	# Replace dovecot-sieve config files
	cp -f $HESTIA_COMMON_DIR/dovecot/sieve/* /etc/dovecot/conf.d

	# Dovecot default file install
	echo -e "require [\"fileinto\"];\n# rule:[SPAM]\nif header :contains \"X-Spam-Flag\" \"YES\" {\n    fileinto \"INBOX.Spam\";\n}\n" > /etc/dovecot/sieve/default

	# exim install
	sed -i "s/\stransport = local_delivery/ transport = dovecot_virtual_delivery/" /etc/exim/exim.conf.template
	sed -i "s/address_pipe:/dovecot_virtual_delivery:\n driver = pipe\n command = \/usr\/libexec\/dovecot\/dovecot-lda -e -d \${extract{1}{:}{\${lookup{\$local_part}lsearch{\/etc\/exim4\/domains\/\${lookup{\$domain}dsearch{\/etc\/exim4\/domains\/}}\/accounts}}}}@\${lookup{\$domain}dsearch{\/etc\/exim4\/domains\/}}\n delivery_date_add\n envelope_to_add\n return_path_add\n log_output = true\n log_defer_output = true\n user = \${extract{2}{:}{\${lookup{\$local_part}lsearch{\/etc\/exim4\/domains\/\${lookup{\$domain}dsearch{\/etc\/exim4\/domains\/}}\/passwd}}}}\n group = mail\n return_output\n\naddress_pipe:/g" /etc/exim4/exim4.conf.template


	if [ -d "/var/lib/roundcube" ]; then
		# Modify Roundcube config
		mkdir -p $RC_CONFIG_DIR/plugins/managesieve
		cp -f $HESTIA_COMMON_DIR/roundcube/plugins/config_managesieve.inc.php $RC_CONFIG_DIR/plugins/managesieve/config.inc.php
		ln -s $RC_CONFIG_DIR/plugins/managesieve/config.inc.php $RC_INSTALL_DIR/plugins/managesieve/config.inc.php
		chown -R root:apache $RC_CONFIG_DIR/
		chmod 751 -R $RC_CONFIG_DIR
		chmod 644 $RC_CONFIG_DIR/*.php
		chmod 644 $RC_CONFIG_DIR/plugins/managesieve/config.inc.php
		sed -i "s/\"archive\"/\"archive\", \"managesieve\"/g" $RC_CONFIG_DIR/config.inc.php
	fi
	# Restart Dovecot and exim
	systemctl restart dovecot > /dev/null 2>&1
	systemctl restart exim > /dev/null 2>&1
fi

#----------------------------------------------------------#
#                       Configure API                      #
#----------------------------------------------------------#

if [ "$api" = "yes" ]; then
	# Keep legacy api enabled until transition is complete
	write_config_value "API" "yes"
	write_config_value "API_SYSTEM" "1"
	write_config_value "API_ALLOWED_IP" ""
else
	write_config_value "API" "no"
	write_config_value "API_SYSTEM" "0"
	write_config_value "API_ALLOWED_IP" ""
	$HESTIA/bin/v-change-sys-api disable
fi

#----------------------------------------------------------#
#                  Configure File Manager                  #
#----------------------------------------------------------#

echo "[ * ] Configuring File Manager..."
$HESTIA/bin/v-add-sys-filemanager quiet

#----------------------------------------------------------#
#                  Configure dependencies                  #
#----------------------------------------------------------#

echo "[ * ] Configuring PHP dependencies..."
$HESTIA/bin/v-add-sys-dependencies quiet

echo "[ * ] Installing Rclone"
curl -s https://rclone.org/install.sh | bash > /dev/null 2>&1

#----------------------------------------------------------#
#                   Configure IP                           #
#----------------------------------------------------------#

# Configuring system IPs
echo "[ * ] Configuring System IP..."
if [ "$nopublicip" = 'yes' ]; then
	touch $HESTIA/conf/nopublickip
fi
$HESTIA/bin/v-update-sys-ip > /dev/null 2>&1

# Get primary IP
default_nic="$(ip -d -j route show | jq -r '.[] | if .dst == "default" then .dev else empty end')"
# IPv4
primary_ipv4="$(ip -4 -d -j addr show "$default_nic" | jq -r '.[] | select(length > 0) | .addr_info[] | if .scope == "global" then .local else empty end' | head -n1)"
# IPv6
#primary_ipv6="$(ip -6 -d -j addr show "$default_nic" | jq -r '.[] | select(length > 0) | .addr_info[] | if .scope == "global" then .local else empty end' | head -n1)"
ip="$primary_ipv4"
local_ip="$primary_ipv4"


# Configuring firewall
if [ "$iptables" = 'yes' ]; then
	$HESTIA/bin/v-update-firewall
fi

# Get public IP
pub_ip=$ip
if [ "$nopublicip" = 'no' ]; then
	pub_ip=$(curl -fsLm5 --retry 2 --ipv4 -H "Simple-Hestiacp: yes" https://hestiaip.brepo.ru/)

	if [ -n "$pub_ip" ] && [ "$pub_ip" != "$ip" ]; then
		$HESTIA/bin/v-change-sys-ip-nat $ip $pub_ip > /dev/null 2>&1
		ip=$pub_ip
	fi
fi

# Configuring mod_remoteip
if [ "$apache" = 'yes' ] && [ "$nginx" = 'yes' ]; then
	cd /etc/httpd/conf.modules.d
	echo "<IfModule mod_remoteip.c>" > remoteip.conf
	echo "  RemoteIPHeader X-Real-IP" >> remoteip.conf
	if [ "$local_ip" != "127.0.0.1" ] && [ "$pub_ip" != "127.0.0.1" ]; then
		echo "  RemoteIPInternalProxy 127.0.0.1" >> remoteip.conf
	fi
	if [ -n "$local_ip" ] && [ "$local_ip" != "$pub_ip" ]; then
		echo "  RemoteIPInternalProxy $local_ip" >> remoteip.conf
	fi
	if [ -n "$pub_ip" ]; then
		echo "  RemoteIPInternalProxy $pub_ip" >> remoteip.conf
	fi
	echo "</IfModule>" >> remoteip.conf
	sed -i "s/LogFormat \"%h/LogFormat \"%a/g" /etc/httpd/conf/httpd.conf
	systemctl restart httpd
fi

#install oneshot service for hestia
echo "[ * ] Configuring One Shot Service..."
$HESTIA/bin/v-oneshot-service
if [ ! -e /etc/systemd/system/hestiacp-prepare.service ]; then
	cp -f $HESTIA_INSTALL_DIR/oneshot/hestiacp-prepare.service /etc/systemd/system/
	systemctl enable hestiacp-prepare.service --now
fi

# Adding default domain
$HESTIA/bin/v-add-web-domain admin $servername $ip
check_result $? "can't create $servername domain"

# Adding cron jobs
export SCHEDULED_RESTART="yes"
command="sudo $HESTIA/bin/v-update-sys-queue restart"
$HESTIA/bin/v-add-cron-job 'admin' '*/2' '*' '*' '*' '*' "$command"
systemctl restart crond

command="sudo $HESTIA/bin/v-update-sys-queue daily"
$HESTIA/bin/v-add-cron-job 'admin' '10' '00' '*' '*' '*' "$command"
command="sudo $HESTIA/bin/v-update-sys-queue disk"
$HESTIA/bin/v-add-cron-job 'admin' '15' '02' '*' '*' '*' "$command"
command="sudo $HESTIA/bin/v-update-sys-queue traffic"
$HESTIA/bin/v-add-cron-job 'admin' '10' '00' '*' '*' '*' "$command"
command="sudo $HESTIA/bin/v-update-sys-queue webstats"
$HESTIA/bin/v-add-cron-job 'admin' '30' '03' '*' '*' '*' "$command"
command="sudo $HESTIA/bin/v-update-sys-queue backup"
$HESTIA/bin/v-add-cron-job 'admin' '*/5' '*' '*' '*' '*' "$command"
command="sudo $HESTIA/bin/v-backup-users"
$HESTIA/bin/v-add-cron-job 'admin' '10' '05' '*' '*' '*' "$command"
command="sudo $HESTIA/bin/v-update-user-stats"
$HESTIA/bin/v-add-cron-job 'admin' '20' '00' '*' '*' '*' "$command"
command="sudo $HESTIA/bin/v-update-sys-rrd"
$HESTIA/bin/v-add-cron-job 'admin' '*/5' '*' '*' '*' '*' "$command"
command="sudo $HESTIA/bin/v-update-letsencrypt-ssl"
min=$(gen_pass '012345' '2')
hour=$(gen_pass '1234567' '1')
$HESTIA/bin/v-add-cron-job 'admin' "$min" "$hour" '*' '*' '*' "$command"

# Enable automatic updates
$HESTIA/bin/v-add-cron-hestia-autoupdate apt

# Building initital rrd images
$HESTIA/bin/v-update-sys-rrd

# Enabling file system quota
if [ "$quota" = 'yes' ]; then
	$HESTIA/bin/v-add-sys-quota
fi

# Set backend port
$HESTIA/bin/v-change-sys-port $port > /dev/null 2>&1

# Create default configuration files
$HESTIA/bin/v-update-sys-defaults

# Update remaining packages since repositories have changed
echo -ne "[ * ] Installing remaining software updates..."
dnf clean all
dnf makecache
dnf -y upgrade >> $LOG &
BACK_PID=$!

# Check if package installation is done, print a spinner
spin_i=1
while kill -0 $BACK_PID > /dev/null 2>&1; do
	printf "\b${spinner:spin_i++%${#spinner}:1}"
	sleep 0.5
done

# Do a blank echo to get the \n back
echo

# Check Installation result
wait $BACK_PID
check_result $? "dnf upgrade failed"

# Starting Hestia service
systemctl enable hestia --now
check_result $? "hestia start failed"
chown admin:admin $HESTIA/data/sessions

# Create backup folder and set correct permission
mkdir -p /backup/
chmod 755 /backup/

# Create cronjob to generate ssl
echo "@reboot root sleep 10 && rm /etc/cron.d/hestia-ssl && PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:' && /usr/local/hestia/bin/v-add-letsencrypt-host" > /etc/cron.d/hestia-ssl

#----------------------------------------------------------#
#              Set hestia.conf default values              #
#----------------------------------------------------------#

echo "[ * ] Updating configuration files..."
write_config_value "PHPMYADMIN_KEY" ""
write_config_value "POLICY_USER_VIEW_SUSPENDED" "no"
write_config_value "POLICY_USER_VIEW_LOGS" "yes"
write_config_value "POLICY_USER_EDIT_WEB_TEMPLATES" "true"
write_config_value "POLICY_USER_EDIT_DNS_TEMPLATES" "yes"
write_config_value "POLICY_USER_EDIT_DETAILS" "yes"
write_config_value "POLICY_USER_DELETE_LOGS" "yes"
write_config_value "POLICY_USER_CHANGE_THEME" "yes"
write_config_value "POLICY_SYSTEM_PROTECTED_ADMIN" "no"
write_config_value "POLICY_SYSTEM_PASSWORD_RESET" "yes"
write_config_value "POLICY_SYSTEM_HIDE_SERVICES" "no"
write_config_value "POLICY_SYSTEM_ENABLE_BACON" "no"
write_config_value "PLUGIN_APP_INSTALLER" "true"
write_config_value "DEBUG_MODE" "no"
write_config_value "ENFORCE_SUBDOMAIN_OWNERSHIP" "yes"
write_config_value "USE_SERVER_SMTP" "false"
write_config_value "SERVER_SMTP_PORT" ""
write_config_value "SERVER_SMTP_HOST" ""
write_config_value "SERVER_SMTP_SECURITY" ""
write_config_value "SERVER_SMTP_USER" ""
write_config_value "SERVER_SMTP_PASSWD" ""
write_config_value "SERVER_SMTP_ADDR" ""
write_config_value "POLICY_CSRF_STRICTNESS" "1"
write_config_value "DISABLE_IP_CHECK" "no"
write_config_value "DNS_CLUSTER_SYSTEM" "hestia"

# Add /usr/local/hestia/bin/ to path variable
echo 'if [ "${PATH#*/usr/local/hestia/bin*}" = "$PATH" ]; then
    . /etc/profile.d/hestia.sh
fi' >> /root/.bashrc

#----------------------------------------------------------#
#                   Hestia Access Info                     #
#----------------------------------------------------------#
# Get the system name
if command -v lsb_release >/dev/null; then
    os_name=$(lsb_release -sd | tr -d '"')
elif [ -f /etc/os-release ]; then
    . /etc/os-release
    os_name="${PRETTY_NAME:-$NAME}"
elif [ -f /etc/redhat-release ]; then
    os_name=$(sed 's/ release//' /etc/redhat-release)
elif [ -f /etc/debian_version ]; then
    os_name="Debian $(cat /etc/debian_version)"
else
    os_name="Unknown OS ($(uname -sr))"
fi
# Comparing hostname and IP
host_ip=$(host $servername | head -n 1 | awk '{print $NF}')
if [ "$host_ip" = "$ip" ]; then
	ip="$servername"
fi

echo -e "\n"
echo "===================================================================="
echo -e "\n"

# Sending notification to admin email
echo -e "Congratulations!\n\nYou have successfully installed Hestia $HESTIA_INSTALL_VER Control Panel on your  $os_name server.

Ready to get started? Log in using the following credentials:

	Admin URL:  https://$servername:$port" > $tmpfile
if [ "$host_ip" != "$ip" ]; then
	echo "	Backup URL: https://$ip:$port" >> $tmpfile
fi
echo -e -n " 	Username:   admin
	Password:   $displaypass

Thank you for choosing Hestia Control Panel(RPM edition) to power your full stack web server,
we hope that you enjoy using it as much as we do!

RHEL GitHub:              https://github.com/bayrepo/hestiacp-rpm
RHEL development:         https://dev.brepo.ru/bayrepo/hestiacp
RHEL Documentation:       https://hestiadocs.brepo.ru/docs
Forum:                    https://forum.hestiacp.com
DEBIAN Documentation:     https://hestiacp.com/docs

Note: Automatic updates are enabled by default. If you would like to disable them,
please log in and navigate to Server > Updates to turn them off.

--
Sincerely yours,
The Hestia Control Panel(RPM edition) development team

Made with love & pride by the open-source community around the world.
" >> $tmpfile

send_mail="$HESTIA/web/inc/mail-wrapper.php"
cat $tmpfile | $send_mail -s "Hestia Control Panel" $email

# Congrats
echo
cat $tmpfile
rm -f $tmpfile

# Add welcome message to notification panel
$HESTIA/bin/v-add-user-notification admin "Welcome to the Hestia Control Panel"  " <p>You 🎉 have successfully installed the Hestia $HESTIA_INSTALL_VER control panel on the $os_name server. We recommend that you start the configuration in the following order:</p><p>1. Create a <a href='/add/user/'> user account</a> for rights<br>management 2. Add <a href='/add/web/'> site domain</a> for deployment<br>3. Select the documentation according to your OS version:<br> 📜 <a href='https://hestiadocs.brepo.ru/docs/' target='_blank'>Red Hat (RHEL)</a> <br>🌐 documentation <a href='https://hestiacp.com/docs' target='_blank' rel='noopener noreferrer'>Official English Documentation</a><br>4. If you have any problems, please contact:<br> 💬 <a href='https://forum.hestiacp.com/' target='_blank' rel='noopener noreferrer'>Official community</a><br>🐞 <a href='https://github.com/hestiacp/hestiacp/issues' target='_blank' rel='noopener noreferrer'>Bug reports on GitHub</a><br>🔍 <a href='https://github.com/bayrepo/hestiacp/issues' target='_blank'>Issue tracker for RHEL version</a></p><p class='u-text-bold'>Useful tips:</p><p>💡 Feature suggestions should be sent to the appropriate GitHub<br>🚨 repositories In case of server issues, attach system logs to forum<br>✨ posts We wish that <a href='https://hestiacp.com' target='_blank' rel='noopener noreferrer'>Hestia</a> provides the perfect experience with your fully functional server!<br>💌 Sincerely, the development team <a href='https://hestiacp.com' target='_blank' rel='noopener noreferrer'>Hestia</a> — an open server control panel</p>"

# Clean-up
# Sort final configuration file
sort_config_file

if [ "$interactive" = 'yes' ]; then
	echo "[ ! ] IMPORTANT: The system will now reboot to complete the installation process."
	read -n 1 -s -r -p "Press any key to continue"
	reboot
else
	echo "[ ! ] IMPORTANT: You must restart the system before continuing!"
fi
# EOF
