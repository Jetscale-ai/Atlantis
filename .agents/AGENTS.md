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
- `release.yml` runs only after validation succeeds on `main`, or by explicit
  manual dispatch from `main`. Manual dispatch builds the image and verifies
  Atlantis and AWS CLI before publishing.
- `go-semantic-release` owns this repository's version. Its output drives the
  git tag, the GitHub release, and the published image version tag. Conventional
  `feat` commits trigger minor releases, `fix` commits trigger patch releases,
  and breaking changes trigger major releases. Chore-only changes produce no
  new release; semantic-release reports `no change`.
- A manual run still publishes `latest` and `sha-<short-sha>` when there is no
  new semantic release. In that case it uses the latest existing Git release
  version for the OCI version label and does not overwrite the existing
  semantic-version image tag. When semantic-release creates a new version, the
  run also publishes that version tag.
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
