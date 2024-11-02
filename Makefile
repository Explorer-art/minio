ASM=nasm

SRC_DIR=src
BUILD_DIR=build

.PHONY: all bootloader kernel clean always

all: clean minios.img

minios.img: $(BUILD_DIR)/minios.img

$(BUILD_DIR)/minios.img: bootloader kernel
	dd if=/dev/zero of=$(BUILD_DIR)/minios.img bs=512 count=2880
	mkfs.fat -F 12 -n "NBOS" $(BUILD_DIR)/minios.img
	dd if=$(BUILD_DIR)/bootloader.bin of=$(BUILD_DIR)/minios.img conv=notrunc
	mcopy -i $(BUILD_DIR)/minios.img $(BUILD_DIR)/kernel.bin "::kernel.bin"

#
# Bootloader
#

bootloader: $(BUILD_DIR)/bootloader.bin

$(BUILD_DIR)/bootloader.bin: always
	$(MAKE) -C $(SRC_DIR)/bootloader BUILD_DIR=$(abspath $(BUILD_DIR))

#
# Kernel
#

kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: always
	$(MAKE) -C $(SRC_DIR)/kernel BUILD_DIR=$(abspath $(BUILD_DIR))

always:
	mkdir -p $(BUILD_DIR)

clean:
	$(MAKE) -C $(SRC_DIR)/bootloader BUILD_DIR=$(abspath $(BUILD_DIR)) clean
	$(MAKE) -C $(SRC_DIR)/kernel BUILD_DIR=$(abspath $(BUILD_DIR)) clean
	rm -rf $(BUILD_DIR)/*