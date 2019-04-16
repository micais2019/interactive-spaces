import time
import pyaudio
import numpy as np

CHUNK = 1024
FORMAT = pyaudio.paInt16
WIDTH = 2 # bytes for RMS sample
CHANNELS = 1
RATE = 48000
CUTOFF = 275

def np_audioop_rms(data, width):
    """audioop.rms() using numpy. more accurate RMS calculation"""
    if len(data) == 0: return None
    fromType = (np.int8, np.int16, np.int32)[width//2]
    d = np.frombuffer(data, fromType).astype(np.float)
    rms = np.sqrt( np.mean(d**2) )
    return int( rms )

audio = pyaudio.PyAudio()
stream = None
while not stream:
    try:
        stream = audio.open(
            format=FORMAT,
            channels=CHANNELS,
            rate=RATE,
            input=True,
            frames_per_buffer=CHUNK + 16
        )
    except:
        print(".",end="",flush=True)
    time.sleep(1)

max_rms = 0
recent = []
while True:
    try:
        data = stream.read(CHUNK, exception_on_overflow = False)
    except OSError:
        print("OSError: stream failure")
        time.sleep(1)
        continue

    if not data:
        continue

    rms = np_audioop_rms(data, WIDTH) # here's where you calculate the volume
    max_rms = max(max_rms, rms)

    recent.append(rms)
    recent = recent[-10:]
    avg = sum(recent) / len(recent)

    if rms > CUTOFF:
        print("{:>8}{:>8}{:>8}".format(rms, max_rms, avg))
