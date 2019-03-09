#####################
## COMPUTER VISION!
## Adapted from https://software.intel.com/en-us/node/754940
#####################
import numpy as np
import cv2

#####################
## Adafruit IO
#####################
from Adafruit_IO import Client
from datetime import datetime
import os
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
motion = aio.feeds('motion')

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

#capture video stream from camera source. 0 refers to first camera, 1 referes to 2nd and so on.
cap = cv2.VideoCapture(0)

# hold 2 frames as reference
_, frame1 = cap.read()
_, frame2 = cap.read()

counter = 0
last_pub = datetime.utcnow()
publish_delay_seconds = 30

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

    # render text to the screen
    cv2.putText(frame2, "Standard Deviation - {}".format(round(stDev[0][0],0)), (70, 70), font, 1, (255, 0, 255), 1, cv2.LINE_AA)
    if stDev > sdThresh:
        print("motion detected {:04d}".format(counter));
        cv2.imshow('motion', mod)
        # cv2.imwrite('/home/pi/images/dist-{:04d}.jpg'.format(counter), mod)
        # cv2.imwrite('/home/pi/images/frame-{:04d}.jpg'.format(counter), frame2)
        # cv2.imwrite('/home/pi/images/frame-{:04d}.jpg'.format(counter), mod)

        # increase the counter value when motion is detected in a frame
        counter = counter + 1

    # send accumulated data every publish_delay_seconds
    now = datetime.utcnow()
    if (now - last_pub).seconds > publish_delay_seconds:
        print('')
        print("------------------------ {}".format(now))
        print("motion published {:04d}".format(counter));
        print("------------------------------".format(now))
        print('')
        aio.send_data(motion.key, counter)
        counter = 0
        last_pub = now


    # cv2.imwrite('/home/pi/images/frame.jpg', mod)
    if cv2.waitKey(1) & 0xFF == 27:
        break

cap.release()

