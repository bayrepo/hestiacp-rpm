#!/bin/bash

# set -e
# Autocompile Script for HestiaCP package Files.
# For building from local source folder use "~localsrc" keyword as hesia branch name,
#   and the script will not try to download the arhive from github, since '~' char is
#   not accepted in branch name.
# Compile but dont install -> ./hst_autocompile.sh --hestia --noinstall --keepbuild '~localsrc'
# Compile and install -> ./hst_autocompile.sh --hestia --install '~localsrc'

# Clear previous screen output
clear

# Define download function
download_file() {
	local url=$1
	local destination=$2
	local force=$3

	[ "$HESTIA_DEBUG" ] && echo >&2 DEBUG: Downloading file "$url" to "$destination"

	# Default destination is the current working directory
	local dstopt=""

	if [ ! -z "$(echo "$url" | grep -E "\.(gz|gzip|bz2|zip|xz)$")" ]; then
		# When an archive file is downloaded it will be first saved localy
		dstopt="--directory-prefix=$ARCHIVE_DIR"
		local is_archive="true"
		local filename="${url##*/}"
		if [ -z "$filename" ]; then
			echo >&2 "[!] No filename was found in url, exiting ($url)"
			exit 1
		fi
		if [ ! -z "$force" ] && [ -f "$ARCHIVE_DIR/$filename" ]; then
			rm -f $ARCHIVE_DIR/$filename
		fi
	elif [ ! -z "$destination" ]; then
		# Plain files will be written to specified location
		dstopt="-O $destination"
	fi
	# check for corrupted archive
	if [ -f "$ARCHIVE_DIR/$filename" ] && [ "$is_archive" = "true" ]; then
		tar -tzf "$ARCHIVE_DIR/$filename" > /dev/null 2>&1
		if [ $? -ne 0 ]; then
			echo >&2 "[!] Archive $ARCHIVE_DIR/$filename is corrupted, redownloading"
			rm -f $ARCHIVE_DIR/$filename
		fi
	fi

	if [ ! -f "$ARCHIVE_DIR/$filename" ]; then
		[ "$HESTIA_DEBUG" ] && echo >&2 DEBUG: wget $url -q $dstopt --show-progress --progress=bar:force --limit-rate=3m
		wget $url -q $dstopt --show-progress --progress=bar:force --limit-rate=3m
		if [ $? -ne 0 ]; then
			echo >&2 "[!] Archive $ARCHIVE_DIR/$filename is corrupted and exit script"
			rm -f $ARCHIVE_DIR/$filename
			exit 1
		fi
	fi

	if [ ! -z "$destination" ] && [ "$is_archive" = "true" ]; then
		if [ "$destination" = "-" ]; then
			cat "$ARCHIVE_DIR/$filename"
		elif [ -d "$(dirname $destination)" ]; then
			cp "$ARCHIVE_DIR/$filename" "$destination"
		fi
	fi
}

get_branch_file() {
	local filename=$1
	local destination=$2
	[ "$HESTIA_DEBUG" ] && echo >&2 DEBUG: Get branch file "$filename" to "$destination"
	if [ "$use_src_folder" == 'true' ]; then
		if [ -z "$destination" ]; then
			[ "$HESTIA_DEBUG" ] && echo >&2 DEBUG: cp -f "$SRC_DIR/$filename" ./
			cp -f "$SRC_DIR/$filename" ./
		else
			[ "$HESTIA_DEBUG" ] && echo >&2 DEBUG: cp -f "$SRC_DIR/$filename" "$destination"
			cp -f "$SRC_DIR/$filename" "$destination"
		fi
	else
		download_file "https://dev.brepo.ru/bayrepo/$REPO/raw/branch/$branch/$filename" "$destination" $3
	fi
}

usage() {
	echo "Usage:"
	echo "    $0 (--all|--hestia|--nginx|--php) [options] [branch] [Y]"
	echo ""
	echo "    --all           Build all hestia packages."
	echo "    --hestia        Build only the Control Panel package."
	echo "    --nginx         Build only the backend nginx engine package."
	echo "    --php           Build only the backend php engine package"
	echo "  Options:"
	echo "    --install       Install generated packages"
	echo "    --keepbuild     Don't delete downloaded source and build folders"
	echo "    --cross         Compile hestia package for both AMD64 and ARM64"
	echo "    --debug         Debug mode"
	echo "    --npm           Rebuild nmp command"
	echo ""
	echo "For automated builds and installations, you may specify the branch"
	echo "after one of the above flags. To install the packages, specify 'Y'"
	echo "following the branch name."
	echo ""
	echo "Example: bash hst_autocompile.sh --hestia develop Y"
	echo "This would install a Hestia Control Panel package compiled with the"
	echo "develop branch code."
}

hestiacp_vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

hestiacp_check_package_version () {
    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
        return 1
    fi
	IS_RPM="$1"
	if [ "$IS_RPM" = true ]; then
	    # Check for rmp based
		pack_version=$(rpm -q --queryformat="%{VERSION}" "$2")
		if [ $? -eq 0 ]; then
			hestiacp_vercomp "$pack_version" "$3"
			RESULT_OF_COMPARISON=$?
			case "$RESULT_OF_COMPARISON" in
				0 ) return 0 ;;
				1 ) return 0 ;;
			esac
		fi
		return 1
	else
	    # Debian based not yet implemented
		return 0
	fi
}


# Set compiling directory
REPO='hestiacp/hestiacp'
BUILD_DIR='/tmp/hestiacp-src'
INSTALL_DIR='/usr/local/hestia'
SRC_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ARCHIVE_DIR="$SRC_DIR/src/archive/"
architecture="$(arch)"
if [ $architecture == 'aarch64' ]; then
	BUILD_ARCH='arm64'
else
	BUILD_ARCH='amd64'
fi
RPM_DIR="$BUILD_DIR/rpm/"
DEB_DIR="$BUILD_DIR/deb"
if [ -f '/etc/redhat-release' ]; then
	BUILD_RPM=true
	BUILD_DEB=false
	BUILD_ARCH=$(uname -i)
	OSTYPE='rhel'
	type=$(grep "^ID=" /etc/os-release | cut -f 2 -d '"')
	DISTRO=$type
	# TODO: remove this condition after testing
	if [[ "$type" =~ ^(rhel|almalinux|eurolinux|ol|rocky|centos|msvsphere)$ ]]; then
		release=$(rpm --eval='%rhel')
	fi
else
	BUILD_RPM=false
	BUILD_DEB=true
	OSTYPE='debian'
fi

# Set packages to compile
for i in $*; do
	case "$i" in
		--all)
			NGINX_B='true'
			PHP_B='true'
			HESTIA_B='true'
			;;
		--nginx)
			NGINX_B='true'
			;;
		--php)
			PHP_B='true'
			;;
		--hestia)
			HESTIA_B='true'
			;;
		--debug)
			HESTIA_DEBUG='true'
			;;
		--install | Y)
			install='true'
			;;
		--noinstall | N)
			install='false'
			;;
		--keepbuild)
			KEEPBUILD='true'
			;;
		--cross)
			CROSS='true'
			;;
		--help | -h)
			usage
			exit 1
			;;
		--dontinstalldeps)
			dontinstalldeps='true'
			;;
		--npm)
			NPM_REBUILD='true'
			;;
		*)
			branch="$i"
			;;
	esac
done

if [[ $# -eq 0 ]]; then
	usage
	exit 1
fi

# Clear previous screen output
clear

# Set command variables
if [ -z $branch ]; then
	echo -n "Please enter the name of the branch to build from (e.g. main): "
	read branch
fi

if [ $(echo "$branch" | grep '^~localsrc') ]; then
	branch=$(echo "$branch" | sed 's/^~//')
	use_src_folder='true'
else
	use_src_folder='false'
fi

if [ -z $install ]; then
	echo -n 'Would you like to install the compiled packages? [y/N] '
	read install
fi

# Set Version for compiling
if [ -e "/etc/redhat-release" ]; then
	if [ -f "$SRC_DIR/src/rpm/hestia/hestia.spec" ] && [ "$use_src_folder" == 'true' ]; then
		BUILD_VER=$(cat $SRC_DIR/src/rpm/hestia/hestia.spec | grep "Version:" | awk '{ print $2 }')
		NGINX_V=$(cat $SRC_DIR/src/rpm/nginx/hestia-nginx.spec | grep "Version:" | awk '{ print $2 }')
		PHP_V=$(cat $SRC_DIR/src/rpm/php/hestia-php.spec | grep "Version:" | awk '{ print $2 }')
	else
		BUILD_VER=$(curl -s https://raw.githubusercontent.com/$REPO/$branch/src/rpm/hestia/hestia.spec | grep "Version:" | awk '{ print $2 }')
		NGINX_V=$(curl -s https://raw.githubusercontent.com/$REPO/$branch/src/rpm/nginx/hestia-nginx.spec | grep "Version:" | awk '{ print $2 }')
		PHP_V=$(curl -s https://raw.githubusercontent.com/$REPO/$branch/src/rpm/php/hestia-php.spec | grep "Version:" | awk '{ print $2 }')
	fi
else
	if [ -f "$SRC_DIR/src/deb/hestia/control" ] && [ "$use_src_folder" == 'true' ]; then
		BUILD_VER=$(cat $SRC_DIR/src/deb/hestia/control | grep "Version:" | cut -d' ' -f2)
		NGINX_V=$(cat $SRC_DIR/src/deb/nginx/control | grep "Version:" | cut -d' ' -f2)
		PHP_V=$(cat $SRC_DIR/src/deb/php/control | grep "Version:" | cut -d' ' -f2)
	else
		BUILD_VER=$(curl -s https://raw.githubusercontent.com/$REPO/$branch/src/deb/hestia/control | grep "Version:" | cut -d' ' -f2)
		NGINX_V=$(curl -s https://raw.githubusercontent.com/$REPO/$branch/src/deb/nginx/control | grep "Version:" | cut -d' ' -f2)
		PHP_V=$(curl -s https://raw.githubusercontent.com/$REPO/$branch/src/deb/php/control | grep "Version:" | cut -d' ' -f2)
	fi
fi

if [ -z "$BUILD_VER" ]; then
	echo "Error: Branch invalid, could not detect version"
	exit 1
fi

echo "Build version $BUILD_VER, with Nginx version $NGINX_V and PHP version $PHP_V"

if [ -e "/etc/redhat-release" ]; then
	HESTIA_V="${BUILD_VER}"
else
	HESTIA_V="${BUILD_VER}_${BUILD_ARCH}"
fi
OPENSSL_V='3.1.1'
PCRE_V='10.42'
ZLIB_V='1.2.13'

# Create build directories
if [ "$KEEPBUILD" != 'true' ]; then
	rm -rf $BUILD_DIR
fi
mkdir -p $BUILD_DIR
mkdir -p $DEB_DIR
mkdir -p $RPM_DIR
mkdir -p $ARCHIVE_DIR

# Define a timestamp function
timestamp() {
	date +%s
}

if [ "$dontinstalldeps" != 'true' ]; then
	# Install needed software
	if [ "$OSTYPE" = 'rhel' ]; then
		# Set package dependencies for compiling
		SOFTWARE='wget tar git mock'

		echo "Updating system DNF repositories..."
		dnf install -y -q dnf-plugins-core epel-release
		if [ "$release" -eq 8 ]; then
			dnf config-manager --set-enabled powertools > /dev/null 2>&1
		else
			dnf config-manager --set-enabled crb > /dev/null 2>&1
		fi
		dnf upgrade -y -q
		echo "Installing dependencies for compilation..."
		dnf install -y -q $SOFTWARE

		mock -r alma+epel-${release}-$BUILD_ARCH --clean
	else
		# Set package dependencies for compiling
		SOFTWARE='wget tar git curl build-essential libxml2-dev libz-dev libzip-dev libgmp-dev libcurl4-gnutls-dev unzip openssl libssl-dev pkg-config libsqlite3-dev libonig-dev rpm lsb-release'

		echo "Updating system APT repositories..."
		apt-get -qq update > /dev/null 2>&1
		echo "Installing dependencies for compilation..."
		apt-get -qq install -y $SOFTWARE > /dev/null 2>&1

		# Fix for Debian PHP Envroiment
		if [ $BUILD_ARCH == "amd64" ]; then
			if [ ! -L /usr/local/include/curl ]; then
				ln -s /usr/include/x86_64-linux-gnu/curl /usr/local/include/curl
			fi
		fi
	fi
fi

# Get system cpu cores
NUM_CPUS=$(grep "^cpu cores" /proc/cpuinfo | uniq | awk '{print $4}')

if [ "$HESTIA_DEBUG" ]; then
	if [ "$OSTYPE" = 'rhel' ]; then
		echo "OS type          : RHEL / Rocky Linux / AlmaLinux / EuroLinux / MSVSphere"
	else
		echo "OS type          : Debian / Ubuntu"
	fi
	echo "Branch           : $branch"
	echo "Install          : $install"
	echo "Build RPM        : $BUILD_RPM"
	echo "Build DEB        : $BUILD_DEB"
	echo "Hestia version   : $BUILD_VER"
	echo "Nginx version    : $NGINX_V"
	echo "PHP version      : $PHP_V"
	echo "Architecture     : $BUILD_ARCH"
	echo "Debug mode       : $HESTIA_DEBUG"
	echo "Source directory : $SRC_DIR"
fi

# Generate Links for sourcecode
HESTIA_ARCHIVE_LINK='https://github.com/hestiacp/hestiacp/archive/'$branch'.tar.gz'
if [[ $NGINX_V =~ - ]]; then
	NGINX='https://nginx.org/download/nginx-'$(echo $NGINX_V | cut -d"-" -f1)'.tar.gz'
else
	NGINX='https://nginx.org/download/nginx-'$(echo $NGINX_V | cut -d"~" -f1)'.tar.gz'
fi

OPENSSL='https://www.openssl.org/source/openssl-'$OPENSSL_V'.tar.gz'
PCRE='https://github.com/PCRE2Project/pcre2/releases/download/pcre2-'$PCRE_V'/pcre2-'$PCRE_V'.tar.gz'
ZLIB='https://github.com/madler/zlib/archive/refs/tags/v'$ZLIB_V'.tar.gz'

if [[ $PHP_V =~ - ]]; then
	PHP='http://de2.php.net/distributions/php-'$(echo $PHP_V | cut -d"-" -f1)'.tar.gz'
else
	PHP='http://de2.php.net/distributions/php-'$(echo $PHP_V | cut -d"~" -f1)'.tar.gz'
fi

# Forward slashes in branchname are replaced with dashes to match foldername in github archive.
branch_dash=$(echo "$branch" | sed 's/\//-/g')

#################################################################################
#
# Building hestia-nginx
#
#################################################################################

if [ "$NGINX_B" = true ]; then
	echo "Building hestia-nginx package..."
	if [ "$CROSS" = "true" ]; then
		echo "Cross compile not supported for hestia-nginx or hestia-php"
		exit 1
	fi

	if [ "$BUILD_DEB" = true ]; then
		# Change to build directory
		cd $BUILD_DIR

		BUILD_DIR_HESTIANGINX=$BUILD_DIR/hestia-nginx_$NGINX_V
		if [[ $NGINX_V =~ - ]]; then
			BUILD_DIR_NGINX=$BUILD_DIR/nginx-$(echo $NGINX_V | cut -d"-" -f1)
		else
			BUILD_DIR_NGINX=$BUILD_DIR/nginx-$(echo $NGINX_V | cut -d"~" -f1)
		fi

		if [ "$KEEPBUILD" != 'true' ] || [ ! -d "$BUILD_DIR_HESTIANGINX" ]; then
			# Check if target directory exist
			if [ -d "$BUILD_DIR_HESTIANGINX" ]; then
				#mv $BUILD_DIR/hestia-nginx_$NGINX_V $BUILD_DIR/hestia-nginx_$NGINX_V-$(timestamp)
				rm -r "$BUILD_DIR_HESTIANGINX"
			fi

			# Create directory
			mkdir -p $BUILD_DIR_HESTIANGINX

			# Download and unpack source files
			download_file $NGINX '-' | tar xz
			download_file $OPENSSL '-' | tar xz
			download_file $PCRE '-' | tar xz
			download_file $ZLIB '-' | tar xz

			# Change to nginx directory
			cd $BUILD_DIR_NGINX

			# configure nginx
			./configure --prefix=/usr/local/hestia/nginx \
				--with-http_v2_module \
				--with-http_ssl_module \
				--with-openssl=../openssl-$OPENSSL_V \
				--with-openssl-opt=enable-ec_nistp_64_gcc_128 \
				--with-openssl-opt=no-nextprotoneg \
				--with-openssl-opt=no-weak-ssl-ciphers \
				--with-openssl-opt=no-ssl3 \
				--with-pcre=../pcre2-$PCRE_V \
				--with-pcre-jit \
				--with-zlib=../zlib-$ZLIB_V
		fi

		# Change to nginx directory
		cd $BUILD_DIR_NGINX

		# Check install directory and remove if exists
		if [ -d "$BUILD_DIR$INSTALL_DIR" ]; then
			rm -r "$BUILD_DIR$INSTALL_DIR"
		fi

		# Copy local hestia source files
		if [ "$use_src_folder" == 'true' ] && [ -d $SRC_DIR ]; then
			cp -rf "$SRC_DIR/" $BUILD_DIR/hestiacp-$branch_dash
		fi

		# Create the files and install them
		make -j $NUM_CPUS && make DESTDIR=$BUILD_DIR install

		# Clear up unused files
		if [ "$KEEPBUILD" != 'true' ]; then
			rm -r $BUILD_DIR_NGINX $BUILD_DIR/openssl-$OPENSSL_V $BUILD_DIR/pcre2-$PCRE_V $BUILD_DIR/zlib-$ZLIB_V
		fi
		cd $BUILD_DIR_HESTIANGINX

		# Move nginx directory
		mkdir -p $BUILD_DIR_HESTIANGINX/usr/local/hestia
		rm -rf $BUILD_DIR_HESTIANGINX/usr/local/hestia/nginx
		mv $BUILD_DIR/usr/local/hestia/nginx $BUILD_DIR_HESTIANGINX/usr/local/hestia/

		# Remove original nginx.conf (will use custom)
		rm -f $BUILD_DIR_HESTIANGINX/usr/local/hestia/nginx/conf/nginx.conf

		# copy binary
		mv $BUILD_DIR_HESTIANGINX/usr/local/hestia/nginx/sbin/nginx $BUILD_DIR_HESTIANGINX/usr/local/hestia/nginx/sbin/hestia-nginx

		# change permission and build the package
		cd $BUILD_DIR
		chown -R root:root $BUILD_DIR_HESTIANGINX
		# Get Debian package files
		mkdir -p $BUILD_DIR_HESTIANGINX/DEBIAN
		get_branch_file 'src/deb/nginx/control' "$BUILD_DIR_HESTIANGINX/DEBIAN/control"
		if [ "$BUILD_ARCH" != "amd64" ]; then
			sed -i "s/amd64/${BUILD_ARCH}/g" "$BUILD_DIR_HESTIANGINX/DEBIAN/control"
		fi
		get_branch_file 'src/deb/nginx/copyright' "$BUILD_DIR_HESTIANGINX/DEBIAN/copyright"
		get_branch_file 'src/deb/nginx/postinst' "$BUILD_DIR_HESTIANGINX/DEBIAN/postinst"
		get_branch_file 'src/deb/nginx/postrm' "$BUILD_DIR_HESTIANGINX/DEBIAN/portrm"
		chmod +x "$BUILD_DIR_HESTIANGINX/DEBIAN/postinst"
		chmod +x "$BUILD_DIR_HESTIANGINX/DEBIAN/portrm"

		# Init file
		mkdir -p $BUILD_DIR_HESTIANGINX/etc/init.d
		get_branch_file 'src/deb/nginx/hestia' "$BUILD_DIR_HESTIANGINX/etc/init.d/hestia"
		chmod +x "$BUILD_DIR_HESTIANGINX/etc/init.d/hestia"

		# Custom config
		get_branch_file 'src/deb/nginx/nginx.conf' "${BUILD_DIR_HESTIANGINX}/usr/local/hestia/nginx/conf/nginx.conf"

		# Build the package
		echo Building Nginx DEB
		dpkg-deb -Zxz --build $BUILD_DIR_HESTIANGINX $DEB_DIR

		rm -r $BUILD_DIR/usr

		if [ "$KEEPBUILD" != 'true' ]; then
			# Clean up the source folder
			rm -r hestia- nginx_$NGINX_V
			rm -rf $BUILD_DIR/rpmbuild
			if [ "$use_src_folder" == 'true' ] && [ -d $BUILD_DIR/hestiacp-$branch_dash ]; then
				rm -r $BUILD_DIR/hestiacp-$branch_dash
			fi
		fi
	fi

	if [ "$BUILD_RPM" = true ]; then
		# Get RHEL package files
		get_branch_file 'src/rpm/nginx/nginx.conf' "$BUILD_DIR/nginx.conf"
		get_branch_file 'src/rpm/nginx/hestia-nginx.spec' "$BUILD_DIR/hestia-nginx.spec"
		get_branch_file 'src/rpm/nginx/hestia-nginx.service' "$BUILD_DIR/hestia-nginx.service"

		# Download source files
		download_file $NGINX $BUILD_DIR

		# Build the package
		echo Building Nginx RPM
		mock -r alma+epel-${release}-$BUILD_ARCH --sources $BUILD_DIR --spec $BUILD_DIR/hestia-nginx.spec --resultdir $RPM_DIR
		rm -f $BUILD_DIR/*
	fi
fi

#################################################################################
#
# Building hestia-php
#
#################################################################################

if [ "$PHP_B" = true ]; then
	if [ "$CROSS" = "true" ]; then
		echo "Cross compile not supported for hestia-nginx or hestia-php"
		exit 1
	fi

	echo "Building hestia-php package..."

	if [ "$BUILD_DEB" = true ]; then
		BUILD_DIR_HESTIAPHP=$BUILD_DIR/hestia-php_$PHP_V

		BUILD_DIR_PHP=$BUILD_DIR/php-$(echo $PHP_V | cut -d"~" -f1)

		if [[ $PHP_V =~ - ]]; then
			BUILD_DIR_PHP=$BUILD_DIR/php-$(echo $PHP_V | cut -d"-" -f1)
		else
			BUILD_DIR_PHP=$BUILD_DIR/php-$(echo $PHP_V | cut -d"~" -f1)
		fi

		if [ "$KEEPBUILD" != 'true' ] || [ ! -d "$BUILD_DIR_HESTIAPHP" ]; then
			# Check if target directory exist
			if [ -d $BUILD_DIR_HESTIAPHP ]; then
				rm -r $BUILD_DIR_HESTIAPHP
			fi

			# Create directory
			mkdir -p $BUILD_DIR_HESTIAPHP

			# Download and unpack source files
			cd $BUILD_DIR
			download_file $PHP '-' | tar xz

			# Change to untarred php directory
			cd $BUILD_DIR_PHP

			# Configure PHP
			./configure --prefix=/usr/local/hestia/php \
				--with-libdir=lib/$(arch)-linux-gnu \
				--enable-fpm --with-fpm-user=admin --with-fpm-group=admin \
				--with-openssl \
				--with-mysqli \
				--with-gettext \
				--with-curl \
				--with-zip \
				--with-gmp \
				--enable-mbstring
		fi

		cd $BUILD_DIR_PHP

		# Create the files and install them
		make -j $NUM_CPUS && make INSTALL_ROOT=$BUILD_DIR install

		# Copy local hestia source files
		if [ "$use_src_folder" == 'true' ] && [ -d $SRC_DIR ]; then
			[ "$HESTIA_DEBUG" ] && echo DEBUG: cp -rf "$SRC_DIR/" $BUILD_DIR/hestiacp-$branch_dash
			cp -rf "$SRC_DIR/" $BUILD_DIR/hestiacp-$branch_dash
		fi
		# Move php directory
		[ "$HESTIA_DEBUG" ] && echo DEBUG: mkdir -p $BUILD_DIR_HESTIAPHP/usr/local/hestia
		mkdir -p $BUILD_DIR_HESTIAPHP/usr/local/hestia

		[ "$HESTIA_DEBUG" ] && echo DEBUG: rm -r $BUILD_DIR_HESTIAPHP/usr/local/hestia/php
		if [ -d $BUILD_DIR_HESTIAPHP/usr/local/hestia/php ]; then
			rm -r $BUILD_DIR_HESTIAPHP/usr/local/hestia/php
		fi

		[ "$HESTIA_DEBUG" ] && echo DEBUG: mv ${BUILD_DIR}/usr/local/hestia/php ${BUILD_DIR_HESTIAPHP}/usr/local/hestia/
		mv ${BUILD_DIR}/usr/local/hestia/php ${BUILD_DIR_HESTIAPHP}/usr/local/hestia/

		# copy binary
		[ "$HESTIA_DEBUG" ] && echo DEBUG: cp $BUILD_DIR_HESTIAPHP/usr/local/hestia/php/sbin/php-fpm $BUILD_DIR_HESTIAPHP/usr/local/hestia/php/sbin/hestia-php
		cp $BUILD_DIR_HESTIAPHP/usr/local/hestia/php/sbin/php-fpm $BUILD_DIR_HESTIAPHP/usr/local/hestia/php/sbin/hestia-php

		# Change permissions and build the package
		chown -R root:root $BUILD_DIR_HESTIAPHP
		# Get Debian package files
		[ "$HESTIA_DEBUG" ] && echo DEBUG: mkdir -p $BUILD_DIR_HESTIAPHP/DEBIAN
		mkdir -p $BUILD_DIR_HESTIAPHP/DEBIAN
		get_branch_file 'src/deb/php/control' "$BUILD_DIR_HESTIAPHP/DEBIAN/control"
		if [ "$BUILD_ARCH" != "amd64" ]; then
			sed -i "s/amd64/${BUILD_ARCH}/g" "$BUILD_DIR_HESTIAPHP/DEBIAN/control"
		fi

		os=$(lsb_release -is)
		release=$(lsb_release -rs)
		if [[ "$os" = "Ubuntu" ]] && [[ "$release" = "20.04" ]]; then
			sed -i "/Conflicts: libzip5/d" "$BUILD_DIR_HESTIAPHP/DEBIAN/control"
			sed -i "s/libzip4/libzip5/g" "$BUILD_DIR_HESTIAPHP/DEBIAN/control"
		fi

		get_branch_file 'src/deb/php/copyright' "$BUILD_DIR_HESTIAPHP/DEBIAN/copyright"
		get_branch_file 'src/deb/php/postinst' "$BUILD_DIR_HESTIAPHP/DEBIAN/postinst"
		chmod +x $BUILD_DIR_HESTIAPHP/DEBIAN/postinst
		# Get custom config
		get_branch_file 'src/deb/php/php-fpm.conf' "${BUILD_DIR_HESTIAPHP}/usr/local/hestia/php/etc/php-fpm.conf"
		get_branch_file 'src/deb/php/php.ini' "${BUILD_DIR_HESTIAPHP}/usr/local/hestia/php/lib/php.ini"

		# Build the package
		echo Building PHP DEB
		[ "$HESTIA_DEBUG" ] && echo DEBUG: dpkg-deb -Zxz --build $BUILD_DIR_HESTIAPHP $DEB_DIR
		dpkg-deb -Zxz --build $BUILD_DIR_HESTIAPHP $DEB_DIR

		rm -r $BUILD_DIR/usr

		# clear up the source folder
		if [ "$KEEPBUILD" != 'true' ]; then
			rm -r $BUILD_DIR/php-$(echo $PHP_V | cut -d"~" -f1)
			rm -r $BUILD_DIR_HESTIAPHP
			if [ "$use_src_folder" == 'true' ] && [ -d $BUILD_DIR/hestiacp-$branch_dash ]; then
				rm -r $BUILD_DIR/hestiacp-$branch_dash
			fi
		fi
	fi

	if [ "$BUILD_RPM" = true ]; then
		# Get RHEL package files
		get_branch_file 'src/rpm/php/php-fpm.conf' "$BUILD_DIR/php-fpm.conf"
		get_branch_file 'src/rpm/php/php.ini' "$BUILD_DIR/php.ini"
		get_branch_file 'src/rpm/php/hestia-php.spec' "$BUILD_DIR/hestia-php.spec"
		get_branch_file 'src/rpm/php/hestia-php.service' "$BUILD_DIR/hestia-php.service"

		# Download source files
		download_file $PHP "$BUILD_DIR/"

		# Build RPM package
		echo Building PHP RPM
		mock -r alma+epel-${release}-$BUILD_ARCH --sources $BUILD_DIR --spec $BUILD_DIR/hestia-php.spec --resultdir $RPM_DIR
		rm -f $BUILD_DIR/*
	fi
fi

#################################################################################
#
# Building hestia
#
#################################################################################

arch="$BUILD_ARCH"

if [ "$HESTIA_B" = true ]; then
	if [ "$CROSS" = "true" ]; then
		arch="amd64 arm64"
	fi
	for BUILD_ARCH in $arch; do
		echo "Building Hestia Control Panel package..."

		if [ "$BUILD_DEB" = true ]; then
			BUILD_DIR_HESTIA=$BUILD_DIR/hestia_$HESTIA_V

			# Change to build directory
			cd $BUILD_DIR

			if [ "$KEEPBUILD" != 'true' ] || [ ! -d "$BUILD_DIR_HESTIA" ]; then
				# Check if target directory exist
				if [ -d $BUILD_DIR_HESTIA ]; then
					rm -r $BUILD_DIR_HESTIA
				fi

				# Create directory
				mkdir -p $BUILD_DIR_HESTIA
			fi

			cd $BUILD_DIR
			rm -rf $BUILD_DIR/hestiacp-$branch_dash
			# Download and unpack source files
			if [ "$use_src_folder" == 'true' ]; then
				[ "$HESTIA_DEBUG" ] && echo DEBUG: cp -rf "$SRC_DIR/" $BUILD_DIR/hestiacp-$branch_dash
				cp -rf "$SRC_DIR/" $BUILD_DIR/hestiacp-$branch_dash
			elif [ -d $SRC_DIR ]; then
				download_file $HESTIA_ARCHIVE_LINK '-' 'fresh' | tar xz
			fi

			mkdir -p $BUILD_DIR_HESTIA/usr/local/hestia

			# Move needed directories
			cd $BUILD_DIR/hestiacp-$branch_dash
			cp -rf bin func install web $BUILD_DIR_HESTIA/usr/local/hestia/

			# Set permissions
			find $BUILD_DIR_HESTIA/usr/local/hestia/ -type f -exec chmod -x {} \;

			# Allow send email via /usr/local/hestia/web/inc/mail-wrapper.php via cli
			chmod +x $BUILD_DIR_HESTIA/usr/local/hestia/web/inc/mail-wrapper.php
			# Allow the executable to be executed
			chmod +x $BUILD_DIR_HESTIA/usr/local/hestia/bin/*
			find $BUILD_DIR_HESTIA/usr/local/hestia/install/ \( -name '*.sh' \) -exec chmod +x {} \;
			chmod -x $BUILD_DIR_HESTIA/usr/local/hestia/install/*.sh
			chown -R root:root $BUILD_DIR_HESTIA
			# Get Debian package files
			mkdir -p $BUILD_DIR_HESTIA/DEBIAN
			get_branch_file 'src/deb/hestia/control' "$BUILD_DIR_HESTIA/DEBIAN/control"
			if [ "$BUILD_ARCH" != "amd64" ]; then
				sed -i "s/amd64/${BUILD_ARCH}/g" "$BUILD_DIR_HESTIA/DEBIAN/control"
			fi
			get_branch_file 'src/deb/hestia/copyright' "$BUILD_DIR_HESTIA/DEBIAN/copyright"
			get_branch_file 'src/deb/hestia/preinst' "$BUILD_DIR_HESTIA/DEBIAN/preinst"
			get_branch_file 'src/deb/hestia/postinst' "$BUILD_DIR_HESTIA/DEBIAN/postinst"
			chmod +x $BUILD_DIR_HESTIA/DEBIAN/postinst
			chmod +x $BUILD_DIR_HESTIA/DEBIAN/preinst

			echo Building Hestia DEB
			dpkg-deb -Zxz --build $BUILD_DIR_HESTIA $DEB_DIR

			# clear up the source folder
			if [ "$KEEPBUILD" != 'true' ]; then
				rm -r $BUILD_DIR_HESTIA
				rm -rf hestiacp-$branch_dash
			fi
			cd $BUILD_DIR/hestiacp-$branch_dash
		fi

		if [ "$BUILD_RPM" = true ]; then

			# Get RHEL package files
			get_branch_file 'src/rpm/hestia/hestia.spec' "$BUILD_DIR/hestia.spec"
			get_branch_file 'src/rpm/hestia/hestia.service' "$BUILD_DIR/hestia.service"
			get_branch_file 'src/rpm/hestia/hestia.tmpfiles' "$BUILD_DIR/hestia.tmpfiles"

			#Get nodejs 20.x version
			if [ "$NPM_REBUILD" = true ]; then
				echo "Update nodejs up to 20.x version"
				hestiacp_check_package_version $BUILD_RPM "nodejs" "20.0"
				IS_NEEDED_NODEJS=$?
				if [ "$IS_NEEDED_NODEJS" = "1" ]; then
					dnf erase nodejs -y
					curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
					dnf install nodejs -y
				fi
				pushd "$SRC_DIR" || { echo "Can't change directory to $SRC_DIR, javascript rebuild aborted"; exit 1; }
				npm install
				npm run build
				popd || { echo "Can't restore directory from $SRC_DIR, javascript rebuild aborted"; exit 1; }
			fi

			#Prepare mo files
			pushd ../web/locale
			./hst_convert_po2mo.sh
			popd

			# Generate source tar.gz
			tar -h --exclude=".git" --exclude=".github" --exclude=".husky" --exclude=".vscode" --exclude="node_modules" --exclude="src/archive" --exclude="*.po" --exclude="*.mo.orig" -czf $BUILD_DIR/hestia-$BUILD_VER.tar.gz -C $SRC_DIR/.. hestiacp

			# Build RPM package
			echo Building Hestia RPM
			mock -r alma+epel-${release}-$BUILD_ARCH --sources $BUILD_DIR --spec $BUILD_DIR/hestia.spec --resultdir $RPM_DIR
			rm -f $BUILD_DIR/*
		fi

	done
fi

#################################################################################
#
# Install Packages
#
#################################################################################

if [ "$install" = 'yes' ] || [ "$install" = 'y' ] || [ "$install" = 'true' ]; then
	# Install all available packages
	echo "Installing packages..."
	if [ "$OSTYPE" = 'rhel' ]; then
	    rpms=""
		for i in $(ls $RPM_DIR/*.rpm | grep -v '\.src\.rpm'); do
			rpms+="$RPM_DIR/$i "
		done
		dnf -y localinstall $rpms
		if [ $? -ne 0 ]; then
			exit 1
		fi
	else
		for i in $DEB_DIR/*.deb; do
			dpkg -i $i
			if [ $? -ne 0 ]; then
				exit 1
			fi
		done
	fi
	unset $answer
fi
