# cd ~
# wget -O opencv.zip https://github.com/opencv/opencv/archive/3.4.5.zip
# unzip opencv.zip
# wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/3.4.5.zip
# unzip opencv_contrib.zip

sudo apt install -y libatk1.0-0 libatlas3-base libavcodec57 libavformat57 \
  libavutil55 libcairo-gobject2 libcairo2 libgdk-pixbuf2.0-0 libgstreamer1.0-0 \
  libgtk-3-0 libharfbuzz0b libhdf5-100 libilmbase12 libjasper1 libopenexr22 \
  libpango-1.0-0 libpangocairo-1.0-0 libswscale4 libtiff5 libwebp6

sudo pip3 install opencv-python-headless
sudo pip3 install opencv-contrib-python-headless

