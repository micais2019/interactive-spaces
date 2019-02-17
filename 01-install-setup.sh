sudo apt update

sudo apt-get remove --purge libreoffice*
sudo apt-get remove --purge "Minecraft Pi"
sudo apt-get clean
sudo apt-get autoremove

sudo apt-get update
sudo apt-get upgrade -y
sudo rpi-update

sudo apt install -y build-essential cmake pkg-config gfortran git-all vim

