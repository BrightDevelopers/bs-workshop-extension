<!-- instructor: this is the only module that changes between Java/Go/C++ sessions. Direct WPs to their language section. Everything before and after this module is identical regardless of language. -->

# Module 4: Build the Extension

**Duration:** 45 minutes
**Learning Objectives:**
- Build a binary that satisfies the extension contract
- Write a `bsext_init` script to manage the process lifecycle
- Verify the extension works locally before deploying to the player

**Prerequisites:** Modules 1–3 complete. Development container running.

Your WL will direct you to the section for your session:

- [Java](#java) — JDK 11, Maven, fat JAR
- [Go](#go) — coming soon
- [C++](#cpp) — coming soon

---

## The Extension Contract

Every extension — regardless of language — must satisfy this contract. Module 5 and all
subsequent modules depend on it exactly as stated here.

1. A binary (or JAR) that starts an HTTP server on **port 8080**.
2. `GET /` returns `{"message":"Hello from BrightSign!","uptime_seconds":N}` with `Content-Type: application/json`.
3. Writes one line to `/tmp/hello-extension.log` on startup.
4. Handles SIGTERM and SIGINT and exits cleanly.
5. A `bsext_init` script that the player OS uses to start and stop the process.

The contract does not care what language produces the binary. Module 5 is identical for
Java, Go, and C++ — it packages whatever is in `install/`.

---

<a name="java"></a>
## Java

**Language:** Java 11+ (Maven)

> **Note:** BrightSign players do not have a system Java installation. The JRE is bundled
> inside the squashfs image. The Makefile handles the download automatically.

### 4.1 Create the Project

Your development repo is already mounted at `/workspace` inside the container. Copy the
Java starter project from the template examples into the repo root:

```
cp -r examples/hello_world-java-extension/. .
```

Verify the key project files are in place:

```
ls Makefile bsext_init pom.xml src/main/java/com/brightsign/workshop/HelloExtension.java
```

Expected: all four files listed without error.

### 4.2 Walk pom.xml

Open `pom.xml` and note three things:

**Coordinates and Java version:**
```xml
<groupId>com.brightsign.workshop</groupId>
<artifactId>hello-extension</artifactId>
<version>1.0.0</version>
<properties>
    <maven.compiler.source>11</maven.compiler.source>
    <maven.compiler.target>11</maven.compiler.target>
</properties>
```

**maven-shade-plugin:**
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-shade-plugin</artifactId>
    ...
    <configuration>
        <transformers>
            <transformer implementation="...ManifestResourceTransformer">
                <mainClass>com.brightsign.workshop.HelloExtension</mainClass>
            </transformer>
        </transformers>
    </configuration>
</plugin>
```
The shade plugin bundles all dependencies into a single JAR and sets `Main-Class` in the
manifest. The player has no Maven, no classpath, no internet access. The JAR must be
completely self-contained.

**No external dependencies:**
There is no `<dependencies>` block. `com.sun.net.httpserver` is part of the JDK 11+
standard library — no external HTTP framework needed.

### 4.3 Walk HelloExtension.java

Open `src/main/java/com/brightsign/workshop/HelloExtension.java`. Walk through each part
before building.

**Named constants:**
```java
private static final int HTTP_PORT = 8080;
private static final String LOG_PATH = "/tmp/hello-extension.log";
```

**Startup log write:**
The first thing `main` does is write one line to `/tmp/hello-extension.log`. `/tmp` is a
writable RAM disk on every player. The extension's own directory is read-only.

**HttpServer setup:**
```java
HttpServer server = HttpServer.create(new InetSocketAddress(HTTP_PORT), 0);
server.createContext("/", exchange -> handleRoot(exchange, startMillis));
server.start();
```
`com.sun.net.httpserver.HttpServer` is part of the JDK — no external HTTP library.

**Request handler:**
```java
long uptimeSeconds = (System.currentTimeMillis() - startMillis) / 1000;
String body = "{\"message\":\"Hello from BrightSign!\",\"uptime_seconds\":" + uptimeSeconds + "}";
```
JSON built by hand — intentional. Zero dependencies, readable output.

**Shutdown hook:**
```java
Runtime.getRuntime().addShutdownHook(new Thread(() -> shutDown(server)));
```
The JVM calls shutdown hooks on SIGTERM and SIGINT. This satisfies contract item 4
without any native signal handling.

### 4.4 Walk bsext_init

Open `bsext_init` at the project root.

**DAEMON_NAME:**
```sh
DAEMON_NAME="hello_extension"
```
Lowercase with underscores. Becomes the PID file path and appears in log messages.

**Bundled JRE path:**
```sh
EXTENSION_DIR="/var/volatile/bsext/${DAEMON_NAME}"
JAVA_BIN="${EXTENSION_DIR}/jre/bin/java"
JAR_PATH="${EXTENSION_DIR}/hello-extension-1.0.0.jar"
```
The extension mounts read-only at `/var/volatile/bsext/hello_extension/`. The `jre/`
directory inside is the Temurin JRE bundled during packaging.

**exec in run_extension:**
```sh
run_extension() {
    exec "${JAVA_BIN}" -jar "${JAR_PATH}"
}
```
`exec` replaces the shell with the JVM. Signals go directly to the JVM and trigger its
shutdown hook. No shell wrapper in the process tree.

**run (foreground mode):**
```sh
run)
    run_extension
    ;;
```
Use `bsext_init run` when SSH'd into the player to see output directly. Ctrl-C to stop.

### 4.5 Download the Bundled JRE

The Makefile downloads Eclipse Temurin 11 JRE for `linux/aarch64` into `install/jre/`.
Run this once — it skips the download if `install/jre/` already exists.

```
make download-jre
```
Expected:
```
Downloading Eclipse Temurin JRE 11 for linux/aarch64...
JRE installed at install/jre
```

> **Note:** `install/jre/` is in `.gitignore` — do not commit it. It is re-downloaded by
> `make download-jre` on a fresh checkout.

> **Note:** The JRE is `linux/aarch64` — it only runs on the BrightSign player (ARM64).
> Use the system `java` for the local smoke test in the next section.

### 4.6 Build

```
make build
```
Expected:
```
[INFO] BUILD SUCCESS
```

Verify the fat JAR:
```
ls -lh target/hello-extension-1.0.0.jar
```
Expected: file present, larger than 1 KB.

> **Note:** The JAR must be self-contained. If you add a dependency later, the shade
> plugin bundles it automatically.

### 4.7 Local Smoke Test

Verify the extension satisfies the contract on your workstation before touching the
player. This catches most problems before they become harder to debug on remote hardware.

1. Start the extension:
   ```
   java -jar target/hello-extension-1.0.0.jar &
   ```

2. Test the endpoint:
   ```
   curl -s http://localhost:8080/ | python3 -m json.tool
   ```
   Expected:
   ```json
   {
     "message": "Hello from BrightSign!",
     "uptime_seconds": 2
   }
   ```

3. Check the startup log:
   ```
   cat /tmp/hello-extension.log
   ```
   Expected: one line with an ISO timestamp.

4. Stop the process:
   ```
   kill %1
   ```

> **Warning:** If curl returns `Connection refused`, port 8080 is not bound. Check for
> another process: `lsof -i :8080`

> **Tip:** `make test-local` runs steps 1–4 automatically.

### 4.8 What You Have

| Path | Purpose |
|---|---|
| `target/hello-extension-1.0.0.jar` | Self-contained extension JAR |
| `bsext_init` | Init script the player OS uses to start and stop the extension |
| `install/jre/` | Eclipse Temurin JRE 11 for linux/aarch64 — bundled with the extension |

Module 5 is **identical regardless of language.** It copies whatever is in `install/`
into the squashfs image.

Proceed to **[Module 5: Package the Extension](../05-package/README.md)**.

---

<a name="go"></a>
## Go

> **Coming soon.** This section will cover building the Hello BrightSign extension in Go,
> cross-compiling for `linux/arm64`, and writing a `bsext_init` for a static binary.
> The packaging and deployment steps (Modules 5–10) are identical to the Java variant.

---

<a name="cpp"></a>
## C++

> **Coming soon.** This section will cover building the Hello BrightSign extension in
> C++ using CMake and the BrightSign SDK Docker container, cross-compiling for
> `linux/arm64`. The packaging and deployment steps (Modules 5–10) are identical to the
> Java variant.
