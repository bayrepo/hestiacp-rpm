#!/bin/bash

# ======================================================== #
#
# Hestia Control Panel Installation Routine
# Automatic OS detection wrapper
# https://hestiadocs.brepo.ru/
#
# Supported Operating Systems:
#
# AlmaLinux, EuroLinux, Red Hat EnterPrise Linux, Rocky Linux, MSVSphere 9
#
# ======================================================== #

# Am I root?
if [ "x$(id -u)" != 'x0' ]; then
	echo 'Error: this script can only be executed by root'
	exit 1
fi

# Check admin user account
if [ ! -z "$(grep ^admin: /etc/passwd)" ] && [ -z "$1" ]; then
	echo "Error: user admin exists"
	echo
	echo 'Please remove admin user before proceeding.'
	echo 'If you want to do it automatically run installer with -f option:'
	echo "Example: bash $0 --force"
	exit 1
fi

# Check admin group
if [ ! -z "$(grep ^admin: /etc/group)" ] && [ -z "$1" ]; then
	echo "Error: group admin exists"
	echo
	echo 'Please remove admin group before proceeding.'
	echo 'If you want to do it automatically run installer with -f option:'
	echo "Example: bash $0 --force"
	exit 1
fi

# Detect OS
if [ -e "/etc/os-release" ] && [ ! -e "/etc/redhat-release" ]; then
	type="NoSupport"
elif [ -e "/etc/os-release" ] && [ -e "/etc/redhat-release" ]; then
	type=$(grep "^ID=" /etc/os-release | cut -f 2 -d '"')
	VERSION=$type
	# TODO: Not sure if this required
	if [[ "$type" =~ ^(rhel|almalinux|eurolinux|ol|rocky|centos|msvsphere)$ ]]; then
		release=$(rpm --eval='%rhel')
	fi
else
	type="NoSupport"
fi

no_support_message() {
	echo "****************************************************"
	echo "Your operating system (OS) is not supported by"
	echo "Hestia Control Panel (RPM edition). Officially supported releases:"
	echo "****************************************************"
	echo "  Red Hat Enterprise Linux 9 and related versions of"
	echo "  AlmaLinux, Rocky Linux, Oracle Linux Server and EuroLinux, MSVSphere"
	echo ""
	exit 1
}

if [ "$type" = "NoSupport" ]; then
	no_support_message
fi

check_wget_curl() {
	# Check wget
	if [ -e '/usr/bin/wget' ]; then
		if [ -e '/etc/redhat-release' ]; then
			wget -q https://dev.brepo.ru/bayrepo/hestiacp/raw/branch/master/install/hst-install-rhel.sh -O hst-install-rhel.sh
			if [ "$?" -eq '0' ]; then
				bash hst-install-rhel.sh $*
				exit $?
			else
				echo "Error: hst-install-rhel.sh download failed."
				exit 1
			fi
		else
			wget -q https://dev.brepo.ru/bayrepo/hestiacp/raw/branch/master/install/hst-install-$type.sh -O hst-install-$type.sh
			if [ "$?" -eq '0' ]; then
				bash hst-install-$type.sh $*
				exit
			else
				echo "Error: hst-install-$type.sh download failed."
				exit 1
			fi
		fi
	fi

	# Check curl
	if [ -e '/usr/bin/curl' ]; then
		if [ -e '/etc/redhat-release' ]; then
			curl -s -O https://dev.brepo.ru/bayrepo/hestiacp/raw/branch/master/install/hst-install-rhel.sh
			if [ "$?" -eq '0' ]; then
				bash hst-install-rhel.sh $*
				exit $?
			else
				echo "Error: hst-install-rhel.sh download failed."
				exit 1
			fi
		else
			curl -s -O https://dev.brepo.ru/bayrepo/hestiacp/raw/branch/master/install/hst-install-$type.sh
			if [ "$?" -eq '0' ]; then
				bash hst-install-$type.sh $*
				exit
			else
				echo "Error: hst-install-$type.sh download failed."
				exit 1
			fi
		fi
	fi
}

# Check for supported operating system before proceeding with download
# of OS-specific installer, and throw error message if unsupported OS detected.
if [[ "$release" =~ ^(10|11|12|20.04|22.04)$ ]]; then
	check_wget_curl $*
elif [[ -e "/etc/redhat-release" ]] && [[ "$release" =~ ^(8|9)$ ]]; then
	check_wget_curl $*
else
	no_support_message
fi

exit
