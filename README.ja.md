<div align="center">

# [Hestia コントロールパネル (RPM版)](https://hestiadocs.brepo.ru)

![HestiaCP Webインターフェーススクリーンショット](./docs/public/images/demo.png)

## 現代的なWebホスティング環境向け軽量で強力なサーバー管理パネル

**安定版:** 1.9.5 (RPM) |
[RPM版](https://hestiadocs.brepo.ru) |
[オリジナルUbuntu/Debian版](https://hestiacp.com) |
[更新履歴](/CHANGELOG.md) |
[サポートフォーラム](https://forum.hestiacp.com)
<br><br>
[![Droneビルドステータス](https://drone.hestiacp.com/api/badges/hestiacp/hestiacp/status.svg?ref=refs/heads/main)](https://drone.hestiacp.com/hestiacp/hestiacp)
[![Lintステータス](https://github.com/hestiacp/hestiacp/actions/workflows/lint.yml/badge.svg)](https://github.com/hestiacp/hestiacp/actions/workflows/lint.yml)
[![技術Q&A](https://img.shields.io/badge/Gurubase-英語を使ってHestia開発者と議論する-006BFF)](https://gurubase.io/g/hestia)

</div>

Hestia コントロールパネル（RPM版）はRPMベースOS専用の開発チームによってメンテナンスされています。Ubuntu/Debian版との機能同期ができないため、問題報告は本プロジェクト宛てにお願いします。

## **ようこそ！**

Hestiaは直感的なWebインターフェースとCLIを提供し、ドメイン管理・メールアカウント・DNSゾーン・データベースの迅速なデプロイを可能にするサーバー管理パネルです。

## 主な機能

- Apache2 & NGINX + PHP-FPM連携
- マルチPHPバージョン（7.4[EOL](https://www.php.net/supported-versions.php) - 8.3、Remiリポジトリ版+カスタムビルド）
- Bind DNSサーバー
- ウイルス/スパム対策付きメールサービス（ClamAV, SpamAssassin, Roundcube）
- MariaDB/MySQL & PostgreSQLデータベース
- Let's Encrypt SSL対応
- ブルートフォース攻撃防御機能（iptables, fail2ban, ipset）

## 対応OS

- **MSVSphere:** 9
- **AlmaLinux:** 9
- **RockyLinux:** 9

**注意事項:**

- 32ビットOS非対応
- OpenVZ 7以前の環境ではDNS/ファイアウォール問題が発生する可能性あり

## インストール手順

### ステップ1: rootログイン

SSHでrootユーザーとしてログイン:

```bash
ssh root@your.server
```

### ステップ2: インストーラ取得

最新インストーラをダウンロード:

```bash
wget https://dev.brepo.ru/bayrepo/hestiacp/raw/branch/master/install/hst-install.sh
```

### ステップ3: 実行

スクリプトを実行し指示に従う:

```bash
bash hst-install.sh
```

### カスタムインストール

オプション確認:

```bash
bash hst-install.sh -h
```

## アップデート

自動更新はデフォルトで有効（**サーバー設定 > 更新**から管理）。手動更新:

```bash
dnf update
```

## サポート

- RPM版問題報告: [GitHub Issues](https://github.com/bayrepo/hestiacp-rpm/issues)
- オリジナル版: [公式リポジトリ](https://github.com/hestiacp/hestiacp)

## ライセンス

Hestiaコントロールパネルは[GPL v3](https://github.com/hestiacp/hestiacp/blob/release/LICENSE)ライセンスで、[VestaCP](https://vestacp.com/)を基に開発されています。
