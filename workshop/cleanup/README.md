# Cleanup

**Duration:** 5 minutes

---

## Stop and Remove the Extension

1. SSH into the player and stop the extension:

   ```bash
   ssh brightsign@$PLAYER_IP
   # /var/volatile/bsext/hello_extension/bsext_init stop
   ```

2. Unmount and remove the LVM volume:

   ```bash
   # umount /var/volatile/bsext/ext_hello_extension 2>/dev/null; rmdir /var/volatile/bsext/ext_hello_extension 2>/dev/null
   # lvremove --yes /dev/mapper/bsos-ext_hello_extension
   ```

3. Verify the extension volume is gone:

   ```bash
   # ls /var/volatile/bsext/
   ```

   Expected: `hello_extension` no longer appears in the listing.

---

## Restore Player Settings

If the player is shared or will be used in a demo, restore its settings before handing it back.

1. Open `http://$PLAYER_IP` in a browser.
2. Navigate to **Settings → Developer Options**.
3. Disable **Local Extensions**.
4. Disable **Insecure Content Loading**.
5. Click **Save** / **Apply**.

> **Note:** Skip this step if the facilitator has told you to leave the player in dev mode for the next group.

---

## What You Built

Over the course of this workshop you:

- Built a working BrightSign extension that runs a real HTTP server inside a sandboxed Java process on the player.
- Walked the complete workflow: build → package → deploy → verify → iterate.
- Built an HTML app that communicates with the extension over the player's local network.
- Learned the production hardening steps required before any extension ships.

The [extension-template](https://github.com/brightsign/extension-template) repo is your starting point for any future extension. The same workflow you practiced here applies to any program you package into it.
