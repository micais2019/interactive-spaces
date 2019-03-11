This folder contains the data gathering scripts / programs that live on the Raspberry Pi.

### `simple-motion.py`

Loads the `motion_detector` and `utils` packages to detect and respond to motion.

### `detection.service`

A [Raspberry Pi systemd](https://www.raspberrypi.org/documentation/linux/usage/systemd.md) script to keep simple-motion.py running.

On the device:

    $ cd interactive-spaces/scripts
    $ sudo cp detection.service /etc/systemd/system/
    $ sudo systemctl start detection.service

