<!-- instructor: this is a conceptual module — no hands-on keys or signing tools needed. Walk through the checklist and explain each item. -->

# Module 10: Production Hardening

**Duration:** 15 minutes

**Learning Objectives:**
- Know the differences between dev mode and production mode
- Understand the extension signing process conceptually
- Know what must change before a production deployment

**Prerequisites:** Module 9 complete.

---

## 10.1 Dev Mode vs. Production Mode

| Setting | Development | Production |
|---|---|---|
| Local Extensions | Enabled | Disabled |
| Unsigned extensions | Allowed | Rejected |
| Insecure Content Loading | Enabled | Disabled |
| Remote Debugging | Enabled | Disabled |
| SSH | Enabled | Disabled |
| Extension Signing | Not required | Required |

> **Warning:** All extensions deployed in this workshop use dev mode settings. Never ship a player with these settings to a real installation.

---

## 10.2 Extension Signing Overview

Signing is handled outside the normal build process. No hands-on steps are required here — understand the flow conceptually before you need it.

1. BrightSign signs extensions with a private key.
2. Players in production mode verify the signature before installing — unsigned ZIPs are rejected at install time.
3. The signing workflow:
   1. Build your extension ZIP as normal (same `mvn package` + `zip` steps from Module 5).
   2. Submit the ZIP to the BrightSign signing portal, or use your own certificate if your organization is authorized.
   3. Receive a signed ZIP back.
   4. Deploy the signed ZIP to production players using the same install API from Module 6.
4. Certificate management rules:
   - Private keys are never stored in version control.
   - Use environment variables in CI/CD pipelines for key paths.
   - Rotate certificates per BrightSign security guidelines.

> **Note:** The signing portal URL and certificate authorization process are covered in BrightSign's internal developer documentation. Ask your BrightSign contact for access if you do not have it.

---

## 10.3 Production Deployment Checklist

Run through this checklist before deploying any extension to a production player.

- [ ] No hardcoded credentials in extension code
- [ ] Debug logging disabled or removed
- [ ] All external HTTP calls use HTTPS
- [ ] Extension ZIP signed with valid BrightSign certificate
- [ ] Tested on a player in secure/production mode before rollout
- [ ] File I/O uses only `/tmp` and the extension's own directory
- [ ] Extension handles shutdown signal gracefully (no zombie processes)
- [ ] ZIP size under 100 MB

> **Tip:** Add this checklist as a pull request template in your extension repository so it runs on every release.

---

## 10.4 Where to Go Next

- [BrightSign Developer Documentation](https://brightsign.atlassian.net/wiki/spaces/DOC/overview) — official reference for the player API, manifest fields, and signing
- [extension-template](https://github.com/brightsign/extension-template) — the starter repo used in this workshop; keep it as your baseline for new extensions
- [brightsign-npu-gaze-extension](https://github.com/brightsign/brightsign-npu-gaze-extension) — a more complex real-world example using hardware inference and an HTML frontend
- BrightSign Developer Community — ask your facilitator for the current forum or Slack channel link
