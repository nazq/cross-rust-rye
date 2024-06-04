#!/bin/bash

# Define the images
images=(
  "nazq/multi-arch-py-musllinux:latest"
  "nazq/multi-arch-py-manylinux:latest"
)

# Function to get supported platforms from the Docker manifest
get_platforms() {
  local image=$1
  docker buildx imagetools inspect $image --format '{{range .Manifest.Manifests}}{{.Platform.OS}}/{{.Platform.Architecture}} {{end}}'
}

# Function to check Python version, architecture, and glibc/musl compatibility
check_python_version_and_arch() {
  local image=$1
  local platform=$2

  echo "Checking $image on $platform..."
  docker run --rm --platform $platform $image /bin/sh -c '
    echo "Platform: $(uname -m)"
    for version in 3.9 3.10 3.11 3.12; do
      python${version} --version 2>/dev/null && break
    done
    if ldd --version 2>&1 | grep -iq "musl"; then
      echo "C library: musl"
    elif ldd --version 2>&1 | grep -iq "glibc"; then
      echo "C library: glibc"
    else
      echo "C library: Unknown"
    fi
    python${version} -m venv venv
    . venv/bin/activate
    pip install pyfusion==1.1.0.dev3 --no-compile
  '
}

# Loop over the images and their supported platforms
for image in "${images[@]}"; do
  platforms=$(get_platforms $image)
  for platform in $platforms; do
    if [[ "$platform" == "unknown/unknown" ]]; then
      echo "Skipping unknown platform for $image"
      continue
    fi
    check_python_version_and_arch "$image" "$platform"
  done
done
