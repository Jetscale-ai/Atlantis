# ==========================================
# Jetscale Atlantis
# Atlantis with AWS CLI for EKS authentication
# and Google Cloud CLI for GKE IAP access
# ==========================================
#
# Base: Official Atlantis image (Alpine). Release builds do not pass
# --platform, so the published image is the runner architecture. The Cloud
# CLI pin below is the linux-x86_64 archive only.
# Added:
#   AWS CLI v2 for `aws eks get-token` (Kubernetes exec auth)
#   Google Cloud CLI for private GKE access (IAP SSH, container API,
#   gke-gcloud-auth-plugin)
#
ARG ATLANTIS_VERSION=v0.48.1 #Upcoming 0.49.0+ will not have terraform binary
FROM ghcr.io/runatlantis/atlantis:${ATLANTIS_VERSION} AS atlantis

USER root

# eMudhra intermediate compromise (2026-10-20): refresh the system trust store
# and distrust emSign ECC Root CA - G3 (the root chaining to the compromised
# intermediates). On the Atlantis base (Alpine 3.24) only ca-certificates-bundle
# 20261020-r0 is fixed so far; ca-certificates is still 20260909-r0, so apply the
# upstream-published Alpine workaround and fail the build if the root remains.
# The guard also fails if the bundle is missing or empty (grep would otherwise
# exit 2 and `!` would pass), and checks the per-cert file in /etc/ssl/certs,
# which Go tooling (atlantis, terraform, providers) reads as well.
# https://emudhra.we-have-a-problem.com/
RUN apk upgrade --no-cache ca-certificates ca-certificates-bundle \
    && sed -i -e 's|^mozilla/emSign_ECC_Root_CA_-_G3.crt|!&|' /etc/ca-certificates.conf \
    && update-ca-certificates 2>/dev/null \
    && rm -f /etc/ssl/certs/ca-certificates.crt.apk-new \
    && test -s /etc/ssl/certs/ca-certificates.crt \
    && ! grep -qF "MIICTjCCAdOgAwIBAgIKPPYHqWhwDtqLhDAKBggqhkjOPQQDAzBrMQswCQYDVQQG" /etc/ssl/certs/ca-certificates.crt \
    && ! test -e /etc/ssl/certs/ca-cert-emSign_ECC_Root_CA_-_G3.pem

# Same release and digest as Jetscale-IaC .atlantis/gke-tunnel.sh. Google does
# not publish a .sha256 sidecar for this archive.
ARG GCLOUD_VERSION=591.0.0
ARG GCLOUD_SHA256=78c570f5fcfe58a9311bd98c06b75530595e3cae6277aad75a676a39e6ee7b63

# The archive's bundled Python is glibc and does not run on Alpine. core
# depends on that component record, so the interpreter tree is deleted rather
# than uninstalled. These settings apply to every user, including when a
# workflow points CLOUDSDK_CONFIG at a temporary directory.
ENV CLOUDSDK_PYTHON=python3 \
    CLOUDSDK_CORE_DISABLE_USAGE_REPORTING=true \
    CLOUDSDK_COMPONENT_MANAGER_DISABLE_UPDATE_CHECK=true \
    CLOUDSDK_CORE_DISABLE_PROMPTS=1

RUN set -eux; \
    case "$(uname -m)" in \
      x86_64) ;; \
      *) echo "Google Cloud CLI ${GCLOUD_VERSION} is pinned for linux-x86_64 (got $(uname -m))." >&2; exit 1 ;; \
    esac; \
    apk add --no-cache \
      python3 \
      py3-pip \
      groff \
      less \
      curl \
      ca-certificates \
      openssh-client \
      procps \
      util-linux \
      coreutils \
    && python3 -c 'import sys; raise SystemExit(0 if (3, 9) <= sys.version_info[:2] <= (3, 14) else 1)' \
    && pip3 install --no-cache-dir --break-system-packages awscli \
    && curl -fsSLo /tmp/google-cloud-cli.tar.gz \
      "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${GCLOUD_VERSION}-linux-x86_64.tar.gz" \
    && echo "${GCLOUD_SHA256}  /tmp/google-cloud-cli.tar.gz" | sha256sum -c - \
    && tar -xzf /tmp/google-cloud-cli.tar.gz -C /opt \
    && rm -f /tmp/google-cloud-cli.tar.gz \
    && rm -rf /opt/google-cloud-sdk/platform/bundledpythonunix \
    && CLOUDSDK_COMPONENT_MANAGER_SNAPSHOT_URL="https://dl.google.com/dl/cloudsdk/channels/rapid/components-v${GCLOUD_VERSION}.json" \
      /opt/google-cloud-sdk/bin/gcloud components install gke-gcloud-auth-plugin --quiet \
    && /opt/google-cloud-sdk/bin/gcloud components remove --quiet bq gsutil \
    && rm -rf \
      /opt/google-cloud-sdk/platform/bundledpythonunix \
      /opt/google-cloud-sdk/platform/gsutil \
      /opt/google-cloud-sdk/platform/bq \
      /root/.config/gcloud \
      /root/.cache/pip \
    && chmod -R a+rX /opt/google-cloud-sdk \
    && ln -sf /opt/google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud \
    && ln -sf /opt/google-cloud-sdk/bin/gke-gcloud-auth-plugin /usr/local/bin/gke-gcloud-auth-plugin \
    && gcloud version \
    && test -x /opt/google-cloud-sdk/bin/gke-gcloud-auth-plugin \
    && gke-gcloud-auth-plugin --version \
    && aws --version

USER atlantis

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["server"]
