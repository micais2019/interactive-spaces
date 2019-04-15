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

# COLORS and OUTPUTS must be sorted according to button connection order.
# This may be different on mood-1 and mood-2
COLORS = [
    (0, 0, 1),
    (0, 1, 0),
    (0, 1, 1),
    (1, 0, 0),
    (1, 0, 1),
    (1, 1, 0),
    (1, 1, 1),
    (0, 0, 2)
]

OUTPUTS = [ 0, 1, 2, 3, 4, 5, 6, 7 ]

class DetectionHandler:
    def __init__(self, client, feed_key):
        self.client = client
        self.feed_key = feed_key
        self.logger = logger.Logger("logs/mood.log")

        self.values = []
        self.print_values = []

        self.color = (0, 0, 0)
        self.do_fade = False
        self.fade_started = 0
        self.fade_seconds = 3

        try:
            self.printer = Usb(0x0416, 0x5011)
        except:
            self.printer = None

        now = time.time()

        # Publish at most once every 5 seconds
        self.last_publish = now
        self.publish_interval_seconds = 5
        self.last_request = None

        # Print at most once every 15 seconds
        self.last_print = now
        self.print_interval_seconds = 15

        self.last_pulse = now
        self.pulse_interval_seconds = 60

    def on_setup(self, *args):
        message = "starting mood detector on {}".format(identity.get_identity())

        self.client.send_data("monitor", message)
        self.last_publish = time.time()

        self.logger.debug(message)
        print(message)

        # LED startup signal
        for i in range(16):
            dots[i] = (100, 100, 100)
            time.sleep(0.1)

        for i in range(16):
            dots[i] = (0, 0, 0)
            time.sleep(0.1)

    def on_shutdown(self):
        dots.fill((0,0,0))

    # every interval
    def on_update(self):
        now = time.time()

        if self.do_fade:
            # time into fade span
            percent_complete = (now - self.fade_started) / self.fade_seconds

            if percent_complete >= 1.0:
                dots.fill([0, 0 ,0])
                self.do_fade = False
            else:
                # always fading out
                next_color = color.lerp_color(self.color, [0, 0, 0], percent_complete)
                if next_color[0] != self.color[0] or next_color[1] != self.color[1] or next_color[2] != self.color[2]:
                    self.color = next_color
                    dots.fill(self.color)

    # every click
    def on_trigger(self, button):
        print("[on_trigger] button", button)

        # always store values
        self.__store(button)

        # set pixel color first
        dots.fill(COLORS[button])

        # then print (delays sketch)
        self.__print(button)

        # and attempt to publish (also delays sketch)
        self.__publish()

        # now start color fade
        self.__fade(COLORS[button])

    # every time `interval_seconds` passes
    def on_interval(self):
        now = time.time()

        # new values have accumulated since the last publish event
        if len(self.values) > 0:
            self.__publish()

        # after a minute, pulse gently
        if now - self.last_publish > self.pulse_interval_seconds and now - self.last_pulse > self.pulse_interval_seconds:
            self.__fade((100, 100, 100))
            self.last_pulse = now

    def __fade(self, color):
        # NOTE:
        self.color = color
        self.do_fade = True
        self.fade_started = time.time()

        # fill LEDs with initial color
        dots.fill(self.color)

    def __print(self, button):
        now = time.time()

        # then print (delays script)
        if now - self.last_print > self.print_interval_seconds:
            if self.printer:
                print("[__print] printing", button)
                self.printer.text("YOU SELECTED {}\n\n".format(COLORS[button]))
                self.printer.text("THE LAST 10 VALUES WERE:\n")
                self.printer.text(" ".join(str(v) for v in self.print_values) + "\n")
                self.printer.text('micavibe.com/mood\n\n')
                self.printer.image('printer_test/tomicavibe_mood.png')
                self.printer.text('\n\n\n\n')
            else:
                print("=================== FAKE PRINT ===================")
                print("YOU SELECTED {}\n\n".format(COLORS[button]))
                print("THE LAST 10 VALUES WERE:\n")
                print(" ".join(str(v) for v in self.print_values) + "\n")
                print("==================================================")
                print()

            self.last_print = now

    def __publish(self):
        now = time.time()

        if now - self.last_publish > self.publish_interval_seconds:
            # publish max 256 values
            to_publish = " ".join(str(val) for val in self.values[-256:])
            print("publish values:", to_publish)

            # send data
            self.last_request = self.client.send_data(self.feed_key, to_publish)

            # mark time of publishing
            self.last_publish = now

            # flush publish value queue
            self.values = []

    def __store(self, value):
        self.values.append(value) # to publish
        if len(self.values) > 256:
            self.values.pop(0)
        self.print_values.append(value) # to print
        if len(self.print_values) > 10:
            self.print_values.pop(0)


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
aio = data_sender.DataSender(ADAFRUIT_IO_USERNAME, ADAFRUIT_IO_KEY, debug=True)

# initialize DetectionHandler with adafruit IO client and a feed to update
handler = DetectionHandler(aio, "mood")

# initialize MotionDetector with the event handler and proper settings
detector = mood_detector.MoodDetector(
    handler, interval_seconds=3
)

# start the whole thing, run forever
detector.run()


