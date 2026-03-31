#!/usr/bin/env bash
# =============================================================================
#  WordPress Stack Reset
#  Entfernt: WordPress, Nginx, PHP-FPM, MariaDB, Redis, Fail2ban, WP-CLI,
#             phpMyAdmin, FileBrowser, SSL, Cron-Jobs, Swap
# =============================================================================
# Usage:
#   sudo bash reset-wordpress.sh
#
# Läuft ohne Rückfragen durch und entfernt alles was install-wordpress.sh
# installiert und konfiguriert hat.
# =============================================================================

set -uo pipefail
IFS=$'\n\t'

# ─── Colour helpers ───────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
section() { echo -e "\n${BOLD}${CYAN}══════════════════════════════════════════${RESET}"; \
            echo -e "${BOLD}${CYAN}  $*${RESET}"; \
            echo -e "${BOLD}${CYAN}══════════════════════════════════════════${RESET}"; }

# ─── Root check ───────────────────────────────────────────────────────────────
[[ $EUID -ne 0 ]] && { echo "Bitte als root ausführen: sudo bash $0"; exit 1; }

# ─── WordPress-Pfad & Domain ermitteln ────────────────────────────────────────
WP_PATH=""
for candidate in /var/www/wordpress /var/www/html /var/www/*/; do
  [[ -f "${candidate}/wp-config.php" ]] && WP_PATH="$candidate" && break
done

WP_DOMAIN=""
if [[ -n "$WP_PATH" ]]; then
  WP_DOMAIN=$(grep -iE "WP_HOME|siteurl" "${WP_PATH}/wp-config.php" 2>/dev/null \
    | head -1 | sed "s/.*['\"]https\?:\/\/\([^'\"]*\)['\"].*/\1/" || true)
  [[ -z "$WP_DOMAIN" ]] && WP_DOMAIN=$(basename "$WP_PATH")
fi

# ─── PHP-Version ermitteln ────────────────────────────────────────────────────
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;" 2>/dev/null || true)
if [[ -z "$PHP_VERSION" ]]; then
  PHP_VERSION=$(find /etc/php -maxdepth 1 -mindepth 1 -type d 2>/dev/null \
    | sort -V | tail -1 | xargs basename || echo "")
fi

# ─── DB-Credentials aus wp-config.php ─────────────────────────────────────────
DB_NAME=""
DB_USER=""
if [[ -n "$WP_PATH" && -f "${WP_PATH}/wp-config.php" ]]; then
  DB_NAME=$(grep "DB_NAME" "${WP_PATH}/wp-config.php" \
    | grep -oP "(?<=')[^']+(?=')" | head -1 || true)
  DB_USER=$(grep "DB_USER" "${WP_PATH}/wp-config.php" \
    | grep -oP "(?<=')[^']+(?=')" | head -1 || true)
fi

section "WordPress Stack Reset"
echo -e "  WordPress-Pfad : ${CYAN}${WP_PATH:-nicht gefunden}${RESET}"
echo -e "  Domain         : ${CYAN}${WP_DOMAIN:-unbekannt}${RESET}"
echo -e "  PHP-Version    : ${CYAN}${PHP_VERSION:-unbekannt}${RESET}"
echo -e "  Datenbank      : ${CYAN}${DB_NAME:-unbekannt}${RESET}"
echo ""

# ─── 1. Services stoppen ──────────────────────────────────────────────────────
section "Services stoppen"
for svc in filebrowser nginx "php${PHP_VERSION}-fpm" redis-server fail2ban; do
  if systemctl is-active --quiet "$svc" 2>/dev/null; then
    systemctl stop "$svc" 2>/dev/null && info "$svc gestoppt." || true
  fi
  systemctl disable "$svc" 2>/dev/null || true
done
success "Services gestoppt."

# ─── 2. WordPress-Dateien ─────────────────────────────────────────────────────
section "WordPress entfernen"
if [[ -n "$WP_PATH" && -d "$WP_PATH" ]]; then
  rm -rf "$WP_PATH"
  success "WordPress-Verzeichnis entfernt: ${WP_PATH}"
else
  warn "Kein WordPress-Verzeichnis gefunden."
fi

# ─── 3. phpMyAdmin ────────────────────────────────────────────────────────────
if [[ -d "/var/www/phpmyadmin" ]]; then
  section "phpMyAdmin entfernen"
  rm -rf /var/www/phpmyadmin /var/lib/phpmyadmin
  rm -f /etc/nginx/.phpmyadmin_htpasswd
  success "phpMyAdmin entfernt."
fi

# ─── 4. FileBrowser ───────────────────────────────────────────────────────────
if [[ -f "/usr/local/bin/filebrowser" || -d "/var/lib/filebrowser" ]]; then
  section "FileBrowser entfernen"
  systemctl stop filebrowser 2>/dev/null || true
  systemctl disable filebrowser 2>/dev/null || true
  rm -f /usr/local/bin/filebrowser
  rm -rf /var/lib/filebrowser
  rm -f /etc/systemd/system/filebrowser.service
  systemctl daemon-reload
  success "FileBrowser entfernt."
fi

# ─── 5. Datenbank & User ──────────────────────────────────────────────────────
section "Datenbank entfernen"
if systemctl is-active --quiet mariadb 2>/dev/null; then
  [[ -n "$DB_NAME" ]] && \
    mysql -e "DROP DATABASE IF EXISTS \`${DB_NAME}\`;" 2>/dev/null && \
    success "Datenbank '${DB_NAME}' gelöscht." || true

  [[ -n "$DB_USER" && "$DB_USER" != "root" ]] && \
    mysql -e "DROP USER IF EXISTS '${DB_USER}'@'localhost';" 2>/dev/null && \
    success "DB-User '${DB_USER}' gelöscht." || true

  mysql -e "DROP USER IF EXISTS 'phpmyadmin'@'localhost';" 2>/dev/null || true
  mysql -e "FLUSH PRIVILEGES;" 2>/dev/null || true
else
  warn "MariaDB läuft nicht — Datenbank wird beim Deinstallieren entfernt."
fi

# ─── 6. Nginx-Konfiguration ───────────────────────────────────────────────────
section "Nginx-Konfiguration entfernen"
if [[ -n "$WP_DOMAIN" ]]; then
  rm -f "/etc/nginx/sites-enabled/${WP_DOMAIN}" \
        "/etc/nginx/sites-available/${WP_DOMAIN}" \
        "/etc/nginx/sites-enabled/phpmyadmin.${WP_DOMAIN}" \
        "/etc/nginx/sites-available/phpmyadmin.${WP_DOMAIN}" \
        "/etc/nginx/sites-enabled/files.${WP_DOMAIN}" \
        "/etc/nginx/sites-available/files.${WP_DOMAIN}"
fi
rm -f /etc/nginx/conf.d/fastcgi-cache.conf \
      /etc/nginx/conf.d/real-ip.conf \
      /etc/nginx/conf.d/rate-limiting.conf
rm -rf /var/cache/nginx/fastcgi
success "Nginx-Konfiguration entfernt."

# ─── 7. PHP-FPM-Konfiguration ─────────────────────────────────────────────────
if [[ -n "$PHP_VERSION" ]]; then
  section "PHP-FPM-Konfiguration entfernen"
  rm -f "/etc/php/${PHP_VERSION}/fpm/pool.d/wordpress.conf" \
        "/etc/php/${PHP_VERSION}/fpm/conf.d/99-opcache-wordpress.ini"
  # www.conf wiederherstellen falls gesichert
  [[ ! -f "/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf" ]] && \
    cp "/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf.dpkg-dist" \
       "/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf" 2>/dev/null || true
  success "PHP-FPM-Konfiguration entfernt."
fi

# ─── 8. Fail2ban ──────────────────────────────────────────────────────────────
section "Fail2ban-Konfiguration entfernen"
rm -f /etc/fail2ban/jail.local \
      /etc/fail2ban/filter.d/wordpress-auth.conf
success "Fail2ban-Konfiguration entfernt."

# ─── 9. Cron-Jobs ─────────────────────────────────────────────────────────────
section "Cron-Jobs entfernen"
rm -f /etc/cron.d/wordpress-cron \
      /etc/cron.daily/wp-db-backup
success "Cron-Jobs entfernt."

# ─── 10. Log-Rotation ─────────────────────────────────────────────────────────
rm -f /etc/logrotate.d/wordpress-stack

# ─── 11. SSL-Zertifikat ───────────────────────────────────────────────────────
section "SSL-Zertifikat entfernen"
if command -v certbot &>/dev/null && [[ -n "$WP_DOMAIN" ]]; then
  certbot delete --cert-name "$WP_DOMAIN" --non-interactive 2>/dev/null && \
    success "SSL-Zertifikat für ${WP_DOMAIN} entfernt." || \
    warn "Kein SSL-Zertifikat gefunden oder bereits entfernt."
else
  warn "Certbot nicht installiert — überspringe."
fi

# ─── 12. WP-CLI ───────────────────────────────────────────────────────────────
section "WP-CLI entfernen"
rm -f /usr/local/bin/wp
success "WP-CLI entfernt."

# ─── 13. Credentials & Backups ────────────────────────────────────────────────
section "Credentials und Backups entfernen"
rm -f /root/.wp_install_credentials_*.txt
rm -rf /root/backups/mysql
success "Credentials und Backups entfernt."

# ─── 14. Pakete deinstallieren ────────────────────────────────────────────────
section "Pakete deinstallieren"
export DEBIAN_FRONTEND=noninteractive
echo "mariadb-server mariadb-server/postrm_remove_databases boolean true" \
  | debconf-set-selections 2>/dev/null || true

PHP_PKGS=()
if [[ -n "$PHP_VERSION" ]]; then
  for pkg in fpm mysql redis xml mbstring curl zip gd intl bcmath imagick; do
    PHP_PKGS+=("php${PHP_VERSION}-${pkg}")
  done
  PHP_PKGS+=("php${PHP_VERSION}")
fi

apt-get purge -y -qq \
  nginx nginx-common \
  libnginx-mod-http-cache-purge \
  libnginx-mod-http-brotli-filter \
  libnginx-mod-http-brotli-static \
  "${PHP_PKGS[@]}" \
  mariadb-server mariadb-client mariadb-common \
  redis-server redis-tools \
  fail2ban \
  certbot python3-certbot-nginx \
  cron 2>/dev/null || true

apt-get autoremove -y -qq 2>/dev/null || true
apt-get autoclean -qq 2>/dev/null || true
success "Pakete deinstalliert."

# ─── 15. Swap-Datei ───────────────────────────────────────────────────────────
section "Swap entfernen"
if [[ -f /swapfile ]]; then
  swapoff /swapfile 2>/dev/null || true
  sed -i '/\/swapfile/d' /etc/fstab
  sed -i '/vm.swappiness/d' /etc/sysctl.conf
  rm -f /swapfile
  success "Swap-Datei entfernt."
else
  info "Keine Swap-Datei gefunden — überspringe."
fi

# ─── Abschluss ────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}${GREEN}════════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}${GREEN}  Reset abgeschlossen — $(date '+%Y-%m-%d %H:%M')${RESET}"
echo -e "${BOLD}${GREEN}════════════════════════════════════════════════════════${RESET}"
echo ""
warn "Empfehlung: Server neu starten mit 'reboot'"
echo ""
