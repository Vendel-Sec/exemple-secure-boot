#!/bin/bash
set -e

# Compiler et extraire le micrologiciel
cargo build
espflash save-image --chip esp32s3 --flash-size 8mb target/xtensa-esp32s3-espidf/debug/exemple-secure-boot firmware.bin

# Chiffrer le micrologiciel
source ~/esp/esp-idf/export.sh
espsecure.py encrypt_flash_data --aes_xts --keyfile keys/flash_encryption_key.bin --address 0x10000 --output firmware-enc.bin firmware.bin

# Ecrire le micrologiciel
esptool.py --chip esp32s3 --port /dev/ttyACM0 --no-stub write_flash 0x10000 firmware-enc.bin
