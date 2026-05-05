# extension-template — Project CLAUDE.md

## What This Project Is

A scaffold for building, packaging, and deploying BrightSign player extensions. Teams
clone or fork this repo as the starting point for any extension — Java, Go, C++, or
anything else that produces a runnable binary.

The "Hello BrightSign" Java example is intentionally minimal: it demonstrates the three
primitives every real extension uses (network, filesystem, lifecycle) without any
application-specific complexity.

**Workshop:** The full build → package → deploy → verify → iterate workflow is taught in:
https://github.com/BrightDevelopers/bs-workshop-extension

---

## Key Reference Repositories

- **Extension template (this repo):** https://github.com/brightsign/extension-template
- **NPU gaze extension:** https://github.com/brightsign/brightsign-npu-gaze-extension —
  production-grade extension using the same template structure
- **Companion HTML app:** https://github.com/BrightDevelopers/bs-extension-workshop-html-app —
  BrightSign HTML application that consumes the extension over HTTP

---

## Target Extension: "Hello BrightSign"

The `examples/hello_world-java-extension/` example satisfies this contract:

- HTTP server on port 8080
- `GET /` → `{ "message": "Hello from BrightSign!", "uptime_seconds": N }` with `Content-Type: application/json`
- Writes one line to `/tmp/hello-extension.log` on startup
- Handles SIGTERM and SIGINT; exits cleanly
- `bsext_init` script with matching `DAEMON_NAME`

Any extension that replaces this one must satisfy the same contract for the packaging
and deployment pipeline to work unchanged.

---

## Development Environment

### Dev Container (Recommended)

```
ghcr.io/brightdevelopers/bs-extension-workshop-devenv:latest
```

Includes: JDK 11 + Maven, Go, Node 20, squashfs-tools, Git, curl, ssh/scp.
The Dockerfile is maintained in the workshop repo: https://github.com/BrightDevelopers/bs-workshop-extension

Pull or update the image:
```
make pull-container
```

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

The container mounts the repo as `/workspace`. Run all build commands there.
Add `-p 8080:8080` only if you need to reach the local smoke test from a host browser.

> **Note for Apple Silicon:** The container is `linux/amd64`. Add `--platform linux/amd64`
> if you see a platform warning.

### Manual Install (Fallback)

| Tool | Version | Notes |
|---|---|---|
| JDK | 11+ | https://adoptium.net |
| Maven | 3.6+ | https://maven.apache.org |
| squashfs-tools | any | `sudo apt install squashfs-tools` — Linux only; required for packaging |
| Git, curl, unzip | any | OS package manager |

squashfs-tools is Linux-only. On macOS/Windows without the container, the packaging
step must run inside the container or a Linux VM.

---

## Repository Layout

```
/
├── CLAUDE.md                          ← this file
├── Makefile                           ← pull-container target
└── examples/
    ├── common-scripts/
    │   ├── pkg-dev.sh                 ← packaging orchestrator
    │   ├── make-extension-lvm         ← squashfs + LVM install script generator (eMMC)
    │   └── make-extension-ubi         ← squashfs + UBI install script generator (NAND)
    └── hello_world-java-extension/
        ├── Makefile                   ← build / download-jre / test-local / package / clean
        ├── bsext_init                 ← SysV init script; player OS uses this to start/stop
        ├── pom.xml                    ← Maven config; maven-shade-plugin for fat JAR
        └── src/main/java/com/brightsign/workshop/
            └── HelloExtension.java    ← HTTP server, uptime counter, startup log
```

---

## Makefile Targets (hello_world-java-extension)

Run from the **repository root** — the Makefile references `examples/common-scripts/`.

| Target | Action |
|---|---|
| `make build` | `mvn clean package` → fat JAR |
| `make download-jre` | Download Temurin 11 JRE for `linux/aarch64` into `install/jre/` |
| `make test-local` | Start extension, curl-verify endpoint, stop |
| `make package` | Build + download JRE + produce deployable squashfs ZIP |
| `make clean` | Remove `target/`, `install/`, generated ZIPs |

---

## Packaging Pipeline

```
mvn clean package
    → target/hello-extension-1.0.0.jar

make download-jre
    → install/jre/   (Eclipse Temurin 11 for linux/aarch64)

examples/common-scripts/pkg-dev.sh install lvm hello_extension
    → ext_hello_extension.squashfs        (read-only filesystem image)
    → ext_hello_extension_install-lvm.sh  (SHA256-verified LVM installer)
    → hello_extension-YYYYMMDD-HHMMSS.zip (transfer artifact)
```

The ZIP is transferred to the player via scp, then the install script creates an LVM
logical volume and writes the squashfs image. The player mounts it read-only at
`/var/volatile/bsext/hello_extension/` on next boot.

---

## bsext_init Key Fields

```sh
DAEMON_NAME="hello_extension"           # 3–31 chars, lowercase + underscore, start with letter
EXTENSION_DIR="/var/volatile/bsext/${DAEMON_NAME}"
JAVA_BIN="${EXTENSION_DIR}/jre/bin/java"
JAR_PATH="${EXTENSION_DIR}/hello-extension-1.0.0.jar"
```

`DAEMON_NAME` must match the name argument passed to `pkg-dev.sh`. The `exec` in
`run_extension()` replaces the shell with the JVM so SIGTERM goes directly to the JVM
and triggers shutdown hooks.
