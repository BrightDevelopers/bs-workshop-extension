# BrightSign Extension Workshop — HTML App

BrightSign HTML application used in the extension workshop. Runs on a BrightSign player
alongside the Hello extension and displays its output on screen.

This repo is used as a git submodule in
[bs-extension-workshop](https://github.com/BrightSign-Playground/bs-extension-workshop)
at `workshop/html-app/`.

---

## What It Does

Polls `http://localhost:8080/` (the Hello extension) every second and renders:
- The message string from the extension
- The extension's uptime in seconds

If the extension is not running, it shows "Extension not responding" and retries.

---

## Prerequisites

- Node.js 14.x and npm (pre-installed in the workshop dev container)
- A BrightSign player with the Hello extension running
- An SD card for deployment

---

## Build

```
$ make prep      # npm install
$ make build     # webpack → dist/
$ make publish   # copy dist/ + autorun.brs → sd/
```

---

## Deploy

Copy the contents of `sd/` to the root of an SD card:

```
$ cp -r sd/. /path/to/sdcard/
```

Insert the SD card into the player and reboot. The player runs `autorun.brs` on boot,
which loads `dist/index.html` as a full-screen HTML widget.

---

## Project Structure

```
src/
├── autorun.brs   BrightScript bootstrap: creates HTML widget, enables SSH + inspector
├── index.html    UI template: message display, uptime counter
└── index.js      Fetch loop: polls extension HTTP API, updates DOM
webpack.config.js Target: node (BrightSign JS runtime). Externalizes @brightsign/* packages.
package.json
Makefile          prep / build / publish / clean
```

---

## Debugging

Open Chrome DevTools and navigate to `http://<player_ip>:2999` to inspect the running
HTML app. SSH is also enabled on port 22.

---

## License

Apache 2.0
