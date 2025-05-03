<div align="center">

# [Panel de Control Hestia (Edición RPM)](https://hestiadocs.brepo.ru)

![Captura de la interfaz web de HestiaCP](./docs/public/images/demo.png)

## Panel de servidor ligero y potente para entornos modernos de alojamiento web

**Versión estable:** 1.9.5 (RPM) |
[Edición RPM](https://hestiadocs.brepo.ru) |
[Proyecto original para Ubuntu/Debian](https://hestiacp.com) |
[Registro de cambios](/CHANGELOG.md) |
[Foro de soporte](https://forum.hestiacp.com)
<br><br>
[![Estado de compilación Drone](https://drone.hestiacp.com/api/badges/hestiacp/hestiacp/status.svg?ref=refs/heads/main)](https://drone.hestiacp.com/hestiacp/hestiacp)
[![Estado de verificación](https://github.com/hestiacp/hestiacp/actions/workflows/lint.yml/badge.svg)](https://github.com/hestiacp/hestiacp/actions/workflows/lint.yml)
[![Soporte técnico](https://img.shields.io/badge/Gurubase-Preguntas_en_inglés-006BFF)](https://gurubase.io/g/hestia)

</div>

El Panel de Control Hestia (Edición RPM) es mantenido por un equipo independiente especializado en sistemas basados en RPM. Debido a cambios implementados tras la bifurcación del proyecto original, esta versión no puede sincronizarse directamente con las actualizaciones de Ubuntu/Debian. Reporte los problemas directamente a este proyecto.

## **¡Bienvenido!**

Hestia ofrece una interfaz web intuitiva y CLI para implementar y gestionar dominios web, cuentas de correo, zonas DNS y bases de datos de forma centralizada, sin configuración manual de componentes individuales.

## Características y servicios

- Apache2 & NGINX con PHP-FPM
- Múltiples versiones de PHP (7.4[EOL](https://www.php.net/supported-versions.php) - 8.3, predeterminado 8.2 desde repositorio Remi + compilaciones personalizadas)
- Servidor DNS (Bind)
- Servicios de correo con protección antivirus/anti-spam (ClamAV, SpamAssassin, Roundcube)
- Bases de datos MariaDB/MySQL & PostgreSQL
- Soporte Let's Encrypt SSL
- Cortafuegos con protección contra fuerza bruta (iptables, fail2ban, ipset)

## Sistemas compatibles

- **MSVSphere:** 9
- **AlmaLinux:** 9
- **RockyLinux:** 9

**Notas importantes:**

- ¡No compatible con sistemas de 32 bits!
- Pueden ocurrir problemas de DNS/cortafuegos en OpenVZ 7 o anteriores. Recomendamos virtualización basada en KVM/LXC.

## Instalación

**Requisito:** ¡Sistema operativo recién instalado!

### Paso 1: Iniciar sesión

Conéctese como **root** vía SSH:

```bash
ssh root@su-servidor
```

### Paso 2: Descargar script

Obtenga el instalador más reciente:

```bash
wget https://dev.brepo.ru/bayrepo/hestiacp/raw/branch/master/install/hst-install.sh
```

### Paso 3: Ejecutar

Ejecute el script con permisos:

```bash
bash hst-install.sh
```

### Instalación personalizada

Ver opciones disponibles:

```bash
bash hst-install.sh -h
```

## Actualizaciones

Las actualizaciones automáticas están activadas por defecto (**Configuración del servidor > Actualizaciones**). Actualización manual:

```bash
dnf update
```

## Soporte técnico

- Problemas con la edición RPM: [Reportar en GitHub](https://github.com/bayrepo/hestiacp-rpm/issues)
- Versión original: [Repositorio principal](https://github.com/hestiacp/hestiacp)

## Licencia

Hestia Control Panel se distribuye bajo licencia [GPL v3](https://github.com/hestiacp/hestiacp/blob/release/LICENSE) y está basado en [VestaCP](https://vestacp.com/).
