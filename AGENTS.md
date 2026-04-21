# Repository Constitution: Jetscale Atlantis

**Status:** Draft (Unratified)  
**Blueprint:** `library` (`.agents/codex/blueprints/library.md`)  
**Authority:**
[Supreme Constitution](https://github.com/Jetscale-AI/Governance/blob/main/AGENTS.md)  
**Version:** 0.2.0  
**Risk Level:** Medium  
**Owner:** Jetscale Platform Team  
**Deploy Target:** `ghcr.io/jetscale-ai/atlantis`

## 0. Situational Awareness (Required Context)

- **Universal Red Lines (excerpt)**:
  - **No Direct Commits:** Agents must never execute commits, pushes, or tags.
  - **No Secrets:** Agents must never output, log, or persist secrets/keys.
  - **No Impersonation:** Agents must clearly identify work as
    machine-generated.
- **Default Failure Mode:** If instructions conflict, evidence is ambiguous, or
  blast radius is unknown: **STOP -> AUDIT -> ASK**.
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
- **Load Local Operations (required):** Read `.agents/AGENTS.md` before giving
  operational instructions (commands, verification steps, release flow). If it
  is missing, treat this repo as **Advisory Mode**.

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
# Local operational law
sed -n '1,200p' .agents/AGENTS.md
```

```bash
# Supreme Constitution
gh api repos/Jetscale-AI/Governance/contents/AGENTS.md --jq .content | base64 -d

# Codex artifacts ratified below
gh api repos/Jetscale-AI/Governance/contents/.agents/codex/protocols/bootstrap.md --jq .content | base64 -d
gh api repos/Jetscale-AI/Governance/contents/.agents/codex/protocols/ratification.md --jq .content | base64 -d
gh api repos/Jetscale-AI/Governance/contents/.agents/codex/protocols/ci-monitoring.md --jq .content | base64 -d
gh api repos/Jetscale-AI/Governance/contents/.agents/codex/blueprints/library.md --jq .content | base64 -d
```

## 1. Preamble & Delegation

This repository does not invent governance. All agentic operations herein are
governed by the Jetscale Supreme Constitution.

Until this constitution is ratified by a human commit, agents must treat this
repository as **Advisory Mode** (read-only) per
`.agents/codex/protocols/ratification.md`.

## 2. Codex Ratification (The Law)

This repository adopts the following Codex artifacts from
`Jetscale-AI/Governance@main`:

### Blueprints

- [x] [`.agents/codex/blueprints/library.md`](https://github.com/Jetscale-AI/Governance/blob/main/.agents/codex/blueprints/library.md)

### Protocols

- [x] [`.agents/codex/protocols/bootstrap.md`](https://github.com/Jetscale-AI/Governance/blob/main/.agents/codex/protocols/bootstrap.md)
- [x] [`.agents/codex/protocols/ratification.md`](https://github.com/Jetscale-AI/Governance/blob/main/.agents/codex/protocols/ratification.md)
- [x] [`.agents/codex/protocols/ci-monitoring.md`](https://github.com/Jetscale-AI/Governance/blob/main/.agents/codex/protocols/ci-monitoring.md)

## 3. Local Constraints

- **Single Image Target:** This repo produces one image (`atlantis`) extending
  the upstream Atlantis base with AWS CLI for EKS authentication.
- **Version Discipline:** The Dockerfile pin in `ARG ATLANTIS_VERSION` is the
  release source of truth. Published image tags must remain aligned to that
  upstream Atlantis version.
- **Minimalism:** Add only what is required for Atlantis + AWS CLI execution.
  Avoid shipping extra tooling that expands image size or attack surface.
- **Release Safety:** Publishing must happen only after validation has built the
  image and exercised the installed AWS CLI.
- **Secrets Boundary:** This repo may reference GitHub Actions secrets, but it
  must never hardcode credentials or emit secret material in logs.

## 4. Local Operational Details

See [**`.agents/AGENTS.md`**](./.agents/AGENTS.md) for repository-specific
verification commands, workflow expectations, and key file locations.
