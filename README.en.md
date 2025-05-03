<div align="center">

# [Hestia Control Panel (RPM Edition)](https://hestiadocs.brepo.ru)

![HestiaCP Web Interface screenshot](./docs/public/images/demo.png)

## A lightweight and powerful server control panel for modern web hosting environments

**Stable Version:** 1.9.5 (RPM) |
[RPM Edition](https://hestiadocs.brepo.ru) |
[Original Ubuntu/Debian Project](https://hestiacp.com) |
[Changelog](/CHANGELOG.md) |
[Support Forum](https://forum.hestiacp.com)
<br><br>
[![Drone Status](https://drone.hestiacp.com/api/badges/hestiacp/hestiacp/status.svg?ref=refs/heads/main)](https://drone.hestiacp.com/hestiacp/hestiacp)
[![Lint Status](https://github.com/hestiacp/hestiacp/actions/workflows/lint.yml/badge.svg)](https://github.com/hestiacp/hestiacp/actions/workflows/lint.yml)
[![Gurubase](https://img.shields.io/badge/Gurubase-Ask%20Hestia%20Guru-006BFF)](https://gurubase.io/g/hestia)

</div>

Hestia Control Panel (RPM Edition) is maintained and developed by a separate team focused on RPM-based operating systems. Since forking from the original project, this edition has incorporated changes that prevent direct syncing with upstream updates from the Ubuntu/Debian version (not all features are relevant for RPM systems). Therefore, found issues should be reported specifically to this project.

Below is the general panel description.

## **Welcome!**

Hestia Control Panel aims to provide administrators with an easy-to-use web interface and CLI for quickly deploying and managing web domains, email accounts, DNS zones, and databases through a centralized panel - eliminating the need for manual configuration of individual components.

## Features & Services

- Apache2 & NGINX with PHP-FPM
- Multiple PHP versions (7.4[EOL](https://www.php.net/supported-versions.php) - 8.3, 8.2 default via Remi repo + custom PHP builds)
- DNS Server (Bind)
- Email services with antivirus/spam protection & webmail (POP/IMAP/SMTP, ClamAV, SpamAssassin, Sieve, Roundcube)
- MariaDB/MySQL & PostgreSQL databases
- Let's Encrypt SSL support
- Firewall with brute-force protection & IP management (iptables, fail2ban, ipset).

## Supported OS

- **MSVSphere:** 9
- **AlmaLinux:** 9
- **RockyLinux:** 9

**NOTES:**

- HestiaCP does not support 32-bit OS!
- HestiaCP combined with OpenVZ 7 or earlier may have DNS/firewall issues. For VPS, we strongly recommend KVM/LXC-based virtualization.

## Installing Hestia Control Panel

- **NOTE:** HestiaCP must be installed on a fresh OS for proper functionality.

While we strive to make installation and usage intuitive, basic Linux server setup knowledge is assumed.

### Step 1: Log in

Login as **root** or a superuser via SSH:

```bash
ssh root@your.server
```

### Step 2: Download

Get the latest installer script:

```bash
wget https://dev.brepo.ru/bayrepo/hestiacp/raw/branch/master/install/hst-install.sh
```

### Step 3: Execute

Run the script and follow on-screen instructions:

```bash
bash hst-install.sh
```

Upon completion, you'll receive a welcome email (if configured) and login details.

### Custom Installation

Use flags to select specific components. View options with:

```bash
bash hst-install.sh -h
```

## Updating Existing Installations

Automatic updates are enabled by default (managed via **Server Settings > Updates**). Manual updates:

```bash
dnf update
```

## Issues & Support

- For RPM edition issues: [Create GitHub Issue](https://github.com/bayrepo/hestiacp-rpm/issues)
- Original Debian/Ubuntu version: [Original Repository](https://github.com/hestiacp/hestiacp)

## Copyright

Original copyrights belong to [HestiaCP](https://github.com/hestiacp/hestiacp)

## License

Hestia Control Panel is licensed under [GPL v3](https://github.com/hestiacp/hestiacp/blob/release/LICENSE) and based on [VestaCP](https://vestacp.com/).
