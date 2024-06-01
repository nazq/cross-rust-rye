all: build

build:
	docker buildx build \
	--builder multi-builder \
	--platform linux/amd64,linux/arm64,linux/arm/v7,linux/ppc64le,linux/ppc64,linux/s390x,linux/riscv64,linux/mips64le,linux/mips64,linux/arm/v6 \
	--tag docker.io/nazq/cross-rye-py-runner \
	--push .

build-dbg:
	docker buildx build \
	--builder multi-builder \
	--platform linux/amd64,linux/arm64,linux/arm/v7,linux/ppc64le,linux/s390x,linux/riscv64,linux/mips64le,linux/mips64,linux/arm/v6 \
	--tag docker.io/nazq/cross-rye-py-runner \
	--progress=plain \
	--push . 2>&1 | tee build.log
