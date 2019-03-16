from Adafruit_IO import Client
from datetime import datetime
import time

# seeeeeecrets
from secrets import secrets

# local help libraries
from utils import identity, mathutils, logger

# local MOTION detection library
from motion_detector import motion_detector


class DetectionHandler:
    def __init__(self, client, feed_key):
        self.client = client
        self.feed_key = feed_key
        self.logger = logger.Logger("logs/motion.log")

    def on_setup(self, *args):
        message = "starting motion detector on {}".format(identity.get_identity())
        print(message)
        self.client.send_data("monitor", message)
        self.logger.debug(message)
        # TODO: LED startup signal <here>

    # every frame
    def on_update(self, score):
        pcount = mathutils.lin_map(score, 10, 50, 0, 12)
        # TODO: update LEDs according to motion <here>
        pass

    # every time score passes threshold
    def on_trigger(self, score, max_score):
        print("  detected motion with score {}, max {}".format(score, max_score))

    # every time `interval_seconds` passes
    def on_interval(self, score):
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
handler = DetectionHandler(aio, "motion")

# give camera time to load
time.sleep(5)

# initialize MotionDetector with the event handler and proper settings
modec = motion_detector.MotionDetector(
    handler,
    interval_seconds=2,
    trigger_interval_seconds=0,
    movement_threshold=18,
    headless=True,
    camera_id=1,
)

# start the whole thing, run forever
modec.run()
