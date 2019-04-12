#####################
## COMPUTER VISION!
## Adapted from: https://software.intel.com/en-us/node/754940
## and: https://docs.opencv.org/3.4/db/d5c/tutorial_py_bg_subtraction.html
#####################

# defaults
import sys
import signal
import time

BUTTONS = [
    digitalio.DigitalInOut(board.D4)
]

class MoodDetector:
    def __init__(
        self, event_handler, interval_seconds=5
    ):
        self.handler = event_handler
        self.interval_seconds = interval_seconds
        self.setup()

        self.buttons = []

    def call_handler(self, handler_method, *args):
        method = getattr(self.handler, handler_method, None)
        if callable(method):
            # print("call {} with args {}".format(handler_method, ', '.join(str(a) for a in args)))
            method(*args)

    def shutdown(self, sig=None, frame=None):
        print("stop signal detected")
        sys.exit(0)

    def setup(self):
        # attach interrupt handler for clean shutdown on SIGINT
        signal.signal(signal.SIGINT, self.shutdown)
        signal.signal(signal.SIGTERM, self.shutdown)

    def run(self):
        # track time between intervals
        last_interval = time.time()
        last_trigger = time.time()

        # while True:
        #     led.value = not button.value # light when button is pressed!

        while True:
            now = time.time()

            # send accumulated data every interval_seconds
            if (now - last_interval) > self.interval_seconds:
                self.call_handler("on_interval", 0)
                last_interval = now

        self.shutdown()
