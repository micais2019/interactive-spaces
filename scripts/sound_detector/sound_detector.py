import pyaudio
# import wave
# import audioop # if you want to use audioop.rms
import numpy as np

# defaults
import sys
import signal
from datetime import datetime
import time

CHUNK = 1024
FORMAT = pyaudio.paInt16
WIDTH = 2 # bytes for RMS sample
CHANNELS = 1
RATE = 48000

def np_audioop_rms(data, width):
    """audioop.rms() using numpy. more accurate RMS calculation"""
    if len(data) == 0: return None
    fromType = (np.int8, np.int16, np.int32)[width//2]
    d = np.frombuffer(data, fromType).astype(np.float)
    rms = np.sqrt( np.mean(d**2) )
    return int( rms )

class SoundDetector:
    def __init__(
        self, event_handler, interval_seconds=10, trigger_threshold=400, headless=True
    ):
        self.handler = event_handler
        self.interval_seconds = interval_seconds
        self.trigger_threshold = trigger_threshold
        self.headless = headless

        self.setup()

    def call_handler(self, handler_method, *args):
        method = getattr(self.handler, handler_method, None)
        if callable(method):
            # print("call {} with args {}".format(handler_method, ', '.join(str(a) for a in args)))
            method(*args)

    def setup(self):
        self.pyaudio = pyaudio.PyAudio()
        self.stream = self.pyaudio.open(
            format=FORMAT,
            channels=CHANNELS,
            rate=RATE,
            input=True,
            frames_per_buffer=CHUNK + 16
        )

        # attach interrupt handler for clean shutdown on SIGINT
        signal.signal(signal.SIGINT, self.shutdown)
        signal.signal(signal.SIGTERM, self.shutdown)

        self.call_handler("on_setup", self)

    def shutdown(self, sig=None, frame=None):
        print("stop signal detected")
        self.stream.stop_stream()
        self.stream.close()
        self.pyaudio.terminate()

        sys.exit(0)

    def run(self):
        # track data timeout
        last_interval = datetime.utcnow()

        max_level = 0
        min_level = 100000

        data = None

        while True:
            try:
                data = self.stream.read(CHUNK, exception_on_overflow = False)
            except OSError:
                print("OSError: stream failure")
                time.sleep(5)
                pass

            if not data:
                continue

            rms = np_audioop_rms(data, WIDTH) # here's where you calculate the volume

            self.call_handler("on_update", rms)

            if rms > max_level:
                max_level = rms
            if rms < min_level:
                min_level = rms

            if rms > self.trigger_threshold:
                self.call_handler("on_trigger", rms, max_level)

            # send accumulated data every interval_seconds
            now = datetime.utcnow()
            if (now - last_interval).seconds > self.interval_seconds:
                self.call_handler("on_interval", max_level)

                last_interval = now
                max_level = 0
                min_level = 100000

        self.shutdown()
