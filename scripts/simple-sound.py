from Adafruit_IO import MQTTClient
import time
import numpy
import math

THIS_FEED = 'sound-2'
OTHER_FEED = 'sound'

# seeeeeecrets
from secrets import secrets

# local help libraries
from utils import identity, mathutils, logger, lttb, color, data_sender

# local SOUND detection library
from sound_detector import sound_detector

TOP_DOTS = 24
BOTTOM_DOTS = 26
DOTCOUNT = TOP_DOTS + BOTTOM_DOTS * 2 

try:
    import board
    import adafruit_dotstar as dotstar
    dots = dotstar.DotStar(board.SCK, board.MOSI, DOTCOUNT, brightness=0.8, auto_write=False)
except:
    print("RUNNING FAKE DOTSTARS!")
    dots = fake_dotstars.FakeDotstars()

##
# TODO: add constants for sound reactive LEDs (which pixels are local, which are remote)
##

def set_top_pixel(index, c):
    # counts right to left
    if index < 0 or index >= TOP_DOTS:
        pass
    else: 
        dots[index] = c

def set_bottom_pixel(index, c): 
    down_pixel = (TOP_DOTS + BOTTOM_DOTS - 1) - index
    up_pixel = (TOP_DOTS + BOTTOM_DOTS) + index
    dots[down_pixel] = c
    dots[up_pixel] = c

def draw():
    dots.show()

MIN_VOLUME = 200
MAX_VOLUME = 10000
MIN_VOLUME_LOG = math.log(MIN_VOLUME, 2)
MAX_VOLUME_LOG = math.log(MAX_VOLUME, 2)
def constrain_volume(volume):
    return max(min(MAX_VOLUME, volume), MIN_VOLUME)

class MovingAverage:
    def __init__(self, count):
        self.idx = 0
        self.count = count
        self.values = [ 0 for i in range(self.count) ]

    def add(self, value):
        self.values[self.idx] = value 
        self.idx = (self.idx + 1) % self.count

    @property
    def value(self): 
        return sum(self.values) / self.count

def volume_to_top_bar(volume):
    volume = constrain_volume(volume) 

    # work with values as log base 2 of volume
    value = math.log(volume, 2)

    fill_count = int(mathutils.lin_map(value, MIN_VOLUME_LOG, MAX_VOLUME_LOG, 0, TOP_DOTS - 1))

    print("TOP VOL {:6} VAL {:8.2f} FC {:4}".format(volume, value, fill_count))

    for i in range(TOP_DOTS): 
        if i <= fill_count:
            set_top_pixel(i, (100, 100, 100))
        else:
            set_top_pixel(i, (0, 0, 0))
    draw()

bmoving_average = MovingAverage(5)
def volume_to_bottom_bar(volume):
    global bmoving_average
    volume = constrain_volume(volume) 

    # work with values as log base 2 of volume
    bmoving_average.add(math.log(volume, 2))
    value = bmoving_average.value

    fill_count = int(mathutils.lin_map(value, MIN_VOLUME_LOG, MAX_VOLUME_LOG, 0, BOTTOM_DOTS - 1))

    print("> BOTTOM VOL {:6} VAL {:8.2f} FC {:4}".format(volume, value, fill_count))

    for i in range(BOTTOM_DOTS): 
        if i <= fill_count:
            c = color.lerp_color((0, 255, 0), (255, 0, 0), i / BOTTOM_DOTS )
            set_bottom_pixel(i, c)
        else:
            set_bottom_pixel(i, (0, 0, 0))
    draw()


class DetectionHandler:
    def __init__(self, client, feed_key):
        self.client = client
        self.feed_key = feed_key
        self.logger = logger.Logger("logs/sound.log")

        # current, max, min
        self.levels = []

        # TODO: we'd like it to receive, as well

    def on_setup(self, *args):
        message = "starting sound detector on {}".format(identity.get_identity())
        print(message)
        self.client.send_data("monitor", message)
        self.logger.debug(message)

        # LED startup signal
        for i in range(TOP_DOTS):
            dots[i] = (100, 100, 100)
            time.sleep(0.01)

        for i in range(TOP_DOTS):
            dots[i] = (0, 0, 0)
            time.sleep(0.01)

    # every frame
    def on_update(self, score):
        self.levels.append([time.time(), int(score)])

        # volume_to_top_bar(score)
        volume_to_bottom_bar(score)


    # every time score passes threshold
    def on_trigger(self, score, max_score):
        # print("  detected sound with score {}, max {}".format(score, max_score))
        pass

    # every time `interval_seconds` passes
    def on_interval(self, score):
        out_value = score

        if len(self.levels) > 30:
            # limit output data to 30 samples
            np_levels = numpy.array(self.levels)
            lttb_result = lttb.downsample(np_levels, 30)
            out_value = ' '.join("%i" % v[1] for v in lttb_result)
        elif len(self.levels) > 0:
            out_value = ' '.join("%i" % v[1] for v in self.levels)

        print()
        print("------------------------------")
        print("send sound data with score {}".format(out_value))
        print("------------------------------")
        print()

        self.client.send_data(self.feed_key, out_value)
        self.logger.info(out_value)

        self.levels = []
        # TODO: (maybe) signal data sent with LEDs <here>

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
aio = data_sender.DataSender(ADAFRUIT_IO_USERNAME, ADAFRUIT_IO_KEY, debug=True)

# initialize station-1 DetectionHandler with adafruit IO client and a feed to update
handler = DetectionHandler(aio, THIS_FEED)

# initialize MotionDetector with the event handler and proper settings
detector = sound_detector.SoundDetector(
    handler, interval_seconds=3, trigger_threshold=400, headless=True
)

# setup MQTT client
# Define callback functions which will be called when certain events happen.
def connected(client):
    print("connected to Adafruit IO!  Listening for {0} changes...".format(OTHER_FEED))
    client.subscribe(OTHER_FEED)

def disconnected(client):
    # Disconnected function will be called when the client disconnects.
    print('disconnected from Adafruit IO!')
    # sys.exit(1)

def message(client, feed_id, payload):
    print('got message from {}: {}'.format(feed_id, payload))

    # values should be in the form of space separated 100ms volume levels
    for volume in [int(v) for v in payload.split(' ')]:
        volume_to_top_bar(volume)
        time.sleep(0.1)

# Create an MQTT client instance.
client = MQTTClient(ADAFRUIT_IO_USERNAME, ADAFRUIT_IO_KEY)

# Setup the callback functions defined above.
client.on_connect    = connected
client.on_disconnect = disconnected
client.on_message    = message

# Connect to the Adafruit IO server.
client.connect()

# Start a message loop that blocks forever waiting for MQTT messages to be
# received.  Note there are other options for running the event loop like doing
# so in a background thread--see the mqtt_client.py example to learn more.
client.loop_background()

# start the whole thing, run forever
detector.run()
