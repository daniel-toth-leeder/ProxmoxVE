#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: MickLesk (CanbiZ)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://twenty.com/

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
APPLICATION="${APPLICATION:-Twenty}"
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt install -y \
  curl \
  openssl
msg_ok "Installed Dependencies"

setup_docker

msg_info "Setting up Twenty"
RELEASE=$(get_latest_github_release "twentyhq/twenty")
mkdir -p /opt/twenty

curl -fsSL "https://raw.githubusercontent.com/twentyhq/twenty/main/packages/twenty-docker/.env.example" -o /opt/twenty/.env
curl -fsSL "https://raw.githubusercontent.com/twentyhq/twenty/main/packages/twenty-docker/docker-compose.yml" -o /opt/twenty/docker-compose.yml

APP_SECRET=$(openssl rand -hex 32)
PG_PASSWORD=$(openssl rand -hex 16)
get_lxc_ip

# Note: TAG is intentionally left as 'latest' (the upstream default).
# Twenty's Docker Hub tags (e.g. v1.18.1) do not always align with
# GitHub release tags (e.g. v1.18.0), so pinning by GitHub release
# version causes image-not-found errors. RELEASE is saved for update
# detection only.
sed -i \
  -e "s|^#\?APP_SECRET=.*|APP_SECRET=${APP_SECRET}|" \
  -e "s|^#\?PG_DATABASE_PASSWORD=.*|PG_DATABASE_PASSWORD=${PG_PASSWORD}|" \
  -e "s|^SERVER_URL=.*|SERVER_URL=http://${LOCAL_IP}:3000|" \
  -e "s|^#\?STORAGE_TYPE=.*|STORAGE_TYPE=local|" \
  /opt/twenty/.env

echo "${RELEASE}" >~/.twenty
msg_ok "Set up Twenty"

msg_info "Starting Twenty (Patience - pulling Docker images)"
cd /opt/twenty || exit
$STD docker compose up -d
msg_ok "Started Twenty"

motd_ssh
customize
cleanup_lxc
