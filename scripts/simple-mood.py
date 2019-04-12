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
from utils import identity, logger

import sys

from escpos.printer import Usb

# local SOUND detection library
from mood_detector import mood_detector

import board
import adafruit_dotstar as dotstar
DOTCOUNT = 4
dots = dotstar.DotStar(board.SCK, board.MOSI, DOTCOUNT, brightness=0.8)

class DetectionHandler:
    def __init__(self, client, feed_key):
        self.client = client
        self.feed_key = feed_key
        self.logger = logger.Logger("logs/mood.log")

        # current, max, min
        self.values = []
        self.button_states = {}

        self.color = (0, 0, 0)
        self.fade_interval = 0.01
        self.last_step = 0

        self.printer = Usb(0x0416, 0x5011)

    def on_setup(self, *args):
        message = "starting mood detector on {}".format(identity.get_identity())
        print(message)
        self.client.send_data("monitor", message)
        self.logger.debug(message)
        # TODO: LED startup signal <here>

    def on_shutdown(self):
        dots.fill((0,0,0))

    # every click
    def on_update(self):
        now = time.time()

        # self.values.append([time.time(), int(score)])
        if any(c > 0 for c in self.color):
            # fade
            if now - self.last_step > self.fade_interval:
                dots.fill(self.color)

                # decrement each value in self.color
                self.color = [ 
                    v - 2 if v > 2 else 0
                    for v in self.color 
                ]

                self.last_step = now
                    
    def on_trigger(self, button):
        color_name = "Something"
        if button == 0:
            color_name = "Sunset Red"
            self.color = [255, 0, 0]
        elif button == 1:
            color_name = "Feeling Blue"
            self.color = [0, 100, 255]

        self.printer.text("YOU SELECTED {}\n\n".format(button))
        self.printer.text('micavibe.com/mood\n\n')
        self.printer.image('printer_test/tomicavibe_mood.png')
        self.printer.text('\n\n\n\n')

    # every time `interval_seconds` passes
    def on_interval(self):
        # print()
        # print("------------------------------")
        # print("send mood data with score {} at {}".format(score, time.time()))
        # print("------------------------------")
        # print()
        # # self.client.send_data(self.feed_key, score)
        # self.logger.info(score)

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

