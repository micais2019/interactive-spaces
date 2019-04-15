#
# Main mood station code.
#
# Wait for button input, then publish to IO, light Dotstars, and print result
#

import time
import numpy

# seeeeeecrets
from secrets import secrets

# local help libraries
from utils import identity, logger, color, data_sender, fake_dotstars

import sys

from escpos.printer import Usb

# local SOUND detection library
from mood_detector import mood_detector

try:
    import board
    import adafruit_dotstar as dotstar
    DOTCOUNT = 16
    dots = dotstar.DotStar(board.SCK, board.MOSI, DOTCOUNT, brightness=0.8)
except:
    dots = fake_dotstars.FakeDotstars()

class DetectionHandler:
    def __init__(self, client, feed_key):
        self.client = client
        self.feed_key = feed_key
        self.logger = logger.Logger("logs/mood.log")

        # current, max, min
        self.values = []
        self.button_states = {}

        self.color = (0, 0, 0)
        self.do_fade = False
        self.fade_started = 0
        self.fade_seconds = 3

        try:
            self.printer = Usb(0x0416, 0x5011)
        except:
            self.printer = None

        self.last_publish = 0
        self.publish_interval_seconds = 5

        self.last_print = 0
        self.print_interval_seconds = 15

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

        if self.do_fade:
            # time into fade span
            percent_complete = (now - self.fade_started) / self.fade_seconds

            if percent_complete >= 1.0:
                dots.fill([0, 0 ,0])
                self.do_fade = False
            else:
                next_color = color.lerp_color(self.color, [0, 0, 0], percent_complete)
                if next_color[0] != self.color[0] or next_color[1] != self.color[1] or next_color[2] != self.color[2]:
                    self.color = next_color
                    dots.fill(self.color)

    def on_trigger(self, button):
        # set pixel color first
        dots.fill(COLORS[button])

        # then print (delays sketch)
        self.__print(button)

        # and attempt to publish (also delays sketch)
        self.__publish(button)

        # now start color fade
        self.__fade(COLORS[button])

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

    def __fade(self, color):
        self.color = color
        self.do_fade = True
        self.fade_started = time.time()

        # fill LEDs with initial color
        dots.fill(self.color)

    def __print(self, button):
        now = time.time()

        # then print (delays script)
        if self.printer and now - self.last_print > self.print_interval_seconds:
            self.printer.text("YOU SELECTED {}\n\n".format(COLORS[button]))
            self.printer.text('micavibe.com/mood\n\n')
            self.printer.image('printer_test/tomicavibe_mood.png')
            self.printer.text('\n\n\n\n')

    def __publish(self, button):
        now = time.time()

        if now - self.last_publish > self.publish_interval_seconds:
            print("publish this button:", button)
            self.last_publish = now


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
aio = data_sender.DataSender(ADAFRUIT_IO_USERNAME, ADAFRUIT_IO_KEY)

# initialize DetectionHandler with adafruit IO client and a feed to update
handler = DetectionHandler(aio, "mood")

# initialize MotionDetector with the event handler and proper settings
detector = mood_detector.MoodDetector(
    handler, interval_seconds=3
)

# start the whole thing, run forever
detector.run()

