# BrightSign Extension Workshop

A self-guided, hands-on workshop for building, packaging, deploying, and iterating on BrightSign OS extensions. By the end you will have deployed a working extension to a live player and walked the full development cycle end-to-end.

**Total time:** ~3.5 hours

---

## What You Will Build

A Java extension ("Hello BrightSign") that runs an HTTP server on port 8080 and returns a JSON uptime response. The extension is intentionally trivial — the workflow is the point. You will also build a BrightScript HTML app that polls the extension and renders its output on the player display.

---

## Prerequisites

- Docker Desktop, Docker Engine, or Podman installed on your workstation
- A GitHub account (personal or work)
- A BrightSign player prepared by your workshop facilitator (insecured, SSH enabled)

---

## Workshop Modules

| Module | Topic | Duration |
|---|---|---|
| [0 — Introduction](workshop/00-introduction/README.md) | What extensions are, system architecture, what you will build | 15 min |
| [1 — Environment Setup](workshop/01-environment-setup/README.md) | Network setup, player connectivity, clone template, start container | 30 min |
| [2 — Understand the Template](workshop/02-understand-template/README.md) | Template structure, bsext_init, packaging scripts | 20 min |
| [3 — Access the Player](workshop/03-player-api/README.md) | SSH, scp, install, verify — facilitator-led demo | 15 min |
| [4 — Build](workshop/04-build/README.md) | Write and compile the extension binary | 45 min |
| [5 — Package](workshop/05-package/README.md) | Produce the deployable squashfs ZIP | 15 min |
| [6 — Deploy](workshop/06-deploy/README.md) | Transfer, install, and start on a live player | 20 min |
| [7 — Verify](workshop/07-verify/README.md) | Confirm the extension is running and serving HTTP | 15 min |
| [8 — Iterate](workshop/08-iterate/README.md) | Change, rebuild, redeploy — the daily dev loop | 20 min |
| [9 — HTML App](workshop/09-html-app/README.md) | Build a BrightScript app that displays extension data on screen | 30 min |
| [10 — Production](workshop/10-production/README.md) | Signing, production checklist, next steps | 15 min |
| [Cleanup](workshop/cleanup/README.md) | Uninstall extension, factory reset player | 5 min |

---

## Dev Container

All build tools (JDK 11, Maven, Go, Node.js, squashfs-tools) are pre-installed in the workshop container. Pull or update it with:

```
make pull-container
```

Or directly:

```
docker pull ghcr.io/brightdevelopers/bs-extension-workshop-devenv:latest
```

Start the container from inside your cloned extension repo:

**macOS / Linux — Docker:**
```
docker run -it --rm \
    -v "$(pwd):/workspace" \
    -e HOST_UID=$(id -u) \
    -e HOST_GID=$(id -g) \
    ghcr.io/brightdevelopers/bs-extension-workshop-devenv:latest
```

**macOS / Linux — Podman (rootless):**
```
podman run -it --rm \
    -v "$(pwd):/workspace" \
    --userns=keep-id \
    ghcr.io/brightdevelopers/bs-extension-workshop-devenv:latest
```

**Windows (PowerShell) — Docker:**
```powershell
docker run -it --rm `
    -v "${PWD}:/workspace" `
    ghcr.io/brightdevelopers/bs-extension-workshop-devenv:latest
```

---

## Facilitator Guide

See [facilitator-guide/README.md](facilitator-guide/README.md) for pre-workshop setup, timing, and common failure fixes.

---

## See Also

- [extension-template](https://github.com/BrightDevelopers/extension-template) — the starter repo used throughout this workshop
- [brightsign-npu-gaze-extension](https://github.com/brightsign/brightsign-npu-gaze-extension) — production extension built on the same template

---

## License

Apache 2.0 — see [LICENSE](LICENSE).
