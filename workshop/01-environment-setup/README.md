# Module 1: Environment Setup

**Duration:** 30 minutes
**Learning Objectives:**
- Connect your workstation to the workshop network
- Locate your player's IP address and verify connectivity
- Confirm the player is configured for extension development
- Launch the workshop development container
- Clone the workshop and extension template repositories

**Prerequisites:** Module 0 complete. Docker Desktop installed (macOS/Windows) or Docker Engine (Linux).

---

## 1.1 Workshop Network Setup

<!-- instructor: The travel router is the workshop LAN. Players are already plugged into it. Hand out the SSID and password verbally or on a card. If players have pre-assigned IPs, distribute the IP list before this section. -->

The Workshop Leader (WL) provides a travel router (GL.iNet or equivalent) that creates an isolated local network for all players and workstations. **Do not use venue WiFi for player communication** — it is slower and may block the ports used by the player.

1. On your workstation, connect to the workshop WiFi:
   - **SSID:** provided by your WL
   - **Password:** provided by your WL

2. Confirm your workstation has an IP on the workshop subnet:

   macOS / Linux:
   ```
   $ ip addr show   # or: ifconfig
   ```
   Windows:
   ```
   > ipconfig
   ```
   Expected: an address in the same subnet as the players (e.g. `192.168.8.x`).

---

## 1.2 Find Your Player's IP Address

Each player at your bench has a label showing its IP address. This IP is a static DHCP reservation set up by the WL — it will not change during the workshop.

> **If there is no label on your player**, boot it without an SD card inserted. The player displays its IP address on the connected display during boot.

1. Note the IP address from the label (or from the display).

2. Set an environment variable — this is used in every module from here on:
   ```
   $ export PLAYER_IP=<your_player_ip>
   ```

   > **Tip:** Save this in a file so it survives a container restart:
   > ```
   > $ echo "export PLAYER_IP=$PLAYER_IP" >> /workspace/.envrc
   > ```

3. Verify the player is reachable:
   ```
   $ ping -c 3 $PLAYER_IP
   ```
   Expected:
   ```
   3 packets transmitted, 3 received, 0% packet loss
   ```

4. Verify the BrightSign API responds:
   ```
   $ curl -s http://$PLAYER_IP/api/v1/info | python3 -m json.tool
   ```
   Expected: JSON with player model, firmware version, serial number.

   > **Note:** The DWS runs on port 80 (not 8008). The WL has already configured the
   > player to run the DWS with no authentication required.

---

## 1.3 Understand the Player's Development Configuration

<!-- instructor: Players have already been insecured and had the development autorun.brs applied. Walk participants through what was done and why. Emphasize that insecuring is irreversible — these are dedicated development units. -->

The WL has already prepared each player for extension development. This section explains what was done so you understand the state of the hardware you are working with.

### What "Insecuring" Means

BrightSign players ship with secure boot enabled. Secure boot prevents unsigned code — including native OS extensions — from running. To develop and deploy unsigned extensions, secure boot must be permanently disabled. This is a one-way, irreversible operation called "insecuring" the player.

> **Warning:** Insecuring a player cannot be undone by factory reset, OS update, or any other means. The players provided for this workshop are dedicated development units. Never insecure a production player.

The insecuring process required:
1. Connecting a serial cable (115200 baud, 8N1) and interrupting the bootloader at startup using the SVC button + Ctrl-C.
2. Running `disable_secure_boot` at the bootloader prompt (or `setenv SECURE_CHECKS 0` + `saveenv` as a fallback).
3. Enabling the BrightScript debugger via `script debug on` at the BrightSign shell.

### What the Development autorun.brs Does

After insecuring, the WL booted each player with this `autorun.brs` on an SD card:

```brightscript
Sub Main()
    regB = CreateObject("roRegistrySection", "brightscript")
    regB.Write("debug", "1")
    regB.Flush()

    reg = CreateObject("roRegistrySection", "networking")
    reg.Write("bbhf", "on")
    reg.Write("dwse", "yes")
    reg.Write("curl_debug", "1")
    reg.Write("prometheus-node-exporter-port", "9100")
    reg.Write("ssh", "22")
    reg.Write("telnet_log_level", "7")
    reg.Flush()

    CreateObject("roNetworkConfiguration", 0).SetupDWS({port: "80", open: "none"})

    n = CreateObject("roNetworkConfiguration", 0)
    n.SetLoginPassword("none")
    n.Apply()

    ShowMessage("Setup complete -- manually reboot the player to apply settings")
    sleep(50000)
End Sub
```

This one-time setup wrote the following registry keys and then the player was rebooted **without the SD card**. After that reboot, the player has:

| Feature | Value |
|---|---|
| Local DWS | `http://<player_ip>/` — no login required |
| SSH | port 22 — no password required |
| BrightScript debug | enabled |
| curl verbose logging | enabled |

> **Warning:** This configuration has no authentication. It is only safe on the isolated workshop travel router network. Do not expose these players to a corporate or public network.

### Verify the Player is Ready

1. Open a browser on your workstation and navigate to:
   ```
   http://<your_player_ip>/
   ```
   Expected: the BrightSign Diagnostic Web Server (DWS) home page loads with no login prompt.

2. Verify SSH from inside the container:
   ```
   $ ssh brightsign@$PLAYER_IP
   ```
   Expected: shell prompt with no password required. Type `exit` to leave.

   > **Note:** `exit` at the BrightSign shell (`BrightSign>`) reboots the player on a secure device. On these insecured players, `exit` drops to a Linux root shell (`#`). Type `exit` again to reboot.

3. Verify the DWS API:
   ```
   $ curl -s http://$PLAYER_IP/api/v1/info | python3 -m json.tool
   ```
   Expected: JSON response with `model`, `firmwareVersion`, `serialNumber`.

If any of these fail, ask your WL before proceeding.

---

## 1.4 Start the Development Container

The workshop uses a pre-built container that includes all required tools: JDK 11, Maven,
Node 14, Go, Git, curl, squashfs-tools, and more. This eliminates tool installation and
version conflicts across macOS, Windows, and Linux.

> **Note:** If your WL has confirmed that tools are pre-installed on your
> workstation, skip to section 1.5.

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
   > `--platform linux/amd64` to the `docker run` command.

4. Verify tools:
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

4. Verify tools:
   ```
   $ java -version && mvn -version && node --version && mksquashfs -version 2>&1 | head -1
   ```
   Expected: version lines for each tool, no errors.

   > **Warning:** Use PowerShell or Windows Terminal — not `cmd.exe`. The volume mount syntax does not work in `cmd.exe`.

### Linux

1. Open a terminal and start the container:
   ```
   $ docker run -it --rm \
       -v "$HOME/workshop:/workspace" \
       -p 8080:8080 \
       ghcr.io/brightsign-playground/bs-extension-workshop-devenv:latest
   ```

2. Verify tools as above.

---

## 1.5 Clone the Workshop Repo

Inside the container:

1. Navigate to workspace:
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

## 1.6 Clone the Extension Template

1. From the workspace directory, clone the template alongside the workshop repo:
   ```
   $ cd /workspace
   $ git clone https://github.com/brightsign/extension-template
   ```

2. Verify contents:
   ```
   $ find extension-template -type f | sort
   ```
   Expected: files under `examples/`, `common-scripts/`, `docs/`.

   > **Note:** You are cloning this template to study its structure. In Module 4 you will
   > build your own extension. Do not modify these template files.

---

You now have a connected, insecured player, a running container, and both repos cloned.
Proceed to **[Module 2](../02-understand-template/README.md)**.
