# Stage 1: Build Python from source
FROM --platform=$BUILDPLATFORM ubuntu:latest as build

# Arguments for cross-building
ARG TARGETPLATFORM
ARG TARGETARCH

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ='America/New_York'

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    curl \
    libssl-dev \
    zlib1g-dev \
    libncurses-dev \
    libreadline-dev \
    libgdbm-dev \
    libbz2-dev \
    libsqlite3-dev \
    libffi-dev \
    liblzma-dev \
    tk-dev \
    uuid-dev \
    tree \
    && rm -rf /var/lib/apt/lists/*

# Copy the build script into the image
COPY build_python.sh /build_python.sh

# Run the script to build Python versions
RUN /build_python.sh

# Update PATH to include all installed Python versions
ENV PATH="/usr/local/bin:${PATH}"

# Verify installations
RUN python3.9 --version && python3.10 --version && python3.11 --version && python3.12 --version

CMD ["bash"]