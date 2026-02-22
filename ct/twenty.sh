#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2026 community-scripts ORG
# Author: MickLesk (CanbiZ)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://twenty.com/

APP="Twenty"
var_tags="${var_tags:-crm;docker}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-4096}"
var_disk="${var_disk:-20}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-0}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -d /opt/twenty ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  if check_for_gh_release "twenty" "twentyhq/twenty"; then
    RELEASE=$(get_latest_github_release "twentyhq/twenty")

    msg_info "Stopping Twenty"
    cd /opt/twenty || exit
    $STD docker compose down
    msg_ok "Stopped Twenty"

    msg_info "Updating Twenty to ${RELEASE}"
    $STD docker compose pull
    $STD docker compose up -d
    echo "${RELEASE}" >~/.twenty
    msg_ok "Updated Twenty to ${RELEASE}"
    msg_ok "Updated successfully!"
  fi
  exit
}

start
build_container
description

msg_ok "Completed successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:3000${CL}"
