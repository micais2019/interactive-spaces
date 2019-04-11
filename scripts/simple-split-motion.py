from Adafruit_IO import Client
from datetime import datetime
import time
from pathlib import Path

# https://learn.adafruit.com/assets/63404
# https://learn.adafruit.com/adafruit-dotstar-leds/python-circuitpython
import board
import adafruit_dotstar as dotstar
from utils import screen_writer
DOTCOUNT = 192
LIGHT_THRESHOLD = 12

LOG_FILE = "logs/split-motion.log"

# seeeeeecrets
from secrets import secrets

# local help libraries
from utils import identity, mathutils, logger, color

# local MOTION detection library
from split_motion_detector import split_motion_detector

class DetectionHandler:
    def __init__(self, client, feed_key):
        self.client = client
        self.feed_key = feed_key
        Path(LOG_FILE).touch()
        self.logger = logger.Logger(LOG_FILE)
        self.pixels = dotstar.DotStar(board.SCK, board.MOSI, DOTCOUNT, brightness=0.9, auto_write=False)

    def on_setup(self, *args):
        message = "starting motion detector on {}".format(identity.get_identity())
        print(message)
        self.client.send_data("monitor", message)
        self.logger.debug(message)
        # TODO: LED startup signal <here>

    # every frame
    def on_update(self, scores):
        # print("FRAME {}".format(scores))
        idx = 0
        for x in reversed(range(8)):
            for y in range(6):
                pxls = screen_writer.screen_to_pixel(x, y)
                score = scores[idx]

                c = color.wheel(score * 2)

                if score < LIGHT_THRESHOLD:
                    c = (0, 0, 0)

                for pixel in pxls: 
                    self.pixels[pixel] = c
                
                idx += 1
        self.pixels.show()

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

    def on_shutdown(self):
        self.pixels.fill((0, 0, 0))
        self.pixels.show()


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
    headless=True,
    camera_id=-1,
    xsteps=8,
    ysteps=6
)

# start the whole thing, run forever
modec.run()
