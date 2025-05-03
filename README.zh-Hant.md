<div align="center">

# [Hestia 控制面板 (RPM 版)](https://hestiadocs.brepo.ru)

![HestiaCP 網頁介面截圖](./docs/public/images/demo.png)

## 面向現代網絡託管環境的輕量級強大伺服器控制面板

**穩定版本:** 1.9.5 (RPM) |
[RPM 版](https://hestiadocs.brepo.ru) |
[原版 Ubuntu/Debian 專案](https://hestiacp.com) |
[更新日誌](/CHANGELOG.md) |
[支援論壇](https://forum.hestiacp.com)
<br>
[![Drone 建構狀態](https://drone.hestiacp.com/api/badges/hestiacp/hestiacp/status.svg?ref=refs/heads/main)](https://drone.hestiacp.com/hestiacp/hestiacp)
[![程式碼檢查狀態](https://github.com/hestiacp/hestiacp/actions/workflows/lint.yml/badge.svg)](https://github.com/hestiacp/hestiacp/actions/workflows/lint.yml)
[![技術問答](https://img.shields.io/badge/Gurubase-使用英文在Hestia論壇提問-006BFF)](https://gurubase.io/g/hestia)

</div>

Hestia 控制面板（RPM 版）由專注於 RPM 系統的獨立團隊維護開發。由於從原專案分叉後，此版本已包含與上游 Ubuntu/Debian 版本無法直接同步的變更（部分功能不適用於 RPM 系統），因此相關問題請直接報告至本專案。

以下是面板的通用描述。

## **歡迎使用！**

Hestia 控制面板旨在透過集中式面板為管理員提供易用的網頁介面和命令列工具，快速部署和管理網站域名、郵箱帳戶、DNS 區域和資料庫，無需手動配置獨立元件。

## 功能與服務

- Apache2 和 NGINX 搭配 PHP-FPM
- 多版本 PHP 支援（7.4[EOL](https://www.php.net/supported-versions.php) - 8.3，預設 8.2 來自 Remi 倉庫 + 自訂 PHP 構建）
- DNS 伺服器（Bind）
- 帶病毒/垃圾郵件防護的郵件服務及網頁郵箱（POP/IMAP/SMTP，ClamAV，SpamAssassin，Sieve，Roundcube）
- MariaDB/MySQL 和 PostgreSQL 資料庫
- Let's Encrypt SSL 支援
- 防火牆含暴力破解防護和 IP 管理（iptables，fail2ban，ipset）

## 支援系統

- **MSVSphere:** 9
- **AlmaLinux:** 9
- **RockyLinux:** 9

**注意事項:**

- HestiaCP 不支援 32 位元作業系統！
- 在 OpenVZ 7 或更早版本上使用 HestiaCP 可能出現 DNS/防火牆問題。建議選擇基於 KVM/LXC 的虛擬化方案。

## 安裝 Hestia 控制面板

- **注意:** 為保證功能完整性，請在新裝系統上進行安裝。

儘管我們力求安裝過程簡單直觀，但使用者需具備基礎的 Linux 伺服器配置知識。

### 步驟 1：登入

使用 **root** 或超級使用者權限透過 SSH 登入：

```bash
ssh root@your.server
```

### 步驟 2：下載

取得最新安裝腳本：

```bash
wget https://dev.brepo.ru/bayrepo/hestiacp/raw/branch/master/install/hst-install.sh
```

### 步驟 3：執行

執行腳本並遵循螢幕指引：

```bash
bash hst-install.sh
```

安裝完成後，您將收到歡迎郵件（如配置）和登入資訊。

### 自訂安裝

使用參數選擇元件，檢視選項：

```bash
bash hst-install.sh -h
```

## 更新現有安裝

預設啟用自動更新（透過 **伺服器設定 > 更新** 管理）。手動更新：

```bash
dnf update
```

## 問題與支援

- RPM 版本問題回饋：[提交 GitHub Issue](https://github.com/bayrepo/hestiacp-rpm/issues)
- 原版 Debian/Ubuntu 版本：[原專案倉庫](https://github.com/hestiacp/hestiacp)

## 版權聲明

原始版權歸屬 [HestiaCP](https://github.com/hestiacp/hestiacp)

## 授權協議

Hestia 控制面板遵循 [GPL v3](https://github.com/hestiacp/hestiacp/blob/release/LICENSE) 協議，基於 [VestaCP](https://vestacp.com/) 開發。
