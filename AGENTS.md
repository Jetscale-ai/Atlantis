# Repository Constitution: Atlantis

**Status:** Draft (Unratified)  
**Authority:**
[Supreme Constitution](https://github.com/Jetscale-ai/Governance/blob/main/AGENTS.md)  
**Version:** 0.1.0  
**Risk Level:** Medium  
**Owner:** JetScale Platform Team  
**Deploy Target:** GHCR — custom Atlantis image with AWS CLI for EKS authentication

## 0. Bootstrapping (Required Context)

- **Universal Red Lines (excerpt)**:
  - **No Direct Commits:** Agents must never execute commits, pushes, or tags.
  - **No Secrets:** Agents must never output, log, or persist secrets/keys.
  - **No Impersonation:** Agents must clearly identify work as
    machine-generated.
- **Default Failure Mode:** If instructions conflict, evidence is ambiguous, or
  blast radius is unknown: **STOP → AUDIT → ASK**.
- **Eudaimonia Framework (12 invariants):** Legitimacy, Prudence, Symbiosis,
  Clarity, Traceability, Minimalism, Testability, Sovereignty, Temporality,
  Proportionality, Interoperability, Reflexivity.
  - `audit_log:` entries cite **only the invariants that applied**; they are not
    the full framework definition.
- **Session start rule (mandatory):** On the **first user message** in a new
  session (and on the first time you read this file), **bootstrap immediately**
  before answering any substantive question. Do not ask permission; this is a
  safety preflight.
- **Tooling preflight (mandatory):** Before bootstrapping canonical law, verify
  required tooling exists (including `gh` auth). If any check fails, **STOP**
  and ask a human to install/authenticate tooling.
- **Load Canonical Law (GitHub `main`)**: Load the Supreme Constitution and the
  Codex artifacts ratified below.
  - If any retrieval fails (permission/404/network), **do not proceed** beyond
    reporting the failure and asking a human to ratify/publish the missing law.
    Treat this repo as **Advisory Mode**.
  - Do not guess definitions from names or templates, and do not run additional
    commands until canonical law is retrievable.

```bash
# Tooling preflight (mandatory). STOP if any check fails.
require_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "Missing required tool: $1" >&2; exit 1; }; }

# Canonical-law bootstrap tooling (private Governance repo)
require_cmd gh
gh auth status -h github.com >/dev/null 2>&1 || { echo "gh not authenticated for github.com (run: gh auth login)" >&2; exit 1; }
require_cmd base64
require_cmd sed

# Repo toolchain (Docker image build)
require_cmd docker
```

```bash
# Supreme Constitution
gh api repos/Jetscale-ai/Governance/contents/AGENTS.md --jq .content | base64 -d

# Codex (repeat for each artifact ratified below)
gh api repos/Jetscale-ai/Governance/contents/codex/protocols/bootstrap.md --jq .content | base64 -d
gh api repos/Jetscale-ai/Governance/contents/codex/protocols/ratification.md --jq .content | base64 -d
gh api repos/Jetscale-ai/Governance/contents/codex/blueprints/library.md --jq .content | base64 -d
```

## 1. Preamble & Delegation

This repository does not invent governance. All agentic operations herein are
governed by the JetScale Supreme Constitution.

Until this constitution is ratified by a human commit, agents must treat this
repository as **Advisory Mode** (read-only) per
`codex/protocols/ratification.md`.

## 2. Codex Ratification (The Law)

This repository adopts the following Codex artifacts from
`Jetscale-ai/Governance@main`:

### Blueprints

- [x] [`codex/blueprints/library.md`](https://github.com/Jetscale-ai/Governance/blob/main/codex/blueprints/library.md)

### Protocols

- [x] [`codex/protocols/bootstrap.md`](https://github.com/Jetscale-ai/Governance/blob/main/codex/protocols/bootstrap.md)
- [x] [`codex/protocols/ratification.md`](https://github.com/Jetscale-ai/Governance/blob/main/codex/protocols/ratification.md)

## 3. Local Constraints (Docker Image)

- **Single Image Target:** This repo produces one image (`atlantis`) extending
  the official Atlantis base with AWS CLI.
- **Upstream Tracking:** Base image version is pinned via `ARG ATLANTIS_VERSION`
  in the Dockerfile (currently `v0.42.0`). Update this value to upgrade.
- **Minimalism:** Add only what's necessary for EKS authentication. Avoid
  bloating the image with unnecessary tools.
- **Release Flow:** Image tags follow the upstream Atlantis version. Tags:
  `:latest`, `:<atlantis-version>`, `:sha-<short>`.

## 4. Local Operational Details

### Build & Test

```bash
# Build locally
docker build --target atlantis -t atlantis-test .

# Verify AWS CLI works
docker run --rm atlantis-test aws --version
```

### Release

Releases are automated via GitHub Actions on every push to `main`. The workflow:

1. Extracts `ATLANTIS_VERSION` from the Dockerfile
2. Builds and pushes to `ghcr.io/jetscale-ai/atlantis` with tags:
   - `:<atlantis-version>` (e.g., `v0.42.0`)
   - `:latest`
   - `:sha-<short>` (commit SHA)

### Consuming the Image

Update Atlantis Helm deployment in `iac/clusters/tools`:

```yaml
image:
  repository: ghcr.io/jetscale-ai/atlantis
  tag: latest  # or pin to specific version
```
