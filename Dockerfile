# ==========================================
# Jetscale Atlantis
# Atlantis with AWS CLI for EKS authentication
# ==========================================
#
# Base: Official Atlantis image
# Added: AWS CLI v2 for `aws eks get-token` (Kubernetes exec auth)
#
ARG ATLANTIS_VERSION=v0.42.0
FROM ghcr.io/runatlantis/atlantis:${ATLANTIS_VERSION} AS atlantis

USER root

# Install AWS CLI v2
RUN apk add --no-cache \
    python3 \
    py3-pip \
    groff \
    less \
    && pip3 install --no-cache-dir --break-system-packages awscli \
    && aws --version

# Verify aws cli works
RUN aws --version && which aws

USER atlantis

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["server"]
