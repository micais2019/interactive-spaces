
# ubuntu 18.04 AWS
sudo apt-add-repository ppa:ubuntu-x-swat/updates
sudo apt update
sudo apt install -y xvfb libxrender1 libxtst6 libxi6 default-jre unzip
sudo apt install -y libglu1-mesa-dev freeglut3-dev mesa-common-dev xserver-xorg libxmu-dev libxi-dev
sudo apt install -y imagemagick-6.q16hdri
sudo apt install -y git curl libssl-dev libreadline-dev zlib1g-dev autoconf \
  bison build-essential libyaml-dev libreadline-dev libncurses5-dev libffi-dev \
  libgdbm-dev
sudo apt install -y awscli

sudo nvidia-xconfig -a --use-display-device=None --virtual=1280x1024

wget http://download.processing.org/processing-3.5.3-linux64.tgz
tar -xzvf processing-3.5.3-linux64.tgz

git clone https://github.com/micais2019/interactive-spaces.git

# installing libraries
mkdir -p sketchbook/libraries/

# hemesh
wget https://www.wblut.com/hemesh/hemesh.zip
mkdir -p sketchbook/libraries/hemesh
unzip hemesh.zip -d sketchbook/libraries/hemesh/

# sql
wget https://github.com/benfry/sql-library-processing/raw/master/release/BezierSQLib.zip
unzip BezierSQLib-0.2.0.zip -d sketchbook/libraries/BezierSQLib/

# http.requests
wget https://github.com/runemadsen/HTTP-Requests-for-Processing/releases/download/0.1.4/httprequests_processing.zip
unzip httprequests_processing.zip -d sketchbook/libraries

# with nvidia driver from https://www.nvidia.com/Download/Find.aspx
# sudo apt-key add /var/nvidia-driver-local-repo-418.87.01/7fa2af80.pub
# sudo dpkg -i nvidia-driver-local-repo-ubuntu1804-418.87.01_1.0-1_amd64.deb

# move Database
# scp /Users/adam/projects/MICA/interactive-spaces-code/data/archive.sqlite mica-image-generation-g3:~/interactive-spaces/image-generation/compositor_3d/data/

# xvfb-run ~/processing-3.5.3/processing-java \
#  --sketch=/home/ubuntu/interactive-spaces/image-generation/compositor_3d/ \
#  --output=/home/ubuntu/sketchbook/compositor_output/ --force --run 1555344000 1 true

# setup ruby
curl -sL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer | bash -
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc
rbenv install 2.6.5
