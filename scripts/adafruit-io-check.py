
import numpy as np
import cv2
# from sklearn.cluster import KMeans
import random
import pyaudio

#####################
## Adafruit IO
#####################
from Adafruit_IO import Client
from datetime import datetime
from secrets import secrets

# local help libraries
from utils import identity

ADAFRUIT_IO_USERNAME = secrets.get('ADAFRUIT_IO_USERNAME')
ADAFRUIT_IO_KEY = secrets.get('ADAFRUIT_IO_KEY')

if ADAFRUIT_IO_USERNAME == None or ADAFRUIT_IO_KEY == None:
    print("make sure ADAFRUIT_IO_USERNAME and ADAFRUIT_IO_KEY are set in secrets.py:")
    print("")
    print("  secrets = {'ADAFRUIT_IO_USERNAME': 'io username', 'ADAFRUIT_IO_KEY': 'io key'}")
    print("")
    exit(1)

## setup Adafruit IO client
aio = Client(ADAFRUIT_IO_USERNAME, ADAFRUIT_IO_KEY)
monitor = aio.feeds('monitor')

message = "starting adafruit IO check on {}".format(identity.get_identity())
print(message)
aio.send_data("monitor", message)
