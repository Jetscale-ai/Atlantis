# ==========================================
# JetScale Atlantis
# Atlantis with AWS CLI for EKS authentication
# ==========================================
#
# Base: Official Atlantis image
# Added: AWS CLI v2 for `aws eks get-token` (Kubernetes exec auth)
#
FROM ghcr.io/runatlantis/atlantis:latest AS atlantis

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
