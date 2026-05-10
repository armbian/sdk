#!/usr/bin/env bash
#
# Armbian build hook — runs inside the rootfs chroot at image build time,
# after packages are installed and before the image is packaged.
# Use this file to pre-install packages, drop configs into place, stage
# first-boot scripts at /root/provisioning.sh, etc.
#
# `userpatches/overlay/` is bind-mounted read-only at `/tmp/overlay/`
# inside the chroot.
#
set -euo pipefail

apt-get update
# armbian-zsh isn't installable directly at customize-image time —
# the Armbian apt repo isn't yet wired up in the chroot, so apt
# returns 'unable to locate package'. Install armbian-config instead
# and then dispatch via its --api flag below; module_zsh handles the
# repo plumbing and pulls armbian-zsh / zsh-common / zsh in one shot.
apt-get install -y --no-install-recommends git tig nodejs npm armbian-config
install -m 0755 /tmp/overlay/provisioning.sh /root/provisioning.sh

# Install zsh via armbian-config's module_zsh. Pulls the armbian-zsh /
# zsh-common / zsh package set, refreshes /etc/skel from the matching
# dotfiles, and flips root's login shell to /bin/zsh — the full
# Armbian-flavoured setup. Same `armbian-config --api module_<name>
# <verb>` invocation pattern provisioning.sh uses for module_code-server.
armbian-config --api module_zsh install

# Pre-install the Claude Code CLI host-side so `claude` is on the
# armbian user's PATH from a plain SSH session too. (provisioning.sh
# also installs it inside the code-server container so it shows up in
# the IDE's integrated terminal — that's a separate npm install.)
npm install -g @anthropic-ai/claude-code

# Clone a small set of armbian-org repos directly into code-server's
# workspace so they appear at /config/workspace/<repo> in the IDE. The
# heavier repos (firmware, armbian.github.io, sdk, docker-armbian-build)
# are left for the user to clone on demand to keep the image under
# GitHub's 2 GiB per-asset release cap. code-server itself is installed
# at first boot (provisioning.sh) since the Docker daemon does not run
# inside the build chroot.
REPOS=(
    build
    configng
    documentation
    website
    imager
)
WORKSPACE=/armbian/code-server/config/workspace
mkdir -p "$WORKSPACE"
for repo in "${REPOS[@]}"; do
    git clone "https://github.com/armbian/${repo}.git" "${WORKSPACE}/${repo}"
done

# Install build host deps now (apt installs land in the chroot's rootfs).
( cd "${WORKSPACE}/build" && ./compile.sh requirements )
apt-get clean
