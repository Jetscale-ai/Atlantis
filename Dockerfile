# ==========================================
# Jetscale Atlantis
# Atlantis with AWS CLI for EKS authentication
# ==========================================
#
# Base: Official Atlantis image
# Added: AWS CLI v2 for `aws eks get-token` (Kubernetes exec auth)
#
ARG ATLANTIS_VERSION=v0.48.1 #Upcoming 0.49.0+ will not have terraform binary
FROM ghcr.io/runatlantis/atlantis:${ATLANTIS_VERSION} AS atlantis

USER root

# eMudhra intermediate compromise (2026-10-20): refresh the system trust store
# and distrust emSign ECC Root CA - G3 (the root chaining to the compromised
# intermediates). On the Atlantis base (Alpine 3.24) only ca-certificates-bundle
# 20261020-r0 is fixed so far; ca-certificates is still 20260909-r0, so apply the
# upstream-published Alpine workaround and fail the build if the root remains.
# https://emudhra.we-have-a-problem.com/
RUN apk upgrade --no-cache ca-certificates ca-certificates-bundle \
    && sed -i -e 's|^mozilla/emSign_ECC_Root_CA_-_G3.crt|!&|' /etc/ca-certificates.conf \
    && update-ca-certificates 2>/dev/null \
    && rm -f /etc/ssl/certs/ca-certificates.crt.apk-new \
    && ! grep -qF "MIICTjCCAdOgAwIBAgIKPPYHqWhwDtqLhDAKBggqhkjOPQQDAzBrMQswCQYDVQQG" /etc/ssl/certs/ca-certificates.crt

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
