# Cleanup

**Duration:** 5 minutes

---

## Uninstall the Extension

Run the uninstall script bundled inside the extension:

```bash
ssh brightsign@$PLAYER_IP
# /var/volatile/bsext/ext_hello_extension/uninstall.sh
```

Expected:

```
Uninstalling extension: hello_extension
Extension hello_extension uninstalled. Reboot to complete removal.
```

---

## Factory Reset the Player

The cleanest way to return the player to a known state is a full factory reset. This removes all installed extensions, clears the registry keys written during setup, and restores secure boot behavior.

Consult the [Factory Reset Documentation](https://docs.brightsign.biz/space/DOC/1936916598/Factory+Reset+a+Player). A full hard factory reset (2-button approach) is recommended.

> **Note:** Skip the factory reset if your facilitator has told you to leave the player ready for the next group.

---

## What You Built

Over the course of this workshop you:

- Built a working BrightSign extension that runs a real HTTP server inside a sandboxed Java process on the player.
- Walked the complete workflow: build → package → deploy → verify → iterate.
- Built an HTML app that communicates with the extension over the player's local network.
- Learned the production hardening steps required before any extension ships.

The [extension-template](https://github.com/BrightDevelopers/extension-template) repo is your starting point for any future extension. The same workflow you practiced here applies to any program you package into it.
