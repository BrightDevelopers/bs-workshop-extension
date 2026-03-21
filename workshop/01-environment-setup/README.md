# Module 1: Environment Setup

**Duration:** 30 minutes
**Learning Objectives:**
- Launch the workshop development container (or verify manual tool installs)
- Connect to your BrightSign player and confirm network access
- Enable developer mode on the player
- Clone the extension template repository

**Prerequisites:** Module 0 complete. Docker Desktop installed (macOS/Windows) or Docker Engine (Linux).

---

## 1.1 Start the Development Container

The workshop uses a pre-built container that includes all required tools: JDK 11, Maven,
Node 14, Go, Git, curl, squashfs-tools, and more. This eliminates tool installation and
version conflicts across macOS, Windows, and Linux.

> **Note:** If your facilitator has confirmed that tools are pre-installed on your
> workstation, skip to section 1.2.

### macOS

1. Open Terminal.

2. Pull the container image:
   ```
   $ docker pull ghcr.io/brightsign-playground/bs-extension-workshop-devenv:latest
   ```

3. Start the container:
   ```
   $ docker run -it --rm \
       -v "$HOME/workshop:/workspace" \
       -p 8080:8080 \
       ghcr.io/brightsign-playground/bs-extension-workshop-devenv:latest
   ```

   You are now at a shell prompt inside the container. All subsequent commands in this
   workshop are run here unless stated otherwise.

   > **Note for Apple Silicon (M1/M2/M3):** If you see a platform warning, add
   > `--platform linux/amd64` to the `docker run` command. The container runs under
   > Rosetta 2 emulation automatically.

4. Verify tools inside the container:
   ```
   $ java -version && mvn -version && node --version && mksquashfs -version 2>&1 | head -1
   ```
   Expected: version lines for each tool, no errors.

### Windows

1. Open PowerShell or Windows Terminal.

2. Pull the container image:
   ```powershell
   docker pull ghcr.io/brightsign-playground/bs-extension-workshop-devenv:latest
   ```

3. Start the container:
   ```powershell
   docker run -it --rm `
       -v "${env:USERPROFILE}\workshop:/workspace" `
       -p 8080:8080 `
       ghcr.io/brightsign-playground/bs-extension-workshop-devenv:latest
   ```

   You are now at a shell prompt inside the container. All workshop commands run here.

4. Verify tools:
   ```
   $ java -version && mvn -version && node --version && mksquashfs -version 2>&1 | head -1
   ```
   Expected: version lines for each tool, no errors.

> **Warning:** Do not use `cmd.exe`. Use PowerShell or Windows Terminal. The volume
> mount syntax above does not work in `cmd.exe`.

### Linux

1. Open a terminal.

2. Pull and start:
   ```
   $ docker run -it --rm \
       -v "$HOME/workshop:/workspace" \
       -p 8080:8080 \
       ghcr.io/brightsign-playground/bs-extension-workshop-devenv:latest
   ```

3. Verify tools as above.

---

## 1.2 Clone the Workshop Repo

Inside the container (or on your workstation if not using the container):

1. Navigate to the workspace directory:
   ```
   $ cd /workspace
   ```

2. Clone:
   ```
   $ git clone https://github.com/BrightSign-Playground/bs-extension-workshop
   $ cd bs-extension-workshop
   ```

3. Verify:
   ```
   $ ls workshop/
   ```
   Expected: numbered module directories (00 through cleanup).

---

## 1.3 Player Setup

Each participant has a BrightSign player at their bench.

1. Connect the power cable to the player.

2. Connect an Ethernet cable from the player to the workshop network switch.

3. Wait for the player to complete its boot sequence. The LED on the front panel turns solid (non-blinking) when ready.

4. Find your player's IP address:
   - **Display method:** If no content is loaded, the player shows its IP on screen during boot.
   - **DHCP table method:** Check your router or network switch DHCP lease table for the player's MAC address.
   - **Facilitator list:** Use the IP assigned to your bench in the workshop network map.

5. Set an environment variable (used in every module from here on):
   ```
   $ export PLAYER_IP=<your_player_ip>
   ```

   > **Tip:** Add this to your container session's history so you can re-run it if you
   > restart the container. If using a persistent `/workspace` volume, save it in a
   > `.envrc` file: `echo "export PLAYER_IP=<ip>" >> /workspace/.envrc`

6. Verify network connectivity from inside the container:
   ```
   $ ping -c 3 $PLAYER_IP
   ```
   Expected:
   ```
   3 packets transmitted, 3 received, 0% packet loss
   ```

7. Verify the BrightSign API is reachable:
   ```
   $ curl -s http://$PLAYER_IP:8008/api/v1/info | python3 -m json.tool
   ```
   Expected: JSON with player model, firmware version, serial number.

---

## 1.4 Enable Developer Mode on the Player

> **Warning:** Developer mode disables signature verification. Never apply these settings
> to a player in a public or production installation.

1. Open a browser on your workstation (not inside the container) and navigate to:
   ```
   http://<your_player_ip>
   ```

2. Log in to the player web interface. Default credentials are on the player's display or
   in the facilitator guide.

3. Navigate to **Settings** → **Developer Options**.

4. Enable **Local Extensions**.

5. Enable **Insecure Content Loading**.

6. Click **Save** (or **Apply**).

7. The player may reboot. Wait for the LED to return to solid, then re-verify:
   ```
   $ curl -s http://$PLAYER_IP:8008/api/v1/info | python3 -m json.tool
   ```
   Expected: same JSON response as step 1.3.7.

---

## 1.5 Clone the Extension Template

1. Inside the container, navigate to workspace:
   ```
   $ cd /workspace
   ```

2. Clone the template (separate from the workshop repo):
   ```
   $ git clone https://github.com/brightsign/extension-template
   $ cd extension-template
   ```

3. Verify contents:
   ```
   $ find . -type f | sort
   ```
   Expected: tree of files including `examples/`, `common-scripts/`, `docs/`.

> **Note:** You are cloning this template to study its structure. In Module 4 you will
> build your own extension. Do not modify these template files.

---

You now have a running container, a connected player in developer mode, and the template
cloned. Proceed to **Module 2**.
