# Exemple Secure Boot
Ce répertoire contient un simple exemple de programme Rust pour la plateforme ESP32s3.
Le programme fait clignoter une DEL contrôlée par le GPIO 2 à une fréquence donnée.

Ce programme sera utilisé pour démontrer comment utiliser le démarrage sécurisé (Secure Boot) sur un appareil ESP32 lors de la formation de l'ISEQ 2025.

## Commandes
Voici les commandes qui seront à faire lors de l'exercice.

> [!WARNING]
> Veuillez attendre que les formateurs vous demandent d'entrer les commandes. Une mauvaise utilisation de ces commandes pourrait causer le bris de l'appareil.

```sh
# Creer les dossiers
mkdir -p keys temp

# Creer une cle et faire une sauvegarde
openssl genrsa -out keys/secure_boot_signing_key.pem 3072
cp keys/secure_boot_signing_key.pem keys/secure_boot_signing_key.pem.bak

# Extraire l'image binaire
espflash save-image --chip esp32s3 target/xtensa-esp32s3-espidf/debug/exemple-secure-boot temp/firmware.bin

# Ajouter les outils
source ~/esp/esp-idf/export.sh

# Deriver la cle publique
espsecure.py digest_sbv2_public_key --keyfile keys/secure_boot_signing_key.pem --output keys/digest.bin

# Bruler la cle publique
espefuse.py --port /dev/ttyACM0 --chip esp32s3 burn_key BLOCK_KEY2 keys/digest.bin SECURE_BOOT_DIGEST0

# Activer Secure Boot
espefuse.py --port /dev/ttyACM0 --chip esp32s3 burn_efuse SECURE_BOOT_EN
espefuse.py --port /dev/ttyACM0 --chip esp32s3 write_protect_efuse RD_DIS

# Signer le bootloader et le micrologiciel
espsecure.py sign_data --key keys/secure_boot_signing_key.pem --version 2 --output temp/bootloader-signed.bin target/xtensa-esp32s3-espidf/debug/bootloader.bin
espsecure.py sign_data --key keys/secure_boot_signing_key.pem --version 2 --output temp/firmware-signed.bin temp/firmware.bin

# Chiffrer les partitions
espsecure.py encrypt_flash_data --aes_xts --keyfile keys/flash_encryption_key.bin --address 0x0 --output temp/bootloader-enc.bin temp/bootloader-signed.bin
espsecure.py encrypt_flash_data --aes_xts --keyfile keys/flash_encryption_key.bin --address 0xA000 --output temp/partition-table-enc.bin target/xtensa-esp32s3-espidf/debug/partition-table.bin
espsecure.py encrypt_flash_data --aes_xts --keyfile keys/flash_encryption_key.bin --address 0x20000 --output temp/firmware-enc.bin temp/firmware-signed.bin

# Ecrire les donnees sur l'appareil
esptool.py --chip esp32s3 --port /dev/ttyACM0 --no-stub write_flash 0 temp/bootloader-enc.bin 0xA000 temp/partition-table-enc.bin --force
esptool.py --chip esp32s3 --port /dev/ttyACM0 --no-stub write_flash 0x20000 temp/firmware-enc.bin --force
```
