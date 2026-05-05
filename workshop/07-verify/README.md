# Module 7: Verify the Extension

**Duration:** 15 minutes

**Learning Objectives:**
- Confirm the extension is responding on port 8080
- Read extension logs from the player
- Know the two verification paths: network and SSH

**Prerequisites:** Module 6 complete. Extension installed and player rebooted.

---

## 7.1 Test the HTTP Endpoint

Run this from your workstation, not from inside the player SSH session:

```
curl -s http://$PLAYER_IP:8080/ | python3 -m json.tool
```

Expected output:

```json
{
    "message": "Hello from BrightSign!",
    "uptime_seconds": 47
}
```

If you see this response, the extension is running and reachable from the network.

> **Warning:** If `curl` times out or returns a connection error, the extension process may have failed to start. Skip to section 7.3 for the debug path before spending time on other steps.

---

## 7.2 Read the Startup Log

```
ssh brightsign@$PLAYER_IP "cat /tmp/hello-extension.log"
```

Expected: one line containing an ISO 8601 timestamp from when the extension process started.

> **Note:** `/tmp` is a RAM disk on BrightSign players. Its contents are lost on every reboot. If you need logs to survive a reboot, write them to `/var/volatile/` instead. `/var/volatile/` persists across reboots but is cleared on factory reset.

---

## 7.3 Read Extension Process Logs (Debug Path)

If the extension is not responding to HTTP requests, work through these steps in order.

**Step 1.** Check whether the process is running:

```
ssh brightsign@$PLAYER_IP "ps aux | grep java"
```

**Step 2.** Check the syslog for messages from the init script:

```
ssh brightsign@$PLAYER_IP "logread | grep hello_extension"
```

**Step 3.** Check whether another process has claimed port 8080:

```
ssh brightsign@$PLAYER_IP "netstat -tlnp | grep 8080"
```

**Step 4.** Run the extension in the foreground to see its output directly:

```
ssh brightsign@$PLAYER_IP
# /var/volatile/bsext/ext_hello_extension/bsext_init run
```

Watch the output. Press Ctrl+C to stop.

> **Note:** `bsext_init run` launches the extension process attached to the terminal instead of daemonizing it. Any stdout/stderr from your extension appears here. This is the fastest way to see startup errors.

---

## 7.4 Confirm the Uptime Counter

Wait 60 seconds, then curl the endpoint again:

```
curl -s http://$PLAYER_IP:8080/ | python3 -m json.tool
```

Expected: `uptime_seconds` is higher than the value you saw in section 7.1.

If `uptime_seconds` is increasing, the extension is alive, its internal state is updating, and the HTTP server is responding to each request independently. This is your baseline for confirming the extension is healthy after every future redeploy.

---

**Next:** [Module 8 — Iterate: Change and Redeploy](../08-iterate/README.md)
