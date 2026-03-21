FROM debian:bookworm-slim

LABEL org.opencontainers.image.source=https://github.com/BrightSign-Playground/bs-extension-workshop
LABEL org.opencontainers.image.description="BrightSign Extension Workshop — development environment"
LABEL org.opencontainers.image.licenses=Apache-2.0

# System packages: base tools + squashfs-tools (required for Module 5 packaging)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    jq \
    lvm2 \
    maven \
    openssh-client \
    openjdk-11-jdk \
    python3 \
    squashfs-tools \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Node.js 14.x (required for HTML app module — matches BrightSign player runtime)
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash - \
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

# Maven local repo pre-warm: pull the shade plugin and java 11 settings so
# the first `mvn clean package` inside the workshop does not require internet.
# This runs a dummy build that forces download of the shade plugin.
RUN mkdir -p /tmp/mvn-warmup/src/main/java/warmup && \
    echo '<project><modelVersion>4.0.0</modelVersion><groupId>warmup</groupId><artifactId>warmup</artifactId><version>1.0</version><properties><maven.compiler.source>11</maven.compiler.source><maven.compiler.target>11</maven.compiler.target></properties><build><plugins><plugin><groupId>org.apache.maven.plugins</groupId><artifactId>maven-shade-plugin</artifactId><version>3.5.1</version><executions><execution><phase>package</phase><goals><goal>shade</goal></goals></execution></executions></plugin></plugins></build></project>' \
        > /tmp/mvn-warmup/pom.xml && \
    echo 'package warmup; public class Main { public static void main(String[] a){} }' \
        > /tmp/mvn-warmup/src/main/java/warmup/Main.java && \
    mvn -f /tmp/mvn-warmup/pom.xml clean package -q 2>/dev/null || true && \
    rm -rf /tmp/mvn-warmup

# Non-root user for workshop work
RUN useradd -m -s /bin/bash workshop
USER workshop
WORKDIR /workspace

# Verify tools
RUN java -version && mvn -version && node --version && npm --version && go version && mksquashfs -version 2>&1 | head -1

CMD ["/bin/bash"]
