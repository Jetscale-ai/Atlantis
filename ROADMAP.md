# Atlantis Strategic Horizon

**Objective:** Provide a customized Atlantis image with AWS CLI for EKS authentication.

## Phase 1: Ignition (Initialization)
> *Goal: Establish the base image.*

- [x] **The Blueprint:** Create `Dockerfile` extending official Atlantis with AWS CLI.
- [x] **The Mechanics:** Install AWS CLI v2 via pip for `aws eks get-token` support.
- [x] **The Spark:** Implement the `release.yml` workflow to publish to GHCR.

## Phase 2: Calibration (Hardening)
> *Goal: Security and Performance.*

- [ ] **Security Scan:** Ensure zero critical CVEs in the image layers.
- [ ] **Version Pinning:** Consider pinning Atlantis base image to specific version.
- [ ] **Size Optimization:** Evaluate AWS CLI v2 binary installer vs pip install.

## Phase 3: Integration (Deployment)
> *Goal: Deploy to Tools cluster.*

- [ ] **Helm Values:** Update Atlantis Helm deployment to use `ghcr.io/jetscale-ai/atlantis`.
- [ ] **Validation:** Verify `clusters/tools` Terraform plan succeeds with new image.
- [ ] **Documentation:** Update IaC runbooks with new image reference.
