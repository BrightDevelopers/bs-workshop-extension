# Facilitator Guide

This guide is for BrightSign engineers running the workshop. Participants do not need to read this.

---

## Pre-Workshop Setup (Day Before)

### Travel Router and Network (Set Up at the Venue)

The travel router bridges the venue internet to the local workshop LAN. Players connect via Ethernet through a switch; participants connect via the router's WiFi AP.

**Equipment checklist:**
- [ ] Travel router (GL.iNet [GL-MT3000](https://www.amazon.com/dp/B09N72FMH5) recommended, or equivalent)
- [ ] Ethernet switch (one port per player + one uplink to router)
- [ ] Ethernet cables: one per player from switch, one from router LAN port to switch uplink

**Router configuration:**
- [ ] Set WAN mode to **WiFi Repeater / Extender** — connect to the venue WiFi as the WAN uplink
- [ ] Confirm the router's LAN subnet does not conflict with the venue network (change if needed, e.g. `192.168.8.0/24`)
- [ ] Set DHCP reservations: one static IP per player MAC address
- [ ] Confirm internet access through the router before the session: `curl https://api.github.com`

**Player cabling:**
- [ ] Each player connected via Ethernet to the switch
- [ ] Switch uplink connected to the router LAN port

**Verification:**
- [ ] From a workstation on the router WiFi: ping each player IP
- [ ] From a workstation: `curl http://<player_ip>/api/v1/info` returns JSON
- [ ] From a workstation: internet access works (GitHub, Docker Hub reachable)

**Labels and handouts:**
- [ ] IP address label printed and affixed to each player — participants use this in Module 1.2
- [ ] SSID and password written on a card or slide to hand out in Module 1.1

> **If you cannot pre-assign IPs:** participants boot their player without an SD card and the player shows its IP on screen. Add ~5 minutes to Module 1.2.

### Players — Insecuring (Critical — Must Be Done Before the Workshop)

Insecuring a player is **irreversible**. Do this only on dedicated development units.

For each participant player:
- [ ] Connect serial cable (115200 baud, 8N1)
- [ ] Remove SD card, hold SVC button, apply power, press Ctrl-C at bootloader countdown
- [ ] At bootloader prompt: `disable_secure_boot` (or `setenv SECURE_CHECKS 0` + `saveenv` as fallback)
- [ ] Reboot, then at BrightSign shell: `script debug on` + `reboot`
- [ ] Boot with the development `autorun.brs` on SD card (see Module 1.3 in the workshop for the script)
- [ ] After player displays "Setup complete", remove SD card and reboot
- [ ] Verify: SSH in, type `exit` twice — second `exit` should drop to `#` Linux shell (not reboot)
- [ ] Affix IP label to player

Reference: [BrightSign dev environment setup docs](https://github.com/BrightDevelopers/technical-documentation/blob/main/howto-articles/01-setting-up-development-environment.md)

### Facilitator Demo Player

- [ ] Separate pre-insecured player with the finished extension and HTML app already deployed
- [ ] Connected to the travel router switch; verify the extension responds on port 8080 before the session
- [ ] Used for the Module 0 demo — show `curl` output and the HTML app on screen before participants start
- [ ] Do not use it for participant exercises

### Workstations (Container Path — Recommended)

- [ ] Docker Desktop, Docker Engine, or Podman installed and running
- [ ] Container image pre-pulled to avoid download time during Module 1:
  ```
  docker pull ghcr.io/brightsign-playground/bs-extension-workshop-devenv:latest
  ```
- [ ] Test the container run command on each workstation OS before the day (docker and podman are interchangeable):
  - macOS/Linux Docker: `docker run -it --rm -v "$(pwd):/workspace" ghcr.io/brightsign-playground/bs-extension-workshop-devenv:latest`
  - macOS/Linux Podman: `podman run -it --rm -v "$(pwd):/workspace" ghcr.io/brightsign-playground/bs-extension-workshop-devenv:latest`
  - Windows PowerShell Docker: `docker run -it --rm -v "${PWD}:/workspace" ghcr.io/brightsign-playground/bs-extension-workshop-devenv:latest`
  - Windows PowerShell Podman: `podman run -it --rm -v "${PWD}:/workspace" ghcr.io/brightsign-playground/bs-extension-workshop-devenv:latest`
- [ ] Network access to GitHub (for `git clone` on the host before starting the container), OR pre-cloned repos already on participant workstations

### Workstations (Manual Install Fallback)

If Docker is unavailable, ensure these are installed on the workstation:
- [ ] JDK 11+, Maven 3.6+, Node 14.x, Git, curl, unzip
- [ ] `squashfs-tools` (Linux only — this is the hard blocker on macOS/Windows without container)
- [ ] On macOS/Windows without squashfs-tools: pre-run Module 5 packaging for participants as a fallback, provide the ZIP directly

---

## Timing Guide

| Module | Expected | Watch for |
|---|---|---|
| 0 — Introduction | 15 min | Demo can run long; cut Q&A if needed |
| 1 — Environment Setup | 30 min | Travel router connectivity is the most common blocker; verify all players are reachable before starting |
| 2 — Understand Template | 20 min | Often sparks questions; 5-minute buffer built in |
| 3 — Player API | 15 min | Network issues here signal problems ahead; fix before proceeding |
| Break | 10 min | After Module 3 |
| 4 — Build Java Extension | 45 min | Maven download on slow networks; pre-cache `.m2` or use a local mirror |
| 5 — Package | 15 min | Usually smooth |
| 6 — Deploy | 20 min | Most common failure: wrong `manifest.json` |
| 7 — Verify | 15 min | Usually fast |
| Break | 10 min | After Module 7 |
| 8 — Iterate | 20 min | Let fast finishers add a `/health` endpoint |
| 9 — HTML App | 30 min | Node/webpack issues on Windows; have a Linux fallback ready |
| 10 — Production | 15 min | Conceptual; keep it crisp |
| Cleanup | 5 min | |
| **Total** | **~3.5 hours** | |

---

## Common Failures and Fixes

### Module 1: Player not reachable

- Check that the cable is in the correct Ethernet port.
- The player may still be booting — wait 90 seconds and retry.
- Run `arp -a` to scan the network for the player's MAC address.

### Module 1: `curl` to port 8008 returns nothing

- Dev mode may not be enabled yet — enable it manually for that participant via the player's web UI.
- A firewall on the workstation may be blocking outbound connections; check Windows Defender rules.

### Module 4: Maven download hangs

- Use a local `.m2` mirror if one is available on the network.
- Pre-stage the fat JAR on a USB drive as a fallback so participants can skip the build and continue.

### Module 6: Extension fails to start after install

- Most common cause: wrong `mainClass` in `manifest.json` — verify the exact fully-qualified `package.ClassName`.
- Second most common cause: the JAR is not a fat JAR — the shaded JAR with all dependencies bundled is required.
- Pull the extension logs to diagnose:

  ```bash
  curl http://$PLAYER_IP:8008/api/v1/extensions/hello-extension/logs
  ```

### Module 9: webpack fails on Windows

- Use WSL2 or a Linux VM — the simple-gaze-detection-html repo has known issues on macOS and Windows.
- A pre-built `sd/` directory is available on USB as a fallback so participants can continue to Module 10.

---

## Fast Finisher Extensions

Optional exercises for participants who finish ahead of schedule.

**Finished Module 4 early:**

- Add a `GET /health` endpoint that returns `{ "status": "ok" }`.
- Add a request counter to the JSON response body.
- Return the player hostname in the JSON response.

**Finished Module 8 early:**

- Use the `curl`-based deploy flow instead of the web UI to redeploy the extension.
- Explore what other endpoints port 8008 exposes on the player.
