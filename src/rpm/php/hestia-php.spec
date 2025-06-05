%global _hardened_build 1
%global _prefix         /usr/local/hestia/php

Name:           hestia-php
Version:        8.2.28
Release:        1%{dist}
Summary:        Hestia internal PHP
Group:          System Environment/Base
URL:            https://www.hestiacp.com
Source0:        https://www.php.net/distributions/php-%{version}.tar.gz
Source1:        hestia-php.service
Source2:        php-fpm.conf
Source3:        php.ini
License:        PHP and Zend and BSD and MIT and ASL 1.0 and NCSA
Vendor:         hestiacp.com

BuildRequires:  gcc
BuildRequires:  gcc-c++
BuildRequires:  make
BuildRequires:  libtool
BuildRequires:  autoconf
BuildRequires:  automake
BuildRequires:  bison
BuildRequires:  gnupg2
BuildRequires:  bzip2-devel
BuildRequires:  openssl-devel
BuildRequires:  re2c
BuildRequires:  gmp-devel
BuildRequires:  oniguruma-devel
BuildRequires:  libzip-devel
BuildRequires:  pkgconfig(libcurl)  >= 7.61.0
BuildRequires:  pkgconfig(libxml-2.0)  >= 2.9.7
BuildRequires:  pkgconfig(sqlite3) >= 3.26.0
BuildRequires:  systemd

%description
This package contains internal PHP for Hestia Control Panel web interface.

%prep
%autosetup -p1 -n php-%{version}

# https://bugs.php.net/63362 - Not needed but installed headers.
# Drop some Windows specific headers to avoid installation,
# before build to ensure they are really not needed.
rm -f TSRM/tsrm_win32.h \
      TSRM/tsrm_config.w32.h \
      Zend/zend_config.w32.h \
      ext/mysqlnd/config-win.h \
      ext/standard/winver.h \
      main/win32_internal_function_disabled.h \
      main/win95nt.h

%build
%if 0%{?rhel} > 8
# This package fails to build with LTO due to undefined symbols.  LTO
# was disabled in OpenSuSE as well, but with no real explanation why
# beyond the undefined symbols.  It really should be investigated further.
# Disable LTO
%define _lto_cflags %{nil}
%endif
%configure --sysconfdir=%{_prefix}%{_sysconfdir} \
		--with-libdir=%{_libdir} \
		--enable-fpm --with-fpm-user=admin --with-fpm-group=admin \
		--with-openssl \
		--with-mysqli \
		--with-gettext \
		--with-curl \
		--with-zip \
		--with-gmp \
		--enable-mbstring
%make_build

%install
mkdir -p %{buildroot}%{_unitdir} %{buildroot}/usr/local/hestia/php/{etc,lib}
mkdir -p %{buildroot}%{_unitdir} %{buildroot}/usr/local/hestia/php/var/{log,run}

%make_install INSTALL_ROOT=$RPM_BUILD_ROOT

install -m644 %{SOURCE1} %{buildroot}%{_unitdir}/hestia-php.service
cp %{SOURCE2} %{buildroot}/usr/local/hestia/php/etc/
cp %{SOURCE3} %{buildroot}/usr/local/hestia/php/lib/

%clean

%pre

%post
%systemd_post hestia-php.service

%preun
%systemd_preun hestia-php.service

%postun
%systemd_postun_with_restart hestia-php.service

%files
%defattr(-,root,root)
%attr(755,root,root) /usr/local/hestia/php
%attr(775,admin,admin) /usr/local/hestia/php/var/log
%attr(775,admin,admin) /usr/local/hestia/php/var/run
%config(noreplace) /usr/local/hestia/php/etc/php-fpm.conf
%config(noreplace) /usr/local/hestia/php/lib/php.ini
%{_unitdir}/hestia-php.service

%changelog
* Tue Jun 3 2025 Alexey Berezhok <a@bayrepo.ru> - 8.2.28-1
- Update PHP version up to 8.2.28

* Sat Jul 22 2023 Raven <raven@sysadmins.ws> - 8.2.8-1
- update PHP version to 8.2.8

* Sat Jun  3 2023 Raven <raven@sysadmins.ws> - 8.2.7-1
- update PHP version to 8.2.7
- spec file cleanup

* Sun May 14 2023 Istiak Ferdous <hello@istiak.com> - 8.2.6-1
- HestiaCP RHEL 9 support

* Thu Jun 25 2020 Ernesto Nicolás Carrea <equistango@gmail.com> - 7.4.6
- HestiaCP CentOS 8 support
