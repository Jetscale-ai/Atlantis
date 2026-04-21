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
- `go-semantic-release` owns this repository's version. Its output drives the
  git tag, the GitHub release, and the published image tag.
- `ARG ATLANTIS_VERSION` in the Dockerfile is an independent pin of the
  upstream Atlantis base image. It is recorded as the OCI
  `org.opencontainers.image.base.name` label on the published image but is
  never used as an image or git tag.
- Published image tags are:
  - `latest`
  - `<release-version>` (e.g. `v1.0.2`, from semantic-release)
  - `sha-<short-sha>`
- Git tags and GitHub releases are pushed by semantic-release only.
  `release.yml` does not push its own git tags.

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
