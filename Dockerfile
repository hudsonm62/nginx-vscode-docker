# syntax = docker/dockerfile:1.2

# this stage is mostly the same from https://github.com/gitpod-io/openvscode-server-releases
FROM debian:bookworm-slim AS download

LABEL org.opencontainers.image.title="NGINX VSCode Server" \
      org.opencontainers.image.description="Web VSCode Server proxied via NGINX." \
      org.opencontainers.image.source="https://github.com/hudsonm62/nginx-vscode-docker" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.vendor="Hudson McNamara" \
      org.opencontainers.image.licenses="MIT"

RUN rm -f /etc/apt/apt.conf.d/docker-clean

# Update and install packages
RUN --mount=type=cache,target=/var/cache/apt1 \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates wget \
    && rm -rf /var/lib/apt/lists/*

ARG OPENVSCODE_SERVER_ROOT="/home/.openvscode-server"

WORKDIR /home/

# you can use your own fork or specific release version
ARG RELEASE_TAG="openvscode-server-v1.85.1"
ARG RELEASE_ORG="gitpod-io" 

# Downloading the VSC Server release and extracting the release archive
RUN if [ -z "${RELEASE_TAG}" ]; then \
        echo "The RELEASE_TAG build arg must be set." >&2 && \
        exit 1; \
    fi && \
    arch=$(uname -m) && \
    if [ "${arch}" = "x86_64" ]; then \
        arch="x64"; \
    elif [ "${arch}" = "aarch64" ]; then \
        arch="arm64"; \
    elif [ "${arch}" = "armv7l" ]; then \
        arch="armhf"; \
    fi && \
    wget --progress=dot:giga https://github.com/${RELEASE_ORG}/openvscode-server/releases/download/${RELEASE_TAG}/${RELEASE_TAG}-linux-${arch}.tar.gz && \
    tar -xzf ${RELEASE_TAG}-linux-${arch}.tar.gz && \
    mv -f ${RELEASE_TAG}-linux-${arch} ${OPENVSCODE_SERVER_ROOT} && \
    cp ${OPENVSCODE_SERVER_ROOT}/bin/remote-cli/openvscode-server ${OPENVSCODE_SERVER_ROOT}/bin/remote-cli/code && \
    rm -f ${RELEASE_TAG}-linux-${arch}.tar.gz

FROM nginxinc/nginx-unprivileged:mainline-bookworm AS nginx

ARG OPENVSCODE_SERVER_ROOT="/home/.openvscode-server"
ARG USERNAME=openvscode-server
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# copy the default config from the repo in case one isn't mounted
COPY nginx.default.conf /etc/nginx/conf.d/default.conf

# Update image and install necessary packages
USER root
RUN rm -f /etc/apt/apt.conf.d/docker-clean
RUN --mount=type=cache,target=/var/cache/apt2 \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends \
    git \
    sudo \
    libatomic1 \
    && rm -rf /var/lib/apt/lists/*

# Setup Visual Studio Code Server
COPY --from=download ${OPENVSCODE_SERVER_ROOT} ${OPENVSCODE_SERVER_ROOT}

# Creating the user and usergroup
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USERNAME -m -s /bin/bash $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

RUN chmod g+rw /home && \
    mkdir -p /home/workspace && \
    chown -R $USERNAME:$USERNAME /home/workspace && \
    chown -R $USERNAME:$USERNAME ${OPENVSCODE_SERVER_ROOT}

USER $USERNAME
WORKDIR /home/workspace/

# Set environment variables
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    HOME=/home/workspace \
    EDITOR=code \
    VISUAL=code \
    GIT_EDITOR="code --wait" \
    OPENVSCODE_SERVER_ROOT=${OPENVSCODE_SERVER_ROOT}

EXPOSE 3000 443

COPY --chown=$USERNAME:$USERNAME start.sh /start.sh

ENTRYPOINT ["/start.sh"]
