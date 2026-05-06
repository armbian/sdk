#!/usr/bin/env bash
#
# Generic post-firstlogin hook. Armbian's first-boot mechanism runs
# /root/provisioning.sh once after firstboot.conf has applied its
# PRESET_* settings (network, locale, root password, the `armbian`
# user, …) and the initial login completes. Runs as root.
#
# customize-image.sh has already cloned every relevant armbian-org repo
# straight into code-server's workspace at /armbian/code-server/config/
# workspace/ at build time. Single source of truth — this hook just
# hands ownership to the armbian user and surfaces a convenience
# symlink in the user's home.
#
set -euo pipefail

USER_NAME="armbian"
USER_HOME="/home/${USER_NAME}"

# Docker daemon is up now (it wasn't in the build chroot), so the
# code-server container install can run normally.
armbian-config --api module_code-server install

# Wait for the code-server binary to be reachable inside the container,
# then provision the Python extension and the Claude Code CLI so the
# IDE is usable out of the box. The first `claude` run inside the
# code-server integrated terminal offers to install the matching VS
# Code extension automatically.
while ! docker exec code-server which code-server >/dev/null 2>&1; do
    sleep 2
done
docker exec -u abc code-server code-server --install-extension ms-python.python
docker exec code-server bash -lc "npm install -g @anthropic-ai/claude-code"

chown -R "${USER_NAME}:${USER_NAME}" /armbian/code-server/config
ln -s /armbian/code-server/config/workspace "${USER_HOME}/workspace"

date -u -Iseconds > /provisioned
