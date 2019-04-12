#####################
## COMPUTER VISION!
## Adapted from: https://software.intel.com/en-us/node/754940
## and: https://docs.opencv.org/3.4/db/d5c/tutorial_py_bg_subtraction.html
#####################

# defaults
import sys
import signal
import time

import board
import digitalio

from .adafruit_debouncer import Debouncer

def to_switch(button):
    button.direction = digitalio.Direction.INPUT
    button.pull = digitalio.Pull.UP
    return Debouncer(button)

BUTTONS = [to_switch(b) for b in [
    digitalio.DigitalInOut(board.D4),
    digitalio.DigitalInOut(board.D3)
]]

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
        self.call_handler("on_shutdown")
        sys.exit(0)

    def setup(self):
        # attach interrupt handler for clean shutdown on SIGINT
        signal.signal(signal.SIGINT, self.shutdown)
        signal.signal(signal.SIGTERM, self.shutdown)

    def run(self):
        # track time between intervals
        last_interval = time.time()
        last_trigger = time.time()

        button_states = {}

        # while True:
        #     led.value = not button.value # light when button is pressed!

        while True:
            now = time.time()

            for bidx in range(len(BUTTONS)): 
                button = BUTTONS[bidx]
                button.update()

                if button.fell:
                    if not button_states.get(bidx, False):
                        button_states[bidx] = now
                        print("BUTTON {} PRESSED".format(bidx))
                        self.call_handler("on_trigger", bidx)
                elif button.rose:
                    button_states[bidx] = False

            # send accumulated data every interval_seconds
            if (now - last_interval) > self.interval_seconds:
                self.call_handler("on_interval")
                last_interval = now

            self.call_handler("on_update")


        self.shutdown()
