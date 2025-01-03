@echo off

echo Updating wallet_connector...
cd /d "C:\MasterCryptoFarmBot\wallet_connector"
git pull

echo Updating wc_blum...
cd /d "C:\MasterCryptoFarmBot\wallet_connector\modules\wc_blum"
git pull

echo Updating wc_notpixel...
cd /d "C:\MasterCryptoFarmBot\wallet_connector\modules\wc_notpixel"
git pull

echo Updating wc_paws...
cd /d "C:\MasterCryptoFarmBot\wallet_connector\modules\wc_paws"
git pull

cd /d "%~dp0"

exit
