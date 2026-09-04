#!/bin/bash

# ============================================================
# JINZHI Hosts Audit
# GitHub: https://github.com/krililrify/jinzhi
#
# 功能：
#   1. 检查 root 权限
#   2. 检查 /etc/hosts
#   3. 自动备份 /etc/hosts
#   4. 删除旧的 JINZHI 审计区块
#   5. 写入最新黑名单
#   6. 自动检测 hostname
#   7. 保留系统原有 IPv6 配置
#
# 重复执行安全，不会无限追加重复内容。
# ============================================================

set -e

START_MARKER="# ===== JINZHI AUDIT BLACKLIST START ====="
END_MARKER="# ===== JINZHI AUDIT BLACKLIST END ====="

HOSTS_FILE="/etc/hosts"
BACKUP_DIR="/etc/hosts.backup"

# ------------------------------------------------------------
# 颜色
# ------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ------------------------------------------------------------
# Root 检查
# ------------------------------------------------------------

if [ "$(id -u)" != "0" ]; then
    error "请使用 root 用户执行此脚本。"
    echo
    echo "例如："
    echo "sudo bash $0"
    exit 1
fi

# ------------------------------------------------------------
# 系统检查
# ------------------------------------------------------------

if [ ! -f /etc/os-release ]; then
    error "无法检测系统版本。"
    exit 1
fi

. /etc/os-release

echo
echo "========================================"
echo "        JINZHI Hosts Audit"
echo "========================================"
echo

info "系统：${PRETTY_NAME}"
info "主机名：$(hostname)"
info "Hosts：${HOSTS_FILE}"

# ------------------------------------------------------------
# 检查 hosts 文件
# ------------------------------------------------------------

if [ ! -f "$HOSTS_FILE" ]; then
    error "${HOSTS_FILE} 不存在。"
    exit 1
fi

# ------------------------------------------------------------
# 创建备份
# ------------------------------------------------------------

mkdir -p "$BACKUP_DIR"

BACKUP_FILE="${BACKUP_DIR}/hosts.$(date '+%Y%m%d_%H%M%S')"

cp -a "$HOSTS_FILE" "$BACKUP_FILE"

success "已备份：${BACKUP_FILE}"

# ------------------------------------------------------------
# 临时文件
# ------------------------------------------------------------

TMP_FILE="$(mktemp)"

cleanup() {
    rm -f "$TMP_FILE"
}

trap cleanup EXIT

# ------------------------------------------------------------
# 删除旧的 JINZHI 区块
# ------------------------------------------------------------

info "检查旧的 JINZHI 审计区块..."

awk -v start="$START_MARKER" -v end="$END_MARKER" '
    $0 == start {
        inside=1
        next
    }

    $0 == end {
        inside=0
        next
    }

    !inside {
        print
    }
' "$HOSTS_FILE" > "$TMP_FILE"

# ------------------------------------------------------------
# 获取 hostname
# ------------------------------------------------------------

HOSTNAME_VALUE="$(hostname)"

if [ -z "$HOSTNAME_VALUE" ]; then
    HOSTNAME_VALUE="localhost"
fi

# ------------------------------------------------------------
# 写入新的审计区块
# ------------------------------------------------------------

cat >> "$TMP_FILE" <<EOF

$START_MARKER

# ======================
# 国外常见网站
# ======================

127.0.0.1   ntdtv.com www.ntdtv.com
127.0.0.1   epochtimes.com www.epochtimes.com theepochtimes.com www.theepochtimes.com
127.0.0.1   soundofhope.org www.soundofhope.org
127.0.0.1   minghui.org www.minghui.org
127.0.0.1   newtmtv.com www.newtmtv.com
127.0.0.1   boxun.com www.boxun.com
127.0.0.1   watchmen.org www.watchmen.org
127.0.0.1   wenxuecity.com www.wenxuecity.com
127.0.0.1   dajiayun.com www.dajiayun.com
127.0.0.1   radiofreeasia.org www.radiofreeasia.org
127.0.0.1   voachinese.com www.voachinese.com
127.0.0.1   rfa.org www.rfa.org
127.0.0.1   voanews.com www.voanews.com
127.0.0.1   freedomhouse.org www.freedomhouse.org
127.0.0.1   tibet.net www.tibet.net
127.0.0.1   chinadigitaltimes.net www.chinadigitaltimes.net
127.0.0.1   chinastrategy.com www.chinastrategy.com
127.0.0.1   unpo.org www.unpo.org
127.0.0.1   chinahumanrights.org www.chinahumanrights.org
127.0.0.1   hongkongfp.com www.hongkongfp.com
127.0.0.1   thechinastory.org www.thechinastory.org
127.0.0.1   asiahumanrights.org www.asiahumanrights.org
127.0.0.1   transparency.org www.transparency.org
127.0.0.1   chinaaid.org www.chinaaid.org
127.0.0.1   chinasocialmedia.org www.chinasocialmedia.org
127.0.0.1   humanrightswatch.org www.humanrightswatch.org hrw.org
127.0.0.1   propublica.org www.propublica.org
127.0.0.1   indexoncensorship.org www.indexoncensorship.org
127.0.0.1   surveillance.com www.surveillance.com
127.0.0.1   freedomofspeech.org www.freedomofspeech.org
127.0.0.1   appledaily.com nextdigital.com.hk
127.0.0.1   nytimes.com bloomberg.com independent.co.uk
127.0.0.1   freetibet.org citizenpowerforchina.org
127.0.0.1   bbc.com bbc.co.uk
127.0.0.1   theinitium.com jw.org bannedbook.org dw.com
127.0.0.1   storm.mg yam.com ltn.com.tw mpweekly.com cup.com.hk thenewslens.com inside.com.tw everylittled.com cool3c.com
127.0.0.1   taketla.zaiko.io news.agentm.tw sportsv.net research.tnlmedia.com ad2iction.com viad.com.tw tnlmedia.com becomingaces.com
127.0.0.1   pincong.rocks flipboard.com aboluowang.com 2047.name shu.best
127.0.0.1   shenyunperformingarts.org shenyuncreations.com
127.0.0.1   wsj.com rfi.fr abc.net.au
127.0.0.1   chinapress.com.my hancel.org miraheze.org zhuichaguoji.org fawanghuihui.org hopto.org yibaochina.com roc-taiwan.org creaders.net upmedia.mg ydn.com.tw udn.com theaustralian.com.au voacantonese.com bitterwinter.org christianstudy.com learnfalungong.com usembassy-china.org.cn master-li.qi-gong.me zhengwunet.org modernchinastudies.org ninecommentaries.com dafahao.com tgcchinese.org botanwang.com

# ======================
# 欺诈 / 点卡类
# ======================

127.0.0.1   funmart.beanfun.com
127.0.0.1   gashpoint.com gash.com gash.tw
127.0.0.1   mycard.com mycard.tw

# ======================
# 国内不适合代理的域名
# 避免代理流量绕路
# ======================

127.0.0.1   10099.com.cn 10010.com 189.cn 10086.cn
127.0.0.1   1688.com jd.com taobao.com pinduoduo.com tmall.com vip.com
127.0.0.1   cctv.com cntv.cn tianya.cn tieba.baidu.com xuexi.cn rednet.cn
127.0.0.1   weibo.com zhihu.com douban.com toutiao.com zijieapi.com
127.0.0.1   xiaomi.cn oppo.cn oneplusbbs.com bbs.vivo.com.cn club.lenovo.com.cn bbs.iqoo.com realmebbs.com rogbbs.asus.com.cn bbs.myzte.cn club.huawei.com club.meizu.cn
127.0.0.1   xiaohongshu.com coolapk.com bbsuc.cn tangdou.com oneniceapp.com izuiyou.com pipigx.com ixiaochuan.cn duitang.com renren.com

# ======================
# 安全软件 / 相关服务
# ======================

127.0.0.1   360.cn 360.com safe.360.cn safe.360.com
127.0.0.1   tencent.com qq.com qz.com ts.tencent.com
127.0.0.1   kingsoft.com kd.com kdd.com
127.0.0.1   safebaidu.com baidutv.com baidusecurity.com
127.0.0.1   safe.sogou.com zg.sogou.com
127.0.0.1   rising.com rsguard.com www.rising.com.cn
127.0.0.1   mi.com xiaomi.com security.mi.com mii.com
127.0.0.1   360safe.com 360cloud.com
127.0.0.1   appchina.com yixin.com dueros.com iflytek.com
127.0.0.1   lenovo.com miui.com

# ======================
# BitTorrent DHT / Tracker
# ======================

127.0.0.1   router.bittorrent.com
127.0.0.1   dht.transmissionbt.com
127.0.0.1   tpb.tracker.prq.to
127.0.0.1   tracker.openbittorrent.com
127.0.0.1   tracker.opentrackr.org
127.0.0.1   tracker.publicbt.com
127.0.0.1   tracker.bt4g.com
127.0.0.1   tracker.thepiratebay.org
127.0.0.1   tracker.torrent.eu.org
127.0.0.1   tracker.fastdownload.xyz
127.0.0.1   torrent.ubuntu.com
127.0.0.1   torrents.linuxmint.com
127.0.0.1   bttracker.debian.org
127.0.0.1   tracker.coppersurfer.tk
127.0.0.1   tracker.leechers-paradise.org
127.0.0.1   tracker.internetwarriors.net
127.0.0.1   bittorrent.com
127.0.0.1   tracker.nyaa.si
127.0.0.1   announce.torrentsmd.com
127.0.0.1   open.tracker.ink
127.0.0.1   open.acgtracker.com
127.0.0.1   tracker.skyts.net

# ======================
# IPv6
# ======================

::1   ntdtv.com www.ntdtv.com
::1   epochtimes.com www.epochtimes.com theepochtimes.com www.theepochtimes.com
::1   soundofhope.org www.soundofhope.org
::1   minghui.org www.minghui.org
::1   rfa.org www.rfa.org
::1   voanews.com www.voanews.com
::1   freedomhouse.org www.freedomhouse.org

$END_MARKER
EOF

# ------------------------------------------------------------
# 写入
# ------------------------------------------------------------

cp "$TMP_FILE" "$HOSTS_FILE"

success "审计名单写入完成。"

# ------------------------------------------------------------
# 显示统计
# ------------------------------------------------------------

COUNT="$(awk '
    /127\.0\.0\.1/ {count++}
    END {print count+0}
' "$HOSTS_FILE")"

echo
info "当前 /etc/hosts 中 127.0.0.1 项数量：${COUNT}"

# ------------------------------------------------------------
# DNS 服务刷新
# ------------------------------------------------------------

echo
info "尝试刷新 DNS 缓存..."

if command -v resolvectl >/dev/null 2>&1; then
    resolvectl flush-caches 2>/dev/null || true
    success "已执行 resolvectl flush-caches"
fi

if systemctl is-active --quiet systemd-resolved 2>/dev/null; then
    systemctl restart systemd-resolved 2>/dev/null || true
    success "已刷新 systemd-resolved"
fi

# ------------------------------------------------------------
# 完成
# ------------------------------------------------------------

echo
echo "========================================"
echo "             执行完成"
echo "========================================"
echo
success "Hosts 审计名单已更新"
info "主机名：${HOSTNAME_VALUE}"
info "备份目录：${BACKUP_DIR}"
echo
echo "测试示例："
echo
echo "  getent hosts ntdtv.com"
echo
echo "正常情况下应该返回："
echo
echo "  127.0.0.1   ntdtv.com"
echo
echo "========================================"
