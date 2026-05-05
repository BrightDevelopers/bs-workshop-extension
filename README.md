# extension-template

A scaffold for building, packaging, and deploying BrightSign extensions. Clone or use this as a template for any extension — Java, Go, TypeScript, C++, or anything else that produces a runnable binary.

## What's Here

| Path | Purpose |
|---|---|
| `examples/hello_world-java-extension/` | Complete Java example: HTTP server, uptime endpoint, bundled JRE |
| `examples/common-scripts/` | Packaging scripts — produce the squashfs + LVM install artifact every extension needs |

## Quick Start (Java)

Run from the repository root:

```
cp -r examples/hello_world-java-extension/. .
make build          # compile fat JAR
make test-local     # smoke test: start → curl → stop
make package        # squashfs ZIP ready to deploy to the player
```

## Learn This Template

The **BrightSign Extension Workshop** teaches the full build → package → deploy → verify → iterate cycle using this template:

**https://github.com/BrightDevelopers/bs-workshop-extension**

## Dev Container

A pre-built container with all required tools (JDK, Maven, Go, Node, squashfs-tools) is
maintained in the workshop repo. Pull or update it with:

```
make pull-container
```

Or directly:

```
docker pull ghcr.io/brightdevelopers/bs-extension-workshop-devenv:latest
```

To use it, run from inside your cloned repo directory:

**Docker (macOS / Linux):**
```
docker run -it --rm \
    -v "$(pwd):/workspace" \
    -e HOST_UID=$(id -u) \
    -e HOST_GID=$(id -g) \
    ghcr.io/brightdevelopers/bs-extension-workshop-devenv:latest
```

**Podman (rootless):**
```
podman run -it --rm \
    -v "$(pwd):/workspace" \
    --userns=keep-id \
    ghcr.io/brightdevelopers/bs-extension-workshop-devenv:latest
```

**Windows (PowerShell — Docker):**
```powershell
docker run -it --rm `
    -v "${PWD}:/workspace" `
    ghcr.io/brightdevelopers/bs-extension-workshop-devenv:latest
```

## See Also

- [BrightSign Extension Workshop](https://github.com/BrightDevelopers/bs-workshop-extension) — workshop teaching this template end-to-end, including the dev container Dockerfile
- [brightsign-npu-gaze-extension](https://github.com/brightsign/brightsign-npu-gaze-extension) — production extension built on this template

## License

Apache 2.0 — see [LICENSE](LICENSE).
