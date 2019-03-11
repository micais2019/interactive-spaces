#####################
## COMPUTER VISION!
## Adapted from https://software.intel.com/en-us/node/754940
#####################
import numpy as np
import cv2
import random

## setup motion detection support functions
sdThresh = 10
font = cv2.FONT_HERSHEY_SIMPLEX

def distMap(frame1, frame2):
    """outputs pythagorean distance between two frames"""
    frame1_32 = np.float32(frame1)
    frame2_32 = np.float32(frame2)
    diff32 = frame1_32 - frame2_32
    norm32 = np.sqrt(diff32[:,:,0]**2 + diff32[:,:,1]**2 + diff32[:,:,2]**2)/np.sqrt(255**2 + 255**2 + 255**2)
    dist = np.uint8(norm32*255)
    return dist

def linMap(value, leftMin, leftMax, rightMin, rightMax):
    """maps a value from one range onto another"""
    # Figure out how 'wide' each range is
    leftSpan = leftMax - leftMin
    rightSpan = rightMax - rightMin

    # Convert the left range into a 0-1 range (float)
    valueScaled = float(value - leftMin) / float(leftSpan)

    # Convert the 0-1 range into a value in the right range.
    return rightMin + (valueScaled * rightSpan)


#####################
## Adafruit IO
#####################
from Adafruit_IO import Client
from datetime import datetime
from secrets import secrets

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
motion = aio.feeds('motion-2')

#######
## LEDs
#######
## load libraries:
##
##   sudo pip3 install rpi_ws281x adafruit-circuitpython-neopixel
##
import board
import neopixel
pixels = neopixel.NeoPixel(board.D18, 12)
light_on = False


### script specific variables
max_motion_value = 0
last_pub = datetime.utcnow()
publish_delay_seconds = 10
light_on_delay_seconds = 1
on_color = (255, 255, 0)
off_color = (0, 0, 0)


pixels.fill(on_color)

#capture video stream from camera source. 0 refers to first camera, 1 referes to 2nd and so on.
cap = cv2.VideoCapture(0)

# hold 2 frames as reference
_, frame1 = cap.read()
_, frame2 = cap.read()

pixels.fill(off_color)

while(True):

    # take a new frame of video
    _, frame3 = cap.read()
    rows, cols, _ = np.shape(frame3)
    cv2.imshow('dist', frame3)

    # how far apart are frame1 and frame3?
    dist = distMap(frame1, frame3)

    # rotate frames
    frame1 = frame2
    frame2 = frame3

    # apply Gaussian smoothing
    mod = cv2.GaussianBlur(dist, (9,9), 0)

    # apply thresholding
    _, thresh = cv2.threshold(mod, 100, 255, 0)

    # calculate standard deviation test
    _, stDev = cv2.meanStdDev(mod)

    max_motion_value = max(stDev, max_motion_value)

    pcount = linMap(stDev[0][0], 10, 50, 0, 12)
    for i in range(12):
        if pcount > i:
            pixels[i] = on_color
        else:
            pixels[i] = off_color

    # render text to the screen
    cv2.putText(frame2, "Standard Deviation - {}".format(round(stDev[0][0],0)), (70, 70), font, 1, (255, 0, 255), 1, cv2.LINE_AA)
    if stDev > sdThresh:
        print("motion detected {:04d}".format(counter));
        cv2.imshow('motion', mod)

    # send accumulated data every publish_delay_seconds
    now = datetime.utcnow()
    if (now - last_pub).seconds > publish_delay_seconds:
        print('')
        print("------------------------ {}".format(now))
        print("motion published {:04d}".format(max_motion_value));
        print("------------------------------".format(now))
        print('')
        aio.send_data(motion.key, counter)
        max_motion_value = 0
        light_on = True
        on_color = (int(random.random() * 255), int(random.random() * 255), int(random.random() * 255))

        last_pub = now

    # if light_on:
    #    pixels.fill(on_color)
    #    if (now - last_pub).seconds > light_on_delay_seconds:
    #        light_on = False
    #        pixels.fill((0, 0, 0))

    # cv2.imwrite('/home/pi/images/frame.jpg', mod)
    if cv2.waitKey(1) & 0xFF == 27:
        break

cap.release()

