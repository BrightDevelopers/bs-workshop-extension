# Cleanup

**Duration:** 5 minutes

---

## Stop and Remove the Extension

1. Stop the extension:

   ```bash
   curl -X POST http://$PLAYER_IP:8008/api/v1/extensions/hello-extension/stop
   ```

2. Uninstall the extension:

   ```bash
   curl -X DELETE http://$PLAYER_IP:8008/api/v1/extensions/hello-extension
   ```

3. Verify the extension is gone:

   ```bash
   curl -s http://$PLAYER_IP:8008/api/v1/extensions
   ```

   Expected response:

   ```json
   []
   ```

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
