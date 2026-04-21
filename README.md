# Jetscale Atlantis

Custom Atlantis image with AWS CLI for EKS authentication.

## Why?

The official Atlantis image doesn't include AWS CLI. When Terraform uses the
Kubernetes provider with exec-based authentication (`aws eks get-token`), it
fails with:

```text
executable aws not found
```

This image adds AWS CLI v2 to the official Atlantis base.

## CI

- `validate.yml` builds the image and verifies both `aws` and `atlantis`
  commands.
- `release.yml` publishes only after validation succeeds on `main`.

## Usage

```yaml
# In your Atlantis deployment (Helm values, etc.)
image:
  repository: ghcr.io/jetscale-ai/atlantis
  tag: latest # or pin to a repo release like 0.1.0
```

## What's Added

- AWS CLI v2 (via pip)
- Python 3 (required for AWS CLI)

## Base Image

- `ghcr.io/runatlantis/atlantis:v0.42.0`

Repository releases are versioned independently from the upstream Atlantis base
image. Updating `ATLANTIS_VERSION` changes the base image used at build time,
but does not change this repository's release numbering.

To build with a different Atlantis version:

```bash
docker build --build-arg ATLANTIS_VERSION=v0.41.0 -t atlantis-custom .
```
