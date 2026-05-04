FROM debian:bookworm-slim

LABEL org.opencontainers.image.source=https://github.com/BrightDevelopers/bs-workshop-extension
LABEL org.opencontainers.image.description="BrightSign Extension Workshop — development environment"
LABEL org.opencontainers.image.licenses=Apache-2.0

# System packages: base tools + squashfs-tools (required for Module 5 packaging)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    gosu \
    jq \
    lvm2 \
    maven \
    openssh-client \
    openjdk-17-jdk \
    python3 \
    squashfs-tools \
    sudo \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Node.js 20.x (LTS — used for webpack build toolchain only, not deployed to player)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Go 1.21 (required for future Go extension module)
ARG GO_VERSION=1.21.13
ARG TARGETARCH=amd64
RUN wget -q https://go.dev/dl/go${GO_VERSION}.linux-${TARGETARCH}.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-${TARGETARCH}.tar.gz \
    && rm go${GO_VERSION}.linux-${TARGETARCH}.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/go"
ENV PATH="${GOPATH}/bin:${PATH}"

# workshop user with UID/GID 1000 (remapped at runtime by entrypoint to match host user)
RUN (groupadd -g 1000 workshop 2>/dev/null || groupmod -n workshop $(getent group 1000 | cut -d: -f1)) && \
    (useradd -m -u 1000 -g 1000 -s /bin/bash workshop 2>/dev/null || \
     usermod -l workshop -d /home/workshop -m $(getent passwd 1000 | cut -d: -f1) 2>/dev/null || true) && \
    echo 'workshop ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Maven local repo pre-warm: pull the shade plugin and java 11 settings so
# the first `mvn clean package` inside the workshop does not require internet.
RUN mkdir -p /tmp/mvn-warmup/src/main/java/warmup && \
    echo '<project><modelVersion>4.0.0</modelVersion><groupId>warmup</groupId><artifactId>warmup</artifactId><version>1.0</version><properties><maven.compiler.source>11</maven.compiler.source><maven.compiler.target>11</maven.compiler.target></properties><build><plugins><plugin><groupId>org.apache.maven.plugins</groupId><artifactId>maven-shade-plugin</artifactId><version>3.5.1</version><executions><execution><phase>package</phase><goals><goal>shade</goal></goals></execution></executions></plugin></plugins></build></project>' \
        > /tmp/mvn-warmup/pom.xml && \
    echo 'package warmup; public class Main { public static void main(String[] a){} }' \
        > /tmp/mvn-warmup/src/main/java/warmup/Main.java && \
    mvn -f /tmp/mvn-warmup/pom.xml clean package -q 2>/dev/null || true && \
    rm -rf /tmp/mvn-warmup

WORKDIR /workspace

# Verify tools
RUN java -version && mvn -version && node --version && npm --version && go version && mksquashfs -version 2>&1 | head -1

# Entrypoint remaps UID/GID to match the host user at runtime, then drops to workshop user
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/bash"]
