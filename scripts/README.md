This folder contains the data gathering scripts / programs that live on the Raspberry Pi.

## Detection Services


A [Raspberry Pi systemd](https://www.raspberrypi.org/documentation/linux/usage/systemd.md) script to keep simple-motion.py running.

On the device:

    $ cd interactive-spaces/scripts

Install a service file to the main system folder:

    $ sudo cp motion-detection.service /etc/systemd/system/

Try starting the service manually:

    $ sudo systemctl start motion-detection.service

Check if it's running well by watching the logs:

    $ tail -f /var/log/syslog

Finally, tell systemctl to run the service on reboot:

    $ sudo systemctl enable motion-detection.service

If you need to stop the service:

    $ sudo systemctl stop motion-detection.service

If you need to turn the service off permanently:

    $ sudo systemctl disable motion-detection.service



### `simple-motion.py`

Loads the `motion_detector` and `utils` packages to detect and respond to motion.



### `simple-sound.py`

Loads the `sound_detector` and `utils` packages to detect and respond to sound.
