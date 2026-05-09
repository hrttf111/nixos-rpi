DEST_DRIVE?=/dev/sdb
SERIAL?=/dev/ttyUSB0
PASSWORD?=raspberry

all: build

password.nix:
	printf '{}: \"$(shell mkpasswd -m sha-512 "$(PASSWORD)")\"' > password.nix

build: password.nix
	nix build ./#sd-card

serial:
	screen $(SERIAL) 115200

dd:
	unzstd -c result/sd-image/nixos-image-sd-card-*-armv6l-linux.img.zst | dd of=$(DEST_DRIVE)

clean:
	rm -rf ./result

.PHONY: all clean dd serial build
