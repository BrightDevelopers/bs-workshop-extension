<!-- instructor: this is the most important module for teams taking the workflow home. The deploy loop is what they will run daily. Watch for participants skipping the stop step — it causes the install script to fail. -->

# Module 8: Iterate — Change and Redeploy

**Duration:** 20 minutes

**Learning Objectives:**
- Execute the full change → rebuild → repackage → redeploy cycle
- Know the stop and uninstall steps required before reinstalling

**Prerequisites:** Module 7 complete. Extension running on player.

---

## 8.1 Make a Code Change

Open `src/main/java/com/brightsign/workshop/HelloExtension.java` in your editor (the file is in your development repo at `/workspace`).

In `handleRoot`, change the message string:

From:

```java
String body = "{\"message\":\"Hello from BrightSign!\",\"uptime_seconds\":" + uptimeSeconds + "}";
```

To:

```java
String body = "{\"message\":\"Hello from BrightSign! (v2)\",\"uptime_seconds\":" + uptimeSeconds + "}";
```

Save the file.

> **Tip:** If you finish early: add a `/health` endpoint that returns `{"status":"ok"}`, and add a `request_count` field to the root response that increments on each request.

---

## 8.2 Rebuild

```
make build
```

Expected: no output (`-q` suppresses Maven's progress lines). A non-zero exit code means a compile error — fix it before continuing.

---

## 8.3 Repackage

Produce a new ZIP with the updated JAR:

```
make package
```

The new ZIP will have a later timestamp in its filename. Confirm:

```
ls -lh hello_extension-*.zip
```

---

## 8.4 Stop and Uninstall the Old Extension

> **Warning:** You must stop the running extension and remove the old LVM volume before installing a new version. The install script creates the LVM volume by name. If a volume with that name already exists, the script fails. Do not skip this step.

SSH into the player:

```
ssh brightsign@$PLAYER_IP
```

Run the uninstall script bundled inside the extension:

```
# /var/volatile/bsext/ext_hello_extension/uninstall.sh
```

Expected:

```
Uninstalling extension: hello_extension
Extension hello_extension uninstalled. Reboot to complete removal.
```

> **Note:** `uninstall.sh` handles everything — it stops the process, unmounts the squashfs volume, and removes the LVM logical volume. It was bundled into the squashfs image during packaging and lives at the extension's mount point.

---

## 8.5 Copy and Reinstall

From your workstation, copy the new ZIP to the SD card:

```
scp hello_extension-*.zip brightsign@$PLAYER_IP:/storage/sd/
```

On the player, unzip directly from the SD card into `/usr/local/` and install:

```
# cd /usr/local
# unzip /storage/sd/hello_extension-*.zip
# bash ext_hello_extension_install-lvm.sh
```

Expected install output:

```
Verifying checksum... OK
Creating logical volume hello_extension...
Writing squashfs image...
Installation complete. Reboot to activate.
```

Reboot:

```
# reboot
```

Wait 60–90 seconds.

---

## 8.6 Verify the Change

After reboot:

```
curl -s http://$PLAYER_IP:8080/ | python3 -m json.tool
```

Expected:

```json
{
    "message": "Hello from BrightSign! (v2)",
    "uptime_seconds": 12
}
```

The updated message confirms the new squashfs image is mounted and running.

---

## 8.7 The Deploy Loop

This is the complete cycle for every change. Write it down. Steps 5–10 are identical regardless of language or framework.

```mermaid
flowchart TD
    A["1. Edit source code"] --> B["2. Rebuild\nmvn clean package"]
    B --> C["3. Update install/\ncopy new JAR or binary"]
    C --> D["4. Repackage\npkg-dev.sh → new ZIP"]
    D --> E["5. scp ZIP to /storage/sd on player"]
    E --> F["6. SSH to Linux shell\nCtrl-C · Ctrl-C · exit"]
    F --> G["7. SSH: uninstall.sh"]
    G --> H["8. SSH: cd /usr/local\nunzip from /storage/sd + install"]
    H --> I["9. SSH: reboot"]
    I --> J["10. curl to verify"]
    J -.->|"make another change"| A
```

> **Note:** Steps 2–4 change per language: Go uses `go build`, C++ uses `make`, and so on. Steps 5–10 are the same for every extension. The squashfs packaging and LVM deployment mechanism does not care what runtime is inside the image.

---

**Workshop complete.** If you are continuing to the production module, see [Module 10 — Production Considerations](../10-production/README.md).
