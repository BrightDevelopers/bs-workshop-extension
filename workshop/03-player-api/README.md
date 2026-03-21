<!-- instructor: run these curl commands live against your demo player. Participants follow along. This builds confidence before they deploy their own extension. -->

# Module 3: The BrightSign Player API

**Duration:** 15 minutes
**Learning Objectives:**
- Distinguish between the control API port and the extension server port
- Query player info, extension list, and system status via curl
- Execute the full extension lifecycle (install, start, stop, uninstall) using API calls

**Prerequisites:** Module 2 complete. `PLAYER_IP` environment variable set.

---

## 3.1 Two Ports, Two Purposes

The player exposes two HTTP interfaces. They serve different roles and you will use both throughout the rest of the workshop.

```
BrightSign Player
├── :8008  BrightSign Control API
│           Install / start / stop / uninstall extensions
│           Query player info, system status, logs
│           Manage content
│
└── :8080  Your Extension's Server
            Whatever HTTP interface your extension exposes
            Only active when your extension is running
```

Requests to `:8008` go to BrightSign firmware. Requests to `:8080` go to your code.

---

## 3.2 Query the Player

Run these commands against your player. Confirm each response before moving to the next.

1. Get player info:
   ```
   $ curl -s http://$PLAYER_IP:8008/api/v1/info | python3 -m json.tool
   ```
   Expected output:
   ```json
   {
       "model": "XT1144",
       "firmwareVersion": "9.x.x",
       "serialNumber": "..."
   }
   ```

2. List installed extensions:
   ```
   $ curl -s http://$PLAYER_IP:8008/api/v1/extensions | python3 -m json.tool
   ```
   Expected output (no extensions installed yet):
   ```json
   []
   ```

3. Get system status:
   ```
   $ curl -s http://$PLAYER_IP:8008/api/v1/system/status | python3 -m json.tool
   ```
   Expected output:
   ```json
   {
       "uptime": 12345,
       "temperature": "...",
       "storage": {...}
   }
   ```

> **Note:** `python3 -m json.tool` pretty-prints JSON. It is available on every Python 3 installation with no extra packages.

> **Tip:** If you prefer `jq`, install it with your system package manager (`apt install jq`, `brew install jq`, etc.) and substitute `| jq .` anywhere you see `| python3 -m json.tool`.

---

## 3.3 Extension Lifecycle via API

These are the six operations you will use repeatedly in Modules 6, 7, and 8. Run through them now against the demo player so the pattern is familiar before you use your own extension.

**Install** — POST a ZIP file to the extensions endpoint:
```
$ curl -X POST http://$PLAYER_IP:8008/api/v1/extensions \
  -F "file=@hello-extension.zip"
```
Expected output:
```json
{"status": "installed", "name": "hello-extension"}
```

**Start** — start a named extension:
```
$ curl -X POST http://$PLAYER_IP:8008/api/v1/extensions/hello-extension/start
```
Expected output:
```json
{"status": "running"}
```

**Get status** — query the current state of an extension:
```
$ curl -s http://$PLAYER_IP:8008/api/v1/extensions/hello-extension | python3 -m json.tool
```
Expected output:
```json
{
    "name": "hello-extension",
    "status": "running",
    "pid": 1234
}
```

**Stop** — stop a running extension:
```
$ curl -X POST http://$PLAYER_IP:8008/api/v1/extensions/hello-extension/stop
```
Expected output:
```json
{"status": "stopped"}
```

**Uninstall** — remove the extension from the player:
```
$ curl -X DELETE http://$PLAYER_IP:8008/api/v1/extensions/hello-extension
```
Expected output:
```json
{"status": "uninstalled"}
```

**Get logs** — retrieve stdout/stderr from the extension process:
```
$ curl -s http://$PLAYER_IP:8008/api/v1/extensions/hello-extension/logs
```
Expected output: plain text lines from your extension's output.

> **Note:** These exact commands are used in Modules 6, 7, and 8. Bookmark this module or keep this terminal window open.

---

## 3.4 Key Takeaway

The player API does not change based on what language your extension is written in or what your extension does. The packaging and deployment workflow covered in Modules 5 through 8 is identical for every extension. This is what the template from Module 1 standardizes — it handles the packaging so you only write application code.
