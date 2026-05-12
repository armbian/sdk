<h3 align="center">
  <a href=#><img src="https://raw.githubusercontent.com/armbian/.github/master/profile/logosmall.png" alt="Armbian logo"></a>
  <br><br>
</h3>

## Purpose of This Repository

The **Armbian SDK** publishes ready-to-deploy generic **Armbian** images preloaded with the toolchain, source repositories, and dependencies needed to develop on the Armbian platform — drop one onto a cloud provider, **Proxmox**, or any **QEMU/KVM**-capable hypervisor and start building immediately.

Daily builds from this repository's [GitHub Action](.github/workflows/build-armbian-sdk.yml) target **`uefi-x86`** and **`uefi-arm64`** on **Ubuntu Noble** and **Debian Trixie** with the **`cloud`** kernel, published as raw `.img.xz` and `.img.qcow2`.

## Quick Start

Download a `.img.qcow2` from the [latest release](https://github.com/armbian/sdk/releases/latest) and boot it under any QEMU/KVM-capable hypervisor.

- **Default credentials:** `armbian` / `armbian` (configured in [userpatches/firstboot.conf](userpatches/firstboot.conf))
- **code-server** (browser-based VS Code) on port `8443`
- **Build framework** checked out at `~/workspace/build`

## What's Inside

- **Curated source tree** pre-cloned into the code-server workspace at `/armbian/code-server/config/workspace/` (linked at `~/workspace` for shell users): [build](https://github.com/armbian/build), [configng](https://github.com/armbian/configng), [documentation](https://github.com/armbian/documentation), [website](https://github.com/armbian/website), [imager](https://github.com/armbian/imager).
- **Build dependencies** pre-installed (`./compile.sh requirements` already ran in the rootfs) — the first build skips the apt phase.
- **[code-server](https://coder.com/docs/code-server)** installed on first boot via `armbian-config --api module_code-server install`, with the **Python** extension (`ms-python.python`) pre-installed and the **[Claude Code](https://docs.claude.com/en/docs/claude-code)** CLI available in the integrated terminal.
- **SSH ready out of the box**: maintainer's GitHub public keys baked into both `root` and the `armbian` user via Armbian's `PRESET_*_KEY` firstboot mechanism.
- **Asset manifest** at a stable URL for programmatic consumption: <https://github.com/armbian/sdk/releases/latest/download/armbian-images.json>.

## How It's Built

The [GitHub Action](.github/workflows/build-armbian-sdk.yml) drives a `{board} × {release} × {extension}` matrix through the [armbian/build](https://github.com/armbian/build) composite action. Each cell runs the build chroot's [customize-image.sh](userpatches/customize-image.sh) (clones, build deps, key seeding) and stages [provisioning.sh](userpatches/overlay/provisioning.sh) for first boot (code-server install, extension provisioning, ownership handover). After the matrix completes, an aggregator job merges per-image manifests into a single `armbian-images.json` and promotes the release from pre-release to latest.

## Resources

- **[Armbian Documentation](https://docs.armbian.com/Developer-Guide_Overview/)** — Building, configuring, and customizing
- **[Armbian Build Framework](https://github.com/armbian/build)** — The framework this SDK targets
- **[Website](https://www.armbian.com)** — News, features, and board information
- **[Forums](https://forum.armbian.com)** — Community support and discussions
