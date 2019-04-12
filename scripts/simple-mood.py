#
# Main mood station code.
#
# Wait for button input, then publish to IO, light Dotstars, and print result


from Adafruit_IO import Client
from datetime import datetime
import time
import numpy

# seeeeeecrets
from secrets import secrets

# local help libraries
from utils import identity, mathutils, logger, lttb

# local SOUND detection library
from mood_detector import mood_detector

class DetectionHandler:
    def __init__(self, client, feed_key):
        self.client = client
        self.feed_key = feed_key
        self.logger = logger.Logger("logs/mood.log")

        # current, max, min
        self.values = []

    def on_setup(self, *args):
        message = "starting mood detector on {}".format(identity.get_identity())
        print(message)
        self.client.send_data("monitor", message)
        self.logger.debug(message)
        # TODO: LED startup signal <here>

    # every click
    def on_update(self, score):
        self.values.append([time.time(), int(score)])
        print(score)

    # every time `interval_seconds` passes
    def on_interval(self, score):
        print()
        print("------------------------------")
        print("send mood data with score {} at {}".format(score, time.time()))
        print("------------------------------")
        print()

        # self.client.send_data(self.feed_key, score)
        self.logger.info(score)

        self.levels = []
        # TODO: signal data sent with LEDs <here>

## setup Adafruit IO client
ADAFRUIT_IO_USERNAME = secrets.get("ADAFRUIT_IO_USERNAME")
ADAFRUIT_IO_KEY = secrets.get("ADAFRUIT_IO_KEY")
if ADAFRUIT_IO_USERNAME == None or ADAFRUIT_IO_KEY == None:
    print("make sure ADAFRUIT_IO_USERNAME and ADAFRUIT_IO_KEY are set in secrets.py:")
    print("")
    print("""
    secrets = {
        'ADAFRUIT_IO_USERNAME': 'io username',
        'ADAFRUIT_IO_KEY': 'io key'"
    }""")
    print("")
    exit(1)
aio = Client(ADAFRUIT_IO_USERNAME, ADAFRUIT_IO_KEY)

# initialize DetectionHandler with adafruit IO client and a feed to update
handler = DetectionHandler(aio, "sound")

# initialize MotionDetector with the event handler and proper settings
detector = mood_detector.MoodDetector(
    handler, interval_seconds=3
)

# start the whole thing, run forever
detector.run()

