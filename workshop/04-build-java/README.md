<!-- instructor: this is the only module that changes between Java/Go/C++ workshops. Everything before and after is identical. -->

# Module 4: Build the Extension — Java

**Duration:** 45 minutes
**Language:** Java 11+ (Maven)
**Learning Objectives:**
- Build a self-contained JAR that satisfies the extension contract
- Write a bsext_init script for a Java extension
- Verify the extension works locally before deploying to the player

**Prerequisites:** Modules 1–3 complete. JDK 11+ and Maven 3.6+ verified (pre-installed in the workshop container).

---

## 4.1 The Extension Contract

Every extension — regardless of language — must satisfy this contract. Module 5 (packaging) and all subsequent modules depend on it exactly as stated here.

1. A binary (or JAR) that starts an HTTP server on **port 8080**.
2. `GET /` returns `{"message":"Hello from BrightSign!","uptime_seconds":N}` with `Content-Type: application/json`.
3. Writes one line to `/tmp/hello-extension.log` on startup.
4. Handles SIGTERM and SIGINT and exits cleanly.
5. A `bsext_init` script that the player OS uses to start and stop the process.

The contract does not care what language produces the binary. Module 5 is identical for Java, Go, and C++ — it packages whatever the build step places in `install/`.

---

## 4.2 Create the Project

1. Open a terminal and create a working directory:
   ```
   $ mkdir -p ~/workshop/hello-extension
   $ cd ~/workshop/hello-extension
   ```

2. Copy the project files from the workshop materials:
   ```
   $ cp -r /path/to/workshop/04-build-java/hello-extension/. .
   ```

3. Verify the structure:
   ```
   $ find . -type f | sort
   ```
   Expected output:
   ```
   ./Makefile
   ./bsext_init
   ./pom.xml
   ./src/main/java/com/brightsign/workshop/HelloExtension.java
   ```

### pom.xml walkthrough

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
Java 11 source and target. The player runs a JVM — confirm the exact version with your facilitator.

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
The shade plugin bundles all dependencies into a single JAR and sets `Main-Class` in the manifest. The player has no Maven, no local classpath, and no internet access. The JAR must be completely self-contained.

**No external dependencies:**
There is no `<dependencies>` block. `com.sun.net.httpserver` is part of the JDK 11+ standard library. We do not need an external HTTP framework.

---

## 4.3 Implement HelloExtension.java

The source file is at `src/main/java/com/brightsign/workshop/HelloExtension.java`. Walk through each part before building.

**Named constants — no magic numbers:**
```java
private static final int HTTP_PORT = 8080;
private static final String LOG_PATH = "/tmp/hello-extension.log";
```
Both values are referenced by the extension contract. Naming them makes the contract visible in the code.

**Startup log write:**
The first thing `main` does (before binding the port) is write one line to `/tmp/hello-extension.log`. The path `/tmp` is used because the extension's own directory on the player is read-only. `/tmp` is a writable RAM disk available on every player.

**HttpServer setup:**
```java
HttpServer server = HttpServer.create(new InetSocketAddress(HTTP_PORT), 0);
server.createContext("/", exchange -> handleRoot(exchange, startMillis));
server.start();
```
`com.sun.net.httpserver.HttpServer` is part of the JDK. No external HTTP library. The `startMillis` timestamp captured at the top of `main` is passed through to the handler for uptime calculation.

**Request handler:**
```java
long uptimeSeconds = (System.currentTimeMillis() - startMillis) / 1000;
String body = "{\"message\":\"Hello from BrightSign!\",\"uptime_seconds\":" + uptimeSeconds + "}";
```
The JSON is built by hand — no JSON library. This is intentional: zero dependencies, zero classpath complexity, and the output is short enough that string concatenation is readable.

**Shutdown hook:**
```java
Runtime.getRuntime().addShutdownHook(new Thread(() -> shutDown(server)));
```
The JVM calls shutdown hooks in response to SIGTERM and SIGINT. The hook logs `"hello-extension stopping"` and calls `server.stop(0)`. This satisfies contract item 4 without any native signal handling.

---

## 4.4 Download the Bundled JRE

BrightSign players do not have a system Java installation. The JRE must be bundled inside the extension's squashfs image alongside the JAR.

The Makefile downloads Eclipse Temurin 11 JRE for `linux/aarch64` from Adoptium and places it in `install/jre/`. This only needs to happen once — the Makefile skips the download if `install/jre/` already exists.

1. Download the JRE:
   ```
   $ make download-jre
   ```
   Expected output:
   ```
   Downloading Eclipse Temurin JRE 11 for linux/aarch64...
   JRE installed at install/jre
   ```
   This downloads ~45MB and extracts to `install/jre/`. The download requires internet access.

2. Verify:
   ```
   $ install/jre/bin/java -version
   ```
   Expected:
   ```
   openjdk version "11.x.x" ...
   ```

> **Note:** `install/jre/` is excluded from version control via `.gitignore`. It is re-downloaded by `make download-jre` on a fresh checkout. Do not commit it.

> **Note:** The JRE is `linux/aarch64` — it only runs on ARM64 hardware (the BrightSign player). Running `install/jre/bin/java` on an x86 workstation will fail. Use the system `java` command for the local smoke test in section 4.6.

---

## 4.5 Write the bsext_init Script

The player OS manages extensions using SysV-style init scripts. The `bsext_init` file is at the project root (not inside `src/`).

**DAEMON_NAME:**
```sh
DAEMON_NAME="hello_extension"
```
Must be lowercase with underscores. This name becomes the PID file path and appears in log messages. Dashes are not safe in all shell contexts — use underscores.

**Bundled JRE path:**
```sh
EXTENSION_DIR="/var/volatile/bsext/${DAEMON_NAME}"
JAVA_BIN="${EXTENSION_DIR}/jre/bin/java"
JAR_PATH="${EXTENSION_DIR}/hello-extension-1.0.0.jar"
```
The extension is mounted read-only at `/var/volatile/bsext/hello_extension/`. The `jre/` directory inside that mount is the Temurin JRE bundled during packaging.

**run_extension function:**
```sh
run_extension() {
    exec "${JAVA_BIN}" -jar "${JAR_PATH}"
}
```
`exec` replaces the shell with the JVM process. Signals go directly to the JVM and trigger the shutdown hook. No shell wrapper remains in the process tree.

**run target (foreground mode):**
```sh
run)
    run_extension
    ;;
```
Runs the extension in the foreground with output going directly to the terminal. Use this when SSH'd into the player to diagnose startup problems.

---

## 4.6 Build

1. From your project directory, run:
   ```
   $ mvn clean package
   ```
   Expected output:
   ```
   [INFO] BUILD SUCCESS
   ```

2. Verify the fat JAR was created:
   ```
   $ ls -lh target/hello-extension-1.0.0.jar
   ```
   Expected: a file larger than 1 KB. Even with no dependencies the shade plugin produces a JAR with a complete manifest and the class files bundled.

> **Note:** The JAR must be self-contained. If you add a dependency in the future, the shade plugin bundles it. The player has no Maven, no classpath configuration, and no internet access — the JAR is the entire runtime.

> **Tip:** Run `make build` instead of `mvn clean package` directly. Both do the same thing; the Makefile wraps `mvn clean package -q` to suppress verbose output.

---

## 4.7 Local Smoke Test

Verify the extension satisfies the contract on your workstation before touching the player. This step catches the majority of problems before they become harder to debug on remote hardware.

1. Start the extension in the background:
   ```
   $ java -jar target/hello-extension-1.0.0.jar &
   ```

2. Wait two seconds for the HTTP server to bind, then send a request:
   ```
   $ curl -s http://localhost:8080/ | python3 -m json.tool
   ```
   Expected output:
   ```json
   {
     "message": "Hello from BrightSign!",
     "uptime_seconds": 2
   }
   ```

3. Check the startup log:
   ```
   $ cat /tmp/hello-extension.log
   ```
   Expected: one line similar to:
   ```
   hello-extension started at 2026-03-21T10:15:30.123Z
   ```

4. Stop the local process:
   ```
   $ kill %1
   ```
   The shutdown hook will log `hello-extension stopping` to stderr before the JVM exits.

> **Warning:** If curl returns `Connection refused`, the HttpServer failed to bind port 8080. Check whether another process is already using that port:
> ```
> $ lsof -i :8080
> ```
> Stop the conflicting process, then retry.

> **Tip:** `make test-local` runs steps 1–4 automatically. It starts the extension, waits 2 seconds, curls the endpoint, and kills the process. Note: this uses the system `java` command, not the bundled ARM64 JRE — that is correct for local testing.

---

## 4.8 What You Have

After completing this module you have everything Module 5 needs:

| Path | Purpose |
|---|---|
| `target/hello-extension-1.0.0.jar` | The self-contained extension JAR |
| `bsext_init` | The init script the player OS uses to start and stop the extension |
| `install/jre/` | Eclipse Temurin JRE 11 for linux/aarch64 — bundled with the extension |

Module 5 is **identical regardless of language**. It copies whatever is in `install/` into the squashfs image. The packaging and deployment workflow does not change based on what language produced the binary.

Proceed to **[Module 5: Package the Extension](../../05-package/README.md)**.
