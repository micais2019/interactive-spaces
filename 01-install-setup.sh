sudo apt update

sudo apt-get remove -y --purge libreoffice*
sudo apt-get remove -y --purge "Minecraft Pi"
sudo apt-get clean -y
sudo apt-get autoremove -y

sudo apt-get update
sudo apt-get upgrade -y
sudo rpi-update

sudo apt install -y build-essential cmake pkg-config gfortran git-all vim
sudo apt install -y libportaudio0 libportaudio2  libportaudiocpp0 portaudio19-dev

