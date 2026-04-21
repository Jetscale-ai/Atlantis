# Repository Operations: Jetscale Atlantis

**Status:** Operational Details  
**Scope:** `Jetscale-AI/Atlantis` only

## 1. Verification Oracles

Use these local checks before proposing release-related changes:

```bash
# Build the image locally
docker build --target atlantis -t atlantis-test .

# Verify AWS CLI is present and runnable
docker run --rm --entrypoint aws atlantis-test --version

# Verify the image still exposes Atlantis and the aws binary path
docker run --rm --entrypoint atlantis atlantis-test version
docker run --rm --entrypoint /usr/bin/which atlantis-test aws
```

## 2. CI and Release Expectations

- `validate.yml` is the pre-release gate. It must build the image and verify the
  installed tooling on pull requests and on `main`.
- `release.yml` is publish-only. It must run only after validation succeeds on
  `main` (or via explicit manual dispatch).
- The Dockerfile `ARG ATLANTIS_VERSION` is the image version source of truth.
- Published image tags are:
  - `latest`
  - `<atlantis-version>`
  - `sha-<short-sha>`

## 3. Key File Locations

| Concern | Location |
| :------ | :------- |
| Image build definition | `Dockerfile` |
| Validation workflow | `.github/workflows/validate.yml` |
| Release workflow | `.github/workflows/release.yml` |
| Semantic release config | `.semrel.yaml` |
| Operator docs | `README.md` |
| Roadmap / follow-up work | `ROADMAP.md` |

## 4. Save and Handoff

- Humans own commits, pushes, tags, and ratification.
- When work is ready, provide:
  - the files changed
  - the verification commands run
  - any follow-up needed before the repo can be considered ratified
