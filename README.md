# jinzhi

用于 VPS 服务器的 `/etc/hosts` 审计与域名屏蔽。

通过将指定域名解析到 `127.0.0.1`，阻止服务器访问名单中的网站和服务。

## 快速使用

直接执行：

```bash
curl -fsSL https://raw.githubusercontent.com/krililrify/jinzhi/main/audit-hosts.sh | bash
```

## 功能

* 自动修改 `/etc/hosts`
* 屏蔽指定域名
* 自动备份原 `/etc/hosts`
* 支持重复执行
* 不需要在服务器保存脚本
* GitHub 更新脚本后，重新执行命令即可使用最新版

## 备份

脚本会自动备份原始 `/etc/hosts`：

```text
/etc/hosts.backup/
```

## 注意

本项目主要供个人服务器使用。

请确认服务器确实需要屏蔽相关域名后再执行。
