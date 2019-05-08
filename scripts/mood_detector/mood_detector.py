# defaults
import sys
import signal
import time

import board
import digitalio
from .adafruit_debouncer import Debouncer
 
LIL_MOOD = True

def to_switch(pin):
    button = digitalio.DigitalInOut(pin)
    button.direction = digitalio.Direction.INPUT
    button.pull = digitalio.Pull.UP
    return Debouncer(button)

if LIL_MOOD:
    BUTTONS = [to_switch(pin) for pin in [
        board.D23, # 2
        board.D3,  # 8 
        board.D19, # 6
        board.D12, # 5
        board.D25, # 3
        board.D4,  # 9
        board.D21, # 7
        board.D5,  # 4
    ]]
else: 
    BUTTONS = [to_switch(pin) for pin in [
        board.D2, 
        board.D27,
        board.D23,
        board.D25,
        board.D5,
        board.D12,
        board.D19,
        board.D21,
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
        self.call_handler("on_setup")

    def run(self):
        # track time between intervals
        last_interval = time.time()
        last_trigger = time.time()

        while True:
            now = time.time()

            for bidx in range(len(BUTTONS)):
                button = BUTTONS[bidx]
                button.update()

                if button.fell:
                    # button is pressed
                    self.call_handler("on_trigger", bidx)

            # trigger interval handler every interval_seconds
            if (now - last_interval) > self.interval_seconds:
                self.call_handler("on_interval")
                last_interval = now

            # called absolutely every loop (as fast as possible)
            self.call_handler("on_update")

        self.shutdown()
