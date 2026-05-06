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

apt-get install -y --no-install-recommends gh
install -m 0755 /tmp/overlay/provisioning.sh /root/provisioning.sh
