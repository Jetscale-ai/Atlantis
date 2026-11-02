# Jetscale Atlantis

Custom Atlantis image with AWS CLI for EKS authentication and Google Cloud CLI
for GKE IAP access.

## Why?

The official Atlantis image doesn't include AWS CLI. When Terraform uses the
Kubernetes provider with exec-based authentication (`aws eks get-token`), it
fails with:

```text
executable aws not found
```

This image adds AWS CLI v2 and a pinned Google Cloud CLI to the official
Atlantis base. The Cloud CLI matches the `591.0.0` linux-x86_64 archive used by
[Jetscale-IaC pull request 391](https://github.com/Jetscale-ai/Jetscale-IaC/pull/391).

## CI

- `validate.yml` builds the image and verifies `aws`, `gcloud`,
  `gke-gcloud-auth-plugin`, and `atlantis` on pull requests and pushes to
  `main`.
- `release.yml` publishes after validation succeeds on `main`. A manual run of
  this workflow from `main` performs the same image build and smoke checks before
  publishing.

### Release Versions and Manual Publishing

The repository's image release version is independent of the upstream Atlantis
version pinned by `ATLANTIS_VERSION`. Semantic-release analyzes Conventional
Commit messages: `feat` commits trigger a minor release, `fix` commits trigger a
patch release, and breaking changes (for example, `feat!` or a
`BREAKING CHANGE:` footer) trigger a major release. Chore-only changes do not
create a release, so semantic-release reports `no change` and does not produce
a new version tag.

When a manual `release.yml` run finds no new semantic version, it still builds
and publishes the image with `latest` and `sha-<short-sha>` tags. It does not
overwrite the previous semantic-version image tag. If semantic-release creates
a version during the run, that version tag is published as well. Manual runs
must use the `main` branch.

## Usage

```yaml
# In your Atlantis deployment (Helm values, etc.)
image:
  repository: ghcr.io/jetscale-ai/atlantis
  tag: latest # or pin to a repository release such as v2.0.0
```

## What's Added

- AWS CLI v2 (via pip)
- Python 3 (required for AWS CLI and for `gcloud` on Alpine)
- Google Cloud CLI `591.0.0` (linux-x86_64), with `gke-gcloud-auth-plugin`
- OpenSSH client, procps (`pkill`), util-linux (`setsid`), and coreutils
  (`sha256sum`)

`bq`, `gsutil`, and the glibc bundled Python are not kept. Usage reporting and
component update checks are disabled. The runtime user remains `atlantis`.

## Base Image

- `ghcr.io/runatlantis/atlantis:v0.48.1`

Repository releases are versioned independently from the upstream Atlantis base
image. Updating `ATLANTIS_VERSION` changes the base image used at build time,
but does not change this repository's release numbering.

To build with a different Atlantis version:

```bash
docker build --build-arg ATLANTIS_VERSION=v0.41.0 -t atlantis-custom .
```
