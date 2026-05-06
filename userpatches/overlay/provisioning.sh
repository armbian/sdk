#!/usr/bin/env bash
#
# Generic post-firstlogin hook. Armbian's first-boot mechanism runs
# /root/provisioning.sh once after firstboot.conf has applied its
# PRESET_* settings (network, locale, root password, …) and the
# initial login completes. Drop any custom setup work here.
# Current body is a stub that just leaves a marker file behind.
#
set -euo pipefail
date -u -Iseconds > /provisioned
