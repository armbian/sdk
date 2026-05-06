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
apt-get install -y --no-install-recommends git
install -m 0755 /tmp/overlay/provisioning.sh /root/provisioning.sh

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
