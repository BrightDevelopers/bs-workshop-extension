# Facilitator Guide

This guide is for BrightSign engineers running the workshop. Participants do not need to read this.

---

## Pre-Workshop Setup (Day Before)

### Players

- [ ] One player per participant (or per pair for larger groups)
- [ ] All players on the same network as participant workstations
- [ ] Dev mode pre-enabled on all players (saves ~5 minutes per participant in Module 1)
- [ ] IP address list printed or displayed on a shared screen (one row per player)
- [ ] SSH enabled (optional but useful for Module 7 log inspection)

### Facilitator Demo Player

- [ ] Separate player with the finished extension and HTML app already deployed
- [ ] Used for the Module 0 demo — show it working before participants start
- [ ] Keep this player isolated; do not use it for participant exercises

### Workstations (Container Path — Recommended)

- [ ] Docker Desktop installed and running (macOS/Windows) or Docker Engine (Linux)
- [ ] Container image pre-pulled to avoid download time during Module 1:
  ```
  docker pull ghcr.io/brightsign-playground/bs-extension-workshop-devenv:latest
  ```
- [ ] Test the container run command on each workstation OS before the day
- [ ] `$HOME/workshop` (macOS/Linux) or `%USERPROFILE%\workshop` (Windows) directory exists as the volume mount point
- [ ] Network access to GitHub (for `git clone` inside the container), OR pre-cloned repos staged in the volume mount directory

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
| 1 — Environment Setup | 30 min | Windows JDK issues eat time; have a pre-configured VM ready |
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
