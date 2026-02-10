# JetScale Atlantis

Custom Atlantis image with AWS CLI for EKS authentication.

## Why?

The official Atlantis image doesn't include AWS CLI. When Terraform uses the
Kubernetes provider with exec-based authentication (`aws eks get-token`), it
fails with:

```
executable aws not found
```

This image adds AWS CLI v2 to the official Atlantis base.

## Usage

```yaml
# In your Atlantis deployment (Helm values, etc.)
image:
  repository: ghcr.io/jetscale-ai/atlantis
  tag: latest
```

## What's Added

- AWS CLI v2 (via pip)
- Python 3 (required for AWS CLI)

## Base Image

- `ghcr.io/runatlantis/atlantis:latest`
