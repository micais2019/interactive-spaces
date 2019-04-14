# sound card / hardware setup
sudo cp scripts/etc/asound.conf /etc/asound.conf
sudo cp scripts/etc/logrotate/sensors /etc/logrotate.d/sensors

# install python detection and publishing services
sudo cp scripts/etc/systemd/motion-detection.service /etc/systemd/system/
sudo cp scripts/etc/systemd/sound-detection.service /etc/systemd/system/
