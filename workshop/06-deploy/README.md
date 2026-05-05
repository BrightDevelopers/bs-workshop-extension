<!-- instructor: walk through each step on your demo player alongside participants. First failure is usually SCP credentials — know the default player SSH password. -->

# Module 6: Deploy to the Player

**Duration:** 20 minutes

**Learning Objectives:**
- Transfer and install the extension package on a live player
- Start the extension and confirm it is running

**Prerequisites:** Module 5 complete. Extension ZIP in your development repo (`/workspace`).

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
ls hello_extension-*.zip
```

Note the filename. You will reference it by the glob pattern `hello_extension-*.zip` throughout this module.

---

## 6.2 Copy the ZIP to the Player

The player's `/usr/local/` is not directly writable over `scp` — copy to the SD card mount point and unzip from there:

```
scp hello_extension-*.zip brightsign@$PLAYER_IP:/storage/sd/
```

No password is required — the player was configured with `SetLoginPassword("none")` during setup.

Expected: a progress bar that completes without error.

> **Warning:** If `scp` fails with "Connection refused", SSH is not enabled on the player. Ask your facilitator to enable SSH via the BrightSign Network or the player's local web interface before continuing.

---

## 6.3 SSH into the Player

```
ssh brightsign@$PLAYER_IP
```

You will see log output from the running autorun. Work through the prompt sequence to reach the Linux shell:

```
^C         ← Ctrl-C: interrupts the autorun, drops to BrightScript debugger
BrightScript Debugger> ^C    ← Ctrl-C again: exits the debugger
BrightSign> exit             ← exit: drops to Linux root shell (insecured players only)
#                            ← you are now root on the Linux shell
```

All commands in sections 6.4 and 6.5 run on the player at this `#` prompt.

---

## 6.4 Install the Extension

Unzip directly from the SD card into `/usr/local/` and run the install script:

```
# cd /usr/local
# unzip /storage/sd/hello_extension-*.zip
# bash ext_hello_extension_install-lvm.sh
```

Expected output from the install script:

```
Verifying checksum... OK
Creating logical volume hello_extension...
Writing squashfs image...
Installation complete. Reboot to activate.
```

> **Warning:** If the checksum verification step prints `FAILED`, the ZIP was corrupted during transfer. Exit the SSH session, re-run the `scp` command from section 6.2, and retry from the `unzip` step.

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
ssh brightsign@$PLAYER_IP
# ps | grep hello_extension
```

Expected: a Java process running `hello-extension-1.0.0.jar` appears in the output.

> **Tip:** If the process is not in the list, check the player syslog for messages from the init script:
> ```
> # logread | grep hello_extension
> ```

---

**Next:** [Module 7 — Verify the Extension](../07-verify/README.md)
