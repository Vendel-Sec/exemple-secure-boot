#!/bin/bash
set -e

# Compiler et extraire le micrologiciel
cargo build
espflash save-image --chip esp32s3 --flash-size 8mb target/xtensa-esp32s3-espidf/debug/exemple-secure-boot temp/firmware.bin

# Signer et chiffrer le micrologiciel
source ~/esp/esp-idf/export.sh
espsecure.py sign_data --key keys/secure_boot_signing_key.pem --version 2 --output temp/firmware-signed.bin temp/firmware.bin
espsecure.py encrypt_flash_data --aes_xts --keyfile keys/flash_encryption_key.bin --address 0x20000 --output temp/firmware-enc.bin temp/firmware-signed.bin

# Ecrire le micrologiciel
esptool.py --chip esp32s3 --port /dev/ttyACM0 --no-stub write_flash 0x20000 temp/firmware-enc.bin --force
