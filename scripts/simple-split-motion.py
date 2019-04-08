from Adafruit_IO import Client
from datetime import datetime
import time
from pathlib import Path

LOG_FILE = "logs/split-motion.log"

# seeeeeecrets
from secrets import secrets

# local help libraries
from utils import identity, mathutils, logger

# local MOTION detection library
from split_motion_detector import split_motion_detector


class DetectionHandler:
    def __init__(self, client, feed_key):
        self.client = client
        self.feed_key = feed_key
        Path(LOG_FILE).touch()
        self.logger = logger.Logger(LOG_FILE)

    def on_setup(self, *args):
        message = "starting motion detector on {}".format(identity.get_identity())
        print(message)
        self.client.send_data("monitor", message)
        self.logger.debug(message)
        # TODO: LED startup signal <here>

    # every frame
    def on_update(self, scores):
        # TODO: update LEDs according to motion <here>
        pass

    # every time `interval_seconds` passes
    def on_interval(self, scores):
        score = (' ').join(["%i" % s for s in scores])
        print()
        print("------------------------------")
        print("send motion data with score {}".format(score))
        print("------------------------------")
        print()
        self.client.send_data(self.feed_key, score)
        self.logger.info(score)
        # TODO: signal data sent with LEDs <here>


## setup Adafruit IO client
ADAFRUIT_IO_USERNAME = secrets.get("ADAFRUIT_IO_USERNAME")
ADAFRUIT_IO_KEY = secrets.get("ADAFRUIT_IO_KEY")
if ADAFRUIT_IO_USERNAME == None or ADAFRUIT_IO_KEY == None:
    print("make sure ADAFRUIT_IO_USERNAME and ADAFRUIT_IO_KEY are set in secrets.py:")
    print("")
    print(
        """
        secrets = {
            'ADAFRUIT_IO_USERNAME': 'io username',
            'ADAFRUIT_IO_KEY': 'io key'"
        }"""
    )
    print("")
    exit(1)
aio = Client(ADAFRUIT_IO_USERNAME, ADAFRUIT_IO_KEY)

# initialize DetectionHandler with adafruit IO client and a feed to update
handler = DetectionHandler(aio, "split-motion")

# give camera time to load
time.sleep(5)

# initialize MotionDetector with the event handler and proper settings
modec = split_motion_detector.SplitMotionDetector(
    handler,
    interval_seconds=2,
    trigger_interval_seconds=0,
    movement_threshold=18,
    headless=False,
    camera_id=0,
    xsteps=10,
    xsteps=8,
    ysteps=6
)

# start the whole thing, run forever
modec.run()
