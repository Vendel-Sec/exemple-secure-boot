# Exemple Secure Boot
Ce répertoire contient un simple exemple de programme Rust pour la plateforme ESP32s3.
Le programme fait clignoter une DEL contrôlée par le GPIO 2 à une fréquence donnée.

Ce programme sera utilisé pour démontrer comment utiliser le démarrage sécurisé (Secure Boot) sur un appareil ESP32 lors de la formation de l'ISEQ 2025.

## Commandes
Voici les commandes qui seront à faire lors de l'exercice.

> [!WARNING]
> Veuillez attendre que les formateurs vous demandent d'entrer les commandes. Une mauvaise utilisation de ces commandes pourrait causer le bris de l'appareil.

```sh
# Creer une cle et faire une sauvegarde
openssl genrsa -out secure_boot_signing_key.pem 3072
cp secure_boot_signing_key.pem secure_boot_signing_key.pem.bak

# Extraire l'image binaire
espflash save-image --chip esp32s3 target/xtensa-esp32s3-espidf/debug/exemple-secure-boot firmware.bin

# Ajouter les outils
source ~/esp/esp-idf/export.sh

# Deriver la cle publique
espsecure.py digest_sbv2_public_key --keyfile secure_boot_signing_key.pem --output digest.bin

# Bruler la cle publique
espefuse.py --port /dev/ttyACM0 --chip esp32s3 burn_key BLOCK_KEY2 digest.bin SECURE_BOOT_DIGEST0

# Activer Secure Boot
espefuse.py --port /dev/ttyACM0 --chip esp32s3 burn_efuse SECURE_BOOT_EN
espefuse.py -p /dev/ttyACM0 write_protect_efuse RD_DIS

# Signer le bootloader et le micrologiciel
espsecure.py sign_data --key secure_boot_signing_key.pem --version 2 --output bootloader-signed.bin target/xtensa-esp32s3-espidf/debug/bootloader.bin
espsecure.py sign_data --key secure_boot_signing_key.pem --version 2 --output firmware-signed.bin firmware.bin

# Ecrire les donnees sur l'appareil
esptool.py --chip esp32s3 --port /dev/ttyACM0 --no-stub write_flash 0 bootloader-signed.bin 0xA000 target/xtensa-esp32s3-espidf/debug/partition-table.bin
esptool.py --chip esp32s3 --port /dev/ttyACM0 --no-stub 0x20000 firmware-signed.bin
```
