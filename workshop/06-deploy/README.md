<!-- instructor: walk through each step on your demo player alongside participants. First failure is usually SCP credentials — know the default player SSH password. -->

# Module 6: Deploy to the Player

**Duration:** 20 minutes

**Learning Objectives:**
- Transfer and install the extension package on a live player
- Start the extension and confirm it is running

**Prerequisites:** Module 5 complete. Extension ZIP in `~/workshop/hello-extension/`.

---

## 6.1 Confirm Your Environment

Your `PLAYER_IP` variable was set in Module 1. Confirm it is still set:

```
echo $PLAYER_IP
```

Expected: an IP address on the local network (e.g., `192.168.1.42`).

> **Warning:** If `PLAYER_IP` is empty, return to Module 1 and set it before continuing. Every command in this module depends on it.

Confirm the extension ZIP is present:

```
ls ~/workshop/hello-extension/hello_extension-*.zip
```

Note the filename. You will reference it by the glob pattern `hello_extension-*.zip` throughout this module.

---

## 6.2 Copy the ZIP to the Player

```
scp ~/workshop/hello-extension/hello_extension-*.zip admin@$PLAYER_IP:/usr/local/
```

Enter the SSH password when prompted. The default password is shown on the facilitator's screen or on the player's front display.

Expected: a progress bar that completes without error.

> **Warning:** If `scp` fails with "Connection refused", SSH is not enabled on the player. Ask your facilitator to enable SSH via the BrightSign Network or the player's local web interface before continuing.

---

## 6.3 SSH into the Player

```
ssh admin@$PLAYER_IP
```

You are now on the player's BusyBox Linux shell. The prompt will look like:

```
BrightSign:/#
```

All commands in sections 6.4 and 6.5 run on the player, not your workstation.

---

## 6.4 Install the Extension

Change to `/usr/local/`, unzip the package, and run the install script:

```
# cd /usr/local
# ls hello_extension-*.zip
# unzip hello_extension-TIMESTAMP.zip
# bash ext_hello_extension_install-lvm.sh
```

Replace `TIMESTAMP` with the actual timestamp in the filename from the previous `ls`.

Expected output from the install script:

```
Verifying checksum... OK
Creating logical volume hello_extension...
Writing squashfs image...
Installation complete. Reboot to activate.
```

> **Warning:** If the checksum verification step prints `FAILED`, the ZIP was corrupted during transfer. Exit the SSH session, re-run the `scp` command from section 6.2, unzip again, and retry the install script.

---

## 6.5 Reboot the Player

```
# reboot
```

Exit the SSH session. Wait 60–90 seconds for the player to complete its boot sequence and initialize the BrightSign runtime APIs.

> **Note:** The 60–90 second wait is not arbitrary. BrightSign runtime APIs must initialize before `bsext_init` signals the extension to start. The `do_start()` function in `bsext_init` checks an autostart registry key; this check runs only after the runtime is ready. On the first boot after install, the extension starts automatically.

---

## 6.6 Verify the Extension is Running

After the player has rebooted, reconnect and check the process list:

```
ssh admin@$PLAYER_IP
# ps aux | grep hello_extension
```

Expected: a Java process running `hello-extension-1.0.0.jar` appears in the output.

> **Tip:** If the process is not in the list, check the player syslog for messages from the init script:
> ```
> # logread | grep hello_extension
> ```

---

**Next:** [Module 7 — Verify the Extension](../07-verify/README.md)
