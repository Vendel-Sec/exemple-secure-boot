#!/bin/bash
# Build and extract the firmware
cargo build
espflash save-image --chip esp32s3 target/xtensa-esp32s3-espidf/debug/exemple-secure-boot firmware.bin

# Sign the firmware
source ~/esp/esp-idf/export.sh
espsecure.py sign_data --key secure_boot_signing_key.pem --version 2 --output firmware-signed.bin firmware.bin

# Flash the firmware
esptool.py --chip esp32s3 --port /dev/ttyACM0 --no-stub write_flash 0x20000 firmware-signed.bin
