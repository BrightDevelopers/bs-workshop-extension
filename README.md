# BrightSign Extension Workshop

A hands-on workshop that takes development teams from a blank workstation to a working
BrightSign extension running on a live player — in roughly half a day.

This workshop covers **basic extension development**: building, packaging, deploying, and
iterating on a BrightSign extension using the standard extension template. It does not
cover BrightSign Model Package (BMP) development for the NPU — that is a more advanced
topic requiring separate tooling and is out of scope here.

> **Note:** Compiling BrightSign AI/ML models for the NPU requires an **x86 host machine**.
> The model compilation tools do not run on ARM-based systems — including Apple Silicon
> MacBooks (M1/M2/M3) and ARM Linux machines — even inside a container. If your work
> involves NPU model compilation, you will need a native x86 Linux machine for that step.
> Windows is not supported.

**[Start here → Module 0: Introduction](https://github.com/BrightDevelopers/bs-workshop-extension/blob/fixit/workshop/00-introduction/README.md)**

---

## Companion Repos

| Repo | Purpose |
|---|---|
| [bs-extension-workshop-html-app](https://github.com/BrightSign-Playground/bs-extension-workshop-html-app) | HTML app deployed in Module 9 |
| [extension-template](https://github.com/brightsign/extension-template) | The packaging scaffold every extension uses |
| [brightsign-npu-gaze-extension](https://github.com/brightsign/brightsign-npu-gaze-extension) | Production example of a real extension |

---

## Running the Workshop

If you are a BrightSign facilitator, see the [Facilitator Guide](facilitator-guide/README.md)
for pre-workshop setup, a timing table, common failure modes and fixes, and suggestions
for fast finishers.

---

## License

Apache 2.0 — see [LICENSE](LICENSE).
