# BrightSign Extension Workshop — Project CLAUDE.md

## What This Project Is

A hands-on, instructor-led workshop (AWS catalog style) that teaches development teams how
to build, package, deploy, and iterate on BrightSign player extensions using the
[extension-template](https://github.com/brightsign/extension-template).

**Primary goal:** Reduce extension development time from days to hours by showing teams
the complete, repeatable workflow — from blank repo to running extension on a live player.
The "Hello BrightSign" example program is a teaching vehicle, not the point. The point
is the template, the workflow, and the packaging and deployment pipeline that teams take
home and apply to whatever they are actually building.

**Current milestone:** Working Java workshop deliverable in one week.
**Planned future variants:** Go, C++ (swap Module 4 only; everything else is shared).

This repo covers the **extension half** of the system. A companion HTML repo (separate
repo, same workshop) covers the BrightSign HTML app that runs on the player and consumes
the extension. See "Companion HTML App" section below.

---

## Key Reference Repositories

- **Extension template:** https://github.com/brightsign/extension-template — the scaffold
  every participant clones. The workshop teaches this template, not a custom project.
- **NPU gaze extension:** https://github.com/brightsign/brightsign-npu-gaze-extension —
  a production-grade extension using the same template. Use it to show what the template
  scales to; never reference its domain-specific complexity (NPU, camera, gaze).
- **Simple gaze HTML app:** https://github.com/brightsign/simple-gaze-detection-html —
  the structural model for the companion HTML repo (BrightScript bootstrap, webpack
  bundle, Makefile pattern, SD card deploy pipeline).

---

## Workshop Philosophy

- **The example program is a teaching prop, not the deliverable.** "Hello BrightSign" is
  intentionally trivial. What participants take home is the template workflow: any team
  can slot their own binary — Java, Go, C++, Rust, anything — into the same packaging
  and deployment pipeline without understanding the internals of the template.
- **The binary section is the only swappable part.** Module 4 (Build the Extension
  Binary) is language-specific. Every other module is shared, identical across languages.
  This is the core structural decision. Do not leak language-specific content elsewhere.
- **Two repos, one workshop.** The extension repo and the HTML app repo are developed
  and deployed independently, but taught together. Teams leave knowing how to build both
  halves of a real extension-driven application.
- **AWS workshop conventions.** Number every participant action step. Use callout blocks
  (Note / Warning / Tip). Every module has a stated learning objective. Participants type
  real commands and see real output.
- **Instructor-led with self-paced fallback.** Every step is complete enough to follow
  alone. Add facilitator guidance in `<!-- instructor: ... -->` HTML comments for things
  that benefit from live demonstration.

---

## Target Extension: "Hello BrightSign"

A deliberately minimal extension that exercises the full lifecycle:

- Starts an HTTP server on port 8080.
- `GET /` → returns JSON: `{ "message": "Hello from BrightSign!", "uptime_seconds": N }`.
- Writes one line to `/tmp/hello-extension.log` on startup.
- Runs until shutdown signal; exits cleanly.

This covers the three primitives every real extension uses: network, filesystem,
lifecycle. Nothing else. The moment participants try to add features, they are ahead of
the workshop — which is the right problem to have.

---

## Companion HTML App (Separate Repo)

A standalone BrightSign HTML application that runs on the same player and interacts with
the extension. It is developed in a sibling repo (name TBD, e.g.
`bs-workshop-html-app`).

### Structural model: simple-gaze-detection-html

Follow the structure and conventions from
https://github.com/brightsign/simple-gaze-detection-html exactly:

| Pattern | How we apply it |
|---|---|
| `src/autorun.brs` — BrightScript bootstrap | Same: load HTML widget, enable SSH/inspector |
| `src/index.html` — HTML template | Same: minimal markup, load `bundle.js` |
| `src/index.js` — application logic | Fetch from extension HTTP endpoint instead of polling `/tmp/` |
| Webpack + Babel bundle | Same toolchain |
| `make prep / build / publish / clean` | Same Makefile targets |
| Deploy to `sd/` → SD card | Same deployment path |

### Interaction contract between extension and HTML app

The extension exposes one endpoint that the HTML app calls:

```
GET http://localhost:8080/
→ { "message": "Hello from BrightSign!", "uptime_seconds": N }
```

The HTML app polls this endpoint once per second, renders the message and uptime on
screen. This demonstrates the full communication path:
extension process (port 8080) ↔ BrightSign JS runtime ↔ HTML UI.

### HTML app layout

```
bs-workshop-html-app/
├── src/
│   ├── autorun.brs       # BrightScript bootstrap
│   ├── index.html        # UI template
│   └── index.js          # fetch loop, DOM update
├── webpack.config.js
├── package.json
├── Makefile              # prep / build / publish / clean
└── README.md
```

Webpack config targets `node` (BrightSign JS runtime), externalizes `@brightsign/*`
packages. Node 14.x. Same as simple-gaze-detection-html.

---

## Workshop Modules (Canonical Structure)

Target duration: **3.5 hours** including short breaks. This is a half-day session.

### Module 0 — Introduction (15 min)
Learning objective: Understand what BrightSign extensions are and why teams build them.
- What is a BrightSign extension? Where does it run? What problem does it solve?
- System architecture diagram: player OS ↔ extension (port 8080) ↔ HTML app (port 2999).
- Demo the finished product: facilitator shows JSON response from `curl` and the HTML
  app rendering it live on the player display.
- What the template gives you: packaging, manifest, deploy pipeline — ready to use.
- What we will build today (and what we will NOT build — scope is intentionally small).

### Module 1 — Environment Setup (30 min)
Learning objective: Verify all tools are present and the player is reachable.
- Workstation: JDK 11+, Maven 3.6+, Node 14, Git, curl, unzip.
- Player: power on, find IP, enable dev mode (Local Extensions + Insecure Content Loading).
- Verify connectivity: `ping <player_ip>`, `curl http://<player_ip>:8008`.
- Clone the extension template: `git clone https://github.com/brightsign/extension-template`.

### Module 2 — Understand the Template (20 min)
Learning objective: Know what every file in the extension template does and why.
- Walk every file in the cloned template.
- `manifest.json` deep-dive: every field, what breaks if wrong.
- How the player finds, installs, starts, and stops an extension.
- Show npu-gaze-extension: same template, bigger program. Same workflow scales.

### Module 3 — Understand the Player API (15 min)
Learning objective: Control extensions via the BrightSign REST API.
- Port 8008 is the player control plane. Port 8080 is the extension's own data plane.
- Live `curl` demos: list extensions, start, stop, get logs.
- These same `curl` commands work for any extension — this API does not change.

### Module 4 — Build the Extension Binary [MODULAR — SWAP PER LANGUAGE] (45 min)
Learning objective: Produce a binary that satisfies the extension contract.

Each language variant lives in `workshop/04-build-<language>/`. Swap this module for
the customer's language. The output contract is always the same: one binary (or JAR)
plus any supporting files, which Module 5 packages.

#### 04-build-java/
- Create Maven project. Implement `HelloExtension.java`: embedded HTTP server
  (`com.sun.net.httpserver`), uptime counter, startup log write.
- `mvn clean package` → fat JAR with all dependencies.
- Local smoke test: `java -jar target/hello-extension.jar` → `curl localhost:8080`.

#### 04-build-go/ (future)
- `go mod init`, `net/http`, cross-compile for BrightSign ARM target.
- Same local smoke test.

#### 04-build-cpp/ (future)
- CMake + cpp-httplib, cross-compile toolchain.
- Same local smoke test.

### Module 5 — Package the Extension (15 min)
Learning objective: Produce a valid extension ZIP from any binary.
- Create ZIP: `manifest.json` at root, JAR/binary alongside it.
- Validate ZIP structure before upload (common failure modes: wrong `mainClass` path,
  missing dependencies, JAR not self-contained).
- This step is language-agnostic. The packaging workflow is identical for every variant.

### Module 6 — Deploy to the Player (20 min)
Learning objective: Install and start the extension on a live player.
- Upload ZIP via player web UI — walk every click with screenshots.
- Alternatively: `curl` upload for command-line preference.
- Install, start, confirm status shows "Running".

### Module 7 — Verify It Works (15 min)
Learning objective: Confirm end-to-end behavior from two angles.
- `curl http://<player_ip>:8080/` — see JSON response.
- View extension logs via player web UI.
- (Optional) SSH into player, `cat /tmp/hello-extension.log`.

### Module 8 — Iterate: Change and Redeploy (20 min)
Learning objective: Execute the full change → rebuild → redeploy cycle.
- Modify message string. Stop → rebuild → repackage → upload → install → start.
- This is the workflow teams will run daily. Muscle memory matters.

### Module 9 — The HTML App (30 min)
Learning objective: Build and deploy the HTML app that consumes the extension.
- Clone the HTML app repo. `make prep && make build && make publish`.
- Walk `src/autorun.brs`, `src/index.html`, `src/index.js` — same pattern as
  simple-gaze-detection-html.
- Deploy `sd/` contents to SD card. Insert, boot, watch the UI pull from the extension.
- Discussion: what teams can build in this HTML layer — dashboards, kiosks, anything.

### Module 10 — Production Hardening Overview (15 min)
Learning objective: Know what changes before shipping.
- Extension signing: why, tools, process — conceptual, no hands-on keys.
- Secure mode vs. dev mode: what is disabled, what is required.
- What to never ship (debug logging, hardcoded credentials, unsigned code).
- Pointer to BrightSign signing documentation.

### Cleanup
- Stop and uninstall the extension.
- Restore player dev mode settings if needed.
- Pointer to BrightSign developer portal, extension-template, community.

---

## Repository Layout

```
/
├── CLAUDE.md                          ← this file
├── docs/
│   ├── PRD.md                         ← original PRD (do not delete)
│   └── DESIGN.md                      ← master design doc (create before building)
├── workshop/
│   ├── 00-introduction/
│   │   └── README.md
│   ├── 01-environment-setup/
│   │   └── README.md
│   ├── 02-understand-template/
│   │   └── README.md
│   ├── 03-player-api/
│   │   └── README.md
│   ├── 04-build-java/                 ← first language variant
│   │   ├── README.md
│   │   └── hello-extension/           ← Maven project
│   ├── 04-build-go/                   ← future
│   ├── 04-build-cpp/                  ← future
│   ├── 05-package/
│   │   └── README.md
│   ├── 06-deploy/
│   │   └── README.md
│   ├── 07-verify/
│   │   └── README.md
│   ├── 08-iterate/
│   │   └── README.md
│   ├── 09-html-app/
│   │   └── README.md                  ← points to companion HTML repo
│   ├── 10-production/
│   │   └── README.md
│   └── cleanup/
│       └── README.md
├── facilitator-guide/
│   └── README.md                      ← timing, demo prep, FAQ, common failures
└── Makefile
```

---

## Writing Style Rules for Workshop Content

- **Numbered action steps.** Every participant action is a numbered list item beginning
  with a verb: "1. Open a terminal." "2. Run the following command:"
- **Commands in fenced code blocks** with shell prompt: `$ mvn clean package`.
- **Expected output** shown immediately after every command that produces output.
- **Callout blocks** (blockquote format):
  - `> **Note:** ...` — helpful context that does not block progress.
  - `> **Warning:** ...` — common mistake, destructive action, or known gotcha.
  - `> **Tip:** ...` — optional shortcut or exploration for fast finishers.
- **Module header format:** Duration · Learning Objectives · Prerequisites.
- No filler. No praise. No "In this section we will...". Start with the first action.

---

## Makefile Targets (Minimum, Both Repos)

Extension repo:
```
build        # build the hello-extension JAR/binary
package      # produce the deployable ZIP
test-local   # run locally and curl-verify
clean        # remove build artifacts
help         # list targets (default)
```

HTML app repo (mirrors simple-gaze-detection-html):
```
prep         # npm install
build        # webpack bundle
publish      # copy dist/ + autorun.brs to sd/
clean        # remove build artifacts
help         # list targets (default)
```

---

## What NOT to Do

- Do not make the example extension clever. Simplicity is the feature.
- Do not skip the local smoke test in Module 4. Participants must see the binary work
  before touching the player.
- Do not put language-specific content outside `04-build-<language>/`. Every other
  module must be identical across all language variants.
- Do not reference npu-gaze-extension domain complexity (NPU, camera, gaze) as
  something participants should understand. It is a packaging structure reference only.
- Do not write a full-day workshop. 3.5 hours with breaks. Half day.
- Do not invent a custom HTML app structure. Follow simple-gaze-detection-html exactly
  — same Makefile targets, same file layout, same webpack config shape.

---

## Current Status

- [ ] Module 0: Introduction
- [ ] Module 1: Environment Setup
- [ ] Module 2: Understand Template
- [ ] Module 3: Player API
- [ ] Module 4 (Java): Build Extension + Maven project
- [ ] Module 5: Package
- [ ] Module 6: Deploy
- [ ] Module 7: Verify
- [ ] Module 8: Iterate
- [ ] Module 9: HTML App + companion repo scaffold
- [ ] Module 10: Production
- [ ] Facilitator Guide
- [ ] Makefile (extension repo)
