<div align="center">

# [Hestia Control Panel (RPM-Edition)](https://hestiadocs.brepo.ru)

![HestiaCP Web-Oberfläche](./docs/public/images/demo.png)

## Leistungsstarkes und schlankes Serververwaltungspanel für moderne Hosting-Umgebungen

**Stabile Version:** 1.9.5 (RPM) |
[RPM-Edition](https://hestiadocs.brepo.ru) |
[Originalprojekt für Ubuntu/Debian](https://hestiacp.com) |
[Änderungsprotokoll](/CHANGELOG.md) |
[Support-Forum](https://forum.hestiacp.com)
<br><br>
[![Drone Build-Status](https://drone.hestiacp.com/api/badges/hestiacp/hestiacp/status.svg?ref=refs/heads/main)](https://drone.hestiacp.com/hestiacp/hestiacp)
[![Lint-Status](https://github.com/hestiacp/hestiacp/actions/workflows/lint.yml/badge.svg)](https://github.com/hestiacp/hestiacp/actions/workflows/lint.yml)
[![Technischer Support](https://img.shields.io/badge/Gurubase-Fragen%20auf%20Englisch-006BFF)](https://gurubase.io/g/hestia)

</div>

Die Hestia Control Panel (RPM-Edition) wird von einem unabhängigen Team für RPM-basierte Betriebssysteme entwickelt. Durch Anpassungen nach dem Fork des Originalprojekts ist eine direkte Synchronisation mit der Ubuntu/Debian-Version nicht möglich. Bitte melden Sie Probleme direkt an dieses Projekt.

## **Willkommen!**

Hestia bietet Administratoren eine intuitive Weboberfläche und CLI zur zentralisierten Verwaltung von Webdomains, E-Mail-Konten, DNS-Zonen und Datenbanken – ohne manuelle Konfiguration einzelner Komponenten.

## Funktionen & Dienste

- Apache2 & NGINX mit PHP-FPM
- Mehrere PHP-Versionen (7.4[EOL](https://www.php.net/supported-versions.php)–8.3, Standard 8.2 aus Remi-Repo + Custom Builds)
- DNS-Server (Bind)
- E-Mail-Services mit Viren-/Spam-Schutz (ClamAV, SpamAssassin, Roundcube)
- MariaDB/MySQL & PostgreSQL Datenbanken
- Let's Encrypt SSL-Unterstützung
- Firewall mit Brute-Force-Schutz (iptables, fail2ban, ipset)

## Unterstützte Betriebssysteme

- **MSVSphere:** 9
- **AlmaLinux:** 9
- **RockyLinux:** 9

**Hinweise:**

- Keine Unterstützung für 32-Bit-Systeme!
- Bei OpenVZ 7 oder älter können DNS/Firewall-Probleme auftreten – wir empfehlen KVM/LXC-basierte Virtualisierung.

## Installation

**Wichtig:** Frische OS-Installation erforderlich!

### Schritt 1: Anmeldung

Als **root** per SSH anmelden:

```bash
ssh root@Ihr-Server
```

### Schritt 2: Installationsskript herunterladen

```bash
wget https://dev.brepo.ru/bayrepo/hestiacp/raw/branch/master/install/hst-install.sh
```

### Schritt 3: Ausführung

Skript mit Berechtigungen ausführen:

```bash
bash hst-install.sh
```

### Custom Installation

Optionen anzeigen:

```bash
bash hst-install.sh -h
```

## Updates

Automatische Updates sind standardmäßig aktiviert (**Server-Einstellungen > Updates**). Manuelles Update:

```bash
dnf update
```

## Support

- Probleme mit RPM-Edition: [GitHub Issues](https://github.com/bayrepo/hestiacp-rpm/issues)
- Originalversion: [Hauptrepository](https://github.com/hestiacp/hestiacp)

## Lizenz

Hestia Control Panel ist unter der [GPL v3](https://github.com/hestiacp/hestiacp/blob/release/LICENSE)-Lizenz lizenziert und basiert auf [VestaCP](https://vestacp.com/).
