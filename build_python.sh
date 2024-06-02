#!/bin/sh

build_python_version() {
  py_ver=$1
  py_major_minor=$(echo $py_ver | awk -F. '{print $1 "." $2}')
  echo "Full py version $py_ver, Release ${py_major_minor}"
  py_dir=Python-${py_ver}
  py_archive="${py_dir}.tgz"
  download_url="https://www.python.org/ftp/python/${py_ver}/${py_archive}"

  # Download, extract, build, and verify
  wget $download_url
  tar xzf ${py_archive}
  cd ${py_dir} && \
    ./configure --enable-optimizations && \
    make -j $(nproc) && \
    make altinstall
  cd ..  # Move back to the previous directory
  rm -rf ${py_archive}

  echo "Built Python ${py_dir} successfully!"
  echo $(/usr/local/bin/python${py_major_minor} --version)
  
  # Upgrade pip, create venv, and install uv
  echo "Create scratch venvs with uv"
  echo "Creating uv venv in /venvs/.venv_uv_${py_major_minor}" 
  uv venv -p /usr/local/bin/python${py_major_minor} /venvs/.venv_uv_${py_major_minor}
}

# Define desired Python versions as a space-separated string
desired_versions="3.9.19 3.10.14 3.11.9 3.12.3"

mkdir -p /venvs
curl -LsSf https://astral.sh/uv/install.sh | sh
ln -s $HOME/.cargo/bin/uv /usr/local/bin/uv

# Iterate over desired Python versions
for py_version in $desired_versions; do
  build_python_version $py_version  # Call the function
done

echo "Build completed for desired Python versions: $desired_versions"
