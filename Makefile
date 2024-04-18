IMG ?= ghcr.io/johanneswuerbach/qhd:latest
PLATFORM ?= linux/amd64,linux/arm64

build:
	docker buildx build --platform $(PLATFORM) -t $(IMG) .

check:
	docker run --rm -v $(PWD):/app $(IMG) ./scripts/check.sh

push:
	docker buildx build --platform $(PLATFORM) -t $(IMG) --push .
