from Adafruit_IO import Client
from datetime import datetime
from secrets import secrets
from utils import identity, math

# local motion detection library
from motion_detector import motion_detector

class DetectionHandler:
    def __init__(self, client, feed_key):
        self.client = client
        self.feed_key = feed_key

    def on_setup(self, *args):
        message = "starting {}".format(identity.get_identity())
        print(message)
        self.client.send_data('monitor', message)
        # TODO: LED startup signal <here>

    # every frame
    def on_update(self, score):
        pcount = math.lin_map(score, 10, 50, 0, 12)
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

# initialize MotionDetector with the event handler and proper settings
modec = motion_detector.MotionDetector(
    handler, interval_seconds=10, movement_threshold=10, headless=True
)

# start the whole thing, run forever
modec.run()
