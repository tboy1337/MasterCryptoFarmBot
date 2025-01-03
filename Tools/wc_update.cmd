@echo off

echo Updating wallet_connector...
cd ..
cd wallet_connector
git pull

echo Updating wc_blum...
cd modules\wc_blum
git pull

echo Updating wc_notpixel...
cd ..
cd modules\wc_notpixel
git pull

echo Updating wc_paws...
cd ..
cd modules\wc_paws
git pull

cd ..
cd ..
cd ..

exit
