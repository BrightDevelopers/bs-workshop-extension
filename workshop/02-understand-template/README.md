<!-- instructor: walk through each file in the terminal with participants. Open bsext_init and explain each function before moving to the examples. -->

# Module 2: Understanding the Extension Template

**Duration:** 20 minutes
**Learning Objectives:**
- Understand the structure and purpose of every file in the extension template
- Understand how bsext_init controls the extension lifecycle
- Know what the packaging scripts produce and why
- See how the same structure scales from hello world to production

**Prerequisites:** Module 1 complete. Extension template cloned.

---

## 2.1 Template Structure

The template is organized as follows. Each example in `examples/` is self-contained; the only shared code is the packaging scripts in `examples/common-scripts/`.

```
extension-template/
├── README.md
├── LICENSE.txt
├── docs/
│   ├── Serial-Connection.md
│   └── Un-Secure-Player.md
├── examples/
│   ├── common-scripts/          ← shared packaging scripts (all languages use these)
│   │   ├── make-extension-lvm
│   │   ├── make-extension-ubi
│   │   ├── pkg-dev.sh
│   │   └── uninstall.sh         ← bundled with every extension; removes it from the player
│   ├── hello_world-java-extension/   ← Java: HTTP server, bundled JRE
│   │   ├── bsext_init
│   │   ├── Makefile
│   │   ├── pom.xml
│   │   └── src/main/java/com/brightsign/workshop/HelloExtension.java
│   ├── hello_world-go-extension/     ← Go: statically compiled, no SDK needed
│   │   ├── bsext_init
│   │   ├── go.mod
│   │   └── main.go
│   ├── hello_world-ts-extension/     ← TypeScript: uses player's Node.js runtime
│   │   ├── bsext_init
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   ├── webpack.config.js
│   │   ├── src/
│   │   │   ├── config.ts
│   │   │   └── index.ts
│   │   └── player-app/
│   │       ├── autorun.brs
│   │       └── listener.js
│   └── time_publisher-cpp-extension/ ← C++: requires BrightSign SDK
│       ├── bsext_init
│       ├── CMakeLists.txt
│       └── src/main.cpp
```

In Module 4 you will copy the contents of `examples/hello_world-java-extension/` to the repo root and build from there. The Makefile in that example is designed to run from the repo root so it can reach `examples/common-scripts/`.

---

## 2.2 The bsext_init Script — The Most Important File

`bsext_init` is a SysV-style init script. It is the entry point for your extension. The player uses it to start, stop, and restart your extension process. Every extension — regardless of language — must have one.

Read the Go example's init script:

```
cat examples/hello_world-go-extension/bsext_init
```

Walk through each part:

**`DAEMON_NAME`**
The extension's unique identifier. Rules: 3–31 characters, lowercase letters, numbers, and underscores only, must start with a letter. This is how the player tracks your process. It must match the directory name your extension installs to on the player.

**`run_extension()`**
Sets environment variables (such as `PORT`) and launches your binary as a background daemon using `start-stop-daemon`. The `--make-pidfile` flag writes a PID file so the player can send signals to your process later.

**`do_start()`**
Reads the player's registry to check whether the autostart flag is set for this extension. If it is, calls `run_extension`. If not, exits without starting the process.

**`do_stop()`**
Reads the PID file written by `start-stop-daemon` and sends `SIGTERM` to the process. After a grace period, sends `SIGKILL` if the process has not exited.

**`start | stop | restart | run` arguments**
Standard SysV init interface. The player calls `bsext_init start` to start your extension, `bsext_init stop` to stop it. The `run` argument is for manual testing — it runs the binary in the foreground.

> **Note:** There is no `manifest.json`. The `bsext_init` script IS the extension definition. The `DAEMON_NAME` value in this file must match the directory name your extension installs to on the player filesystem.

> **Warning:** `DAEMON_NAME` must be globally unique if you plan to submit for production signing. Use an organization-specific prefix — `acme_hello`, not `hello`. BrightSign's signing process will reject names that conflict with existing signed extensions.

---

## 2.3 The Packaging Scripts

Read the packaging script:

```
cat examples/common-scripts/pkg-dev.sh
```

What this script does, in order:

1. Takes your `install/` directory as input along with a filesystem type (`lvm` or `ubi`) and your extension name.
2. Calls either `make-extension-lvm` or `make-extension-ubi` depending on your target player's flash storage type.
3. Creates a squashfs read-only filesystem image from the contents of `install/`.
4. Generates an installation shell script named `ext_<name>_install-lvm.sh` (or `-ubi.sh`).
5. Bundles the squashfs image and the install script into a timestamped ZIP file: `<name>-YYYYMMDD-HHMMSS.zip`.

> **Note:** Extensions are squashfs read-only filesystems, not ZIP files you extract manually. The squashfs image is mounted by the player at runtime as a read-only volume. Your extension binary cannot write to its own directory. Write temporary data to `/dev/shm` (RAM) or `/var/volatile` depending on your player firmware version.

---

## 2.4 What Goes in install/

The `install/` directory is the root of your extension's filesystem. Treat it as `/` for your extension's mount point.

Required contents:
- Your compiled binary (or entry script, or JAR file)
- `bsext_init` — copied from your project root

Optional contents:
- Configuration files your binary reads at startup
- Supporting shared libraries (`.so` files for C++ extensions)
- Static assets your extension reads at runtime (certificates, model files, etc.)

Do not include build artifacts, source files, or development tools. The squashfs image is size-constrained and is mounted read-only.

---

## 2.5 Walk a Complete Example: Go

List the Go example directory:

```
ls examples/hello_world-go-extension/
```

Expected output:
```
bsext_init  main.go
```

Read `main.go`. It does three things:
- Reads `PORT` from the environment (defaults to `5010` if not set)
- Sends a short UDP broadcast message once per second
- Registers handlers for `SIGINT` and `SIGTERM` and shuts down cleanly when either signal arrives

Cross-compile the binary for BrightSign's ARM64 processor:

```
GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o hello_world_go main.go
```

> **Note:** BrightSign players run ARM64 Linux. Your development machine is almost certainly x86-64. `CGO_ENABLED=0` produces a fully static binary with no libc dependency — the safest approach for cross-compilation. Other languages require a cross-compiler toolchain or a Docker container with the BrightSign SDK.

Package the extension:

```
mkdir -p install
cp hello_world_go bsext_init install/
../common-scripts/pkg-dev.sh install lvm hello_world_go
```

Expected output:
```
Creating squashfs image...
Generating install script...
hello_world_go-1747123456.zip
```

> **Note:** The timestamp in the ZIP filename is a Unix epoch value from `date +%s`, not a human-readable date.

That ZIP file is your deployable extension artifact. Upload it to the player via the Control API.

---

## 2.6 The Same Pattern for Every Language

The template works for any language that can produce a runnable binary. The packaging and deployment steps do not change. Only the build step changes.

| Language | Binary produced | Cross-compile method | bsext_init starts it |
|---|---|---|---|
| TypeScript | `index.js` (webpack bundle) | n/a — uses the player's built-in Node.js runtime | `node ./index.js` |
| Go | static binary | `GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build` | `./hello_world_go` |
| C++ | dynamically linked binary | Docker container with BrightSign SDK cross-compiler | `LD_LIBRARY_PATH=./lib ./time_publisher` |
| Java | fat JAR | n/a — JVM-portable bytecode | `./jre/bin/java -jar hello-extension.jar` |

> **Note:** BrightSign players do not have a system Java installation. The Java example
> bundles Eclipse Temurin 11 JRE for `linux/aarch64` inside the squashfs image. The
> `bsext_init` script references `./jre/bin/java` — a path relative to the extension's
> mount point. The `make download-jre` target handles the JRE download automatically.

---

## 2.7 The NPU Gaze Extension — What This Scales To

The template you just studied is the same structure used in production extensions. For reference, see the BrightSign NPU Gaze Extension:

```
https://github.com/brightsign/brightsign-npu-gaze-extension
```

It is a substantially larger binary: it runs a neural processing pipeline, streams camera frames through an NPU inference engine, and publishes gaze coordinates over HTTP. The `bsext_init` structure is identical. The packaging scripts are identical. The deployment workflow is identical.

> **Note:** Do not study the gaze extension's internals during this workshop. The point is that the template does not change regardless of what the extension does. Your team replaces the binary and updates `DAEMON_NAME` in `bsext_init`. Everything else is the same workflow you just learned.

---

## What's Next

In Module 4 you will write your own `bsext_init`, compile your own binary, run `pkg-dev.sh`, and deploy the resulting ZIP to your player. The steps are exactly what you walked through in sections 2.5 above.

Proceed to **[Module 3: The BrightSign Player API](../03-player-api/README.md)**.
