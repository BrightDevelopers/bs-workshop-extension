FROM debian:bookworm-slim

LABEL org.opencontainers.image.source=https://github.com/BrightDevelopers/bs-workshop-extension
LABEL org.opencontainers.image.description="BrightSign Extension Workshop — development environment"
LABEL org.opencontainers.image.licenses=Apache-2.0

# System packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    direnv \
    ffmpeg \
    file \
    git \
    gosu \
    imagemagick \
    jq \
    keychain \
    libpcap-dev \
    libusb-1.0-0 \
    libusb-1.0-0-dev \
    lvm2 \
    maven \
    mg \
    openssh-client \
    openjdk-17-jdk \
    python3 \
    python3-pip \
    qpdf \
    rsync \
    squashfs-tools \
    stow \
    sudo \
    tmux \
    tree \
    udev \
    unzip \
    usbutils \
    wget \
<<<<<<< Updated upstream
    xxd \
    zip \
    zoxide \
    zstd \
=======
    zip \
>>>>>>> Stashed changes
    && rm -rf /var/lib/apt/lists/*

# GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*

# Node.js 20.x (LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# npm globals
RUN npm install -g typescript ts-node pnpm eslint prettier webpack webpack-cli

# Go
ARG GO_VERSION=1.25.0
ARG TARGETARCH=amd64
RUN wget -q https://go.dev/dl/go${GO_VERSION}.linux-${TARGETARCH}.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-${TARGETARCH}.tar.gz \
    && rm go${GO_VERSION}.linux-${TARGETARCH}.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/go"
ENV PATH="${GOPATH}/bin:${PATH}"

# Go tools
RUN go install golang.org/x/tools/cmd/goimports@latest \
    && go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest \
    && go install github.com/go-delve/delve/cmd/dlv@latest \
    && go clean -cache

# TinyGo
ARG TINYGO_VERSION=0.40.1
RUN wget -q https://github.com/tinygo-org/tinygo/releases/download/v${TINYGO_VERSION}/tinygo${TINYGO_VERSION}.linux-${TARGETARCH}.deb \
    && dpkg -i tinygo${TINYGO_VERSION}.linux-${TARGETARCH}.deb \
    && rm tinygo${TINYGO_VERSION}.linux-${TARGETARCH}.deb

# uv (Python package manager)
RUN UV_INSTALL_DIR=/usr/local/bin curl -LsSf https://astral.sh/uv/install.sh | sh

# workshop user with UID/GID 1000 (remapped at runtime by entrypoint to match host user)
RUN (groupadd -g 1000 workshop 2>/dev/null || groupmod -n workshop $(getent group 1000 | cut -d: -f1)) && \
    (useradd -m -u 1000 -g 1000 -s /bin/bash workshop 2>/dev/null || \
     usermod -l workshop -d /home/workshop -m $(getent passwd 1000 | cut -d: -f1) 2>/dev/null || true) && \
    echo 'workshop ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Maven pre-warm: pull shade plugin so first `mvn clean package` does not need internet
RUN mkdir -p /tmp/mvn-warmup/src/main/java/warmup && \
    echo '<project><modelVersion>4.0.0</modelVersion><groupId>warmup</groupId><artifactId>warmup</artifactId><version>1.0</version><properties><maven.compiler.source>11</maven.compiler.source><maven.compiler.target>11</maven.compiler.target></properties><build><plugins><plugin><groupId>org.apache.maven.plugins</groupId><artifactId>maven-shade-plugin</artifactId><version>3.5.1</version><executions><execution><phase>package</phase><goals><goal>shade</goal></goals></execution></executions></plugin></plugins></build></project>' \
        > /tmp/mvn-warmup/pom.xml && \
    echo 'package warmup; public class Main { public static void main(String[] a){} }' \
        > /tmp/mvn-warmup/src/main/java/warmup/Main.java && \
    mvn -f /tmp/mvn-warmup/pom.xml clean package -q 2>/dev/null || true && \
    rm -rf /tmp/mvn-warmup

WORKDIR /workspace

# Verify tools present
RUN java -version && mvn -version && node --version && npm --version \
    && go version && tinygo version && mksquashfs -version 2>&1 | head -1 \
    && gh --version && uv --version

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/bash"]
