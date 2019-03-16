# https://docs.opencv.org/3.4/db/d5c/tutorial_py_bg_subtraction.html

import numpy as np
import cv2 as cv
import time
import imutils

METHOD = 'MOG2'
WITH_THRESHOLD = False
DOWNSCALE = True
SHOW_DETECTION = True

print("motion detection with method", METHOD)

def frame_complete(idx, times, diffs):
    if idx > 0:
        prev = idx - 1
    else:
        prev = FT_MAX - 1
    # measure interval between this frame and last in ms
    times[idx] = now()
    diffs[idx] = times[idx] - times[prev]
    return (idx + 1) % FT_MAX


def now():
    return time.time() * 1000.0


def get_movement_amount(frame):
    if WITH_THRESHOLD:
        blur = cv.GaussianBlur(frame,(5,5),0)
        _, thres = cv.threshold(blur, 0, 255, cv.THRESH_BINARY+cv.THRESH_OTSU)
        mean, score = cv.meanStdDev(thres)
        return (score, thres)
    else:
        mean, score = cv.meanStdDev(frame)
        return (score, frame)


def display(frame):
    cv.imshow('frame', frame)


def downscale(frame):
    sframe = cv.resize(frame, None, None, 0.75, 0.75)
    # cv.imshow('small', sframe)

    gray = cv.cvtColor(sframe, cv.COLOR_BGR2GRAY)
    gray = cv.GaussianBlur(gray, (21, 21), 0)

    return gray


def capture(frame, thresh):
    # dilate the thresholded image to fill in holes, then find contours on
    # thresholded image
    thresh = cv.dilate(thresh, None, iterations=2)
    cnts = cv.findContours(thresh.copy(), cv.RETR_EXTERNAL,
        cv.CHAIN_APPROX_SIMPLE)
    cnts = imutils.grab_contours(cnts)

    # loop over the contours
    for c in cnts:
        # if the contour is too small, ignore it
        if cv.contourArea(c) < 500:
            continue

        # compute the bounding box for the contour, draw it on the frame,
        # and update the text
        (x, y, w, h) = cv.boundingRect(c)
        cv.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)

    cv.imshow("Security Feed", frame)


FT_MAX = 30 # get average time of last 30 frames
frame_times = [now() for i in range(FT_MAX)]
frame_waits = [0 for i in range(FT_MAX)]
idx = 0

# publishing
publish_interval = 1500
last_publish = now()
max_score = 0

# capture video stream from camera source. -1 -> get any camera
cap = cv.VideoCapture(1)

if METHOD == 'GMG':
    kernel = cv.getStructuringElement(cv.MORPH_ELLIPSE,(3,3))# {{{
    fgbg = cv.bgsegm.createBackgroundSubtractorGMG()

    while True:
        ret, frame = cap.read()
        if frame is None:
            # FIXME!
            print("no camera detected, quitting")
            break

        fgmask = fgbg.apply(frame)
        fgmask = cv.morphologyEx(fgmask, cv.MORPH_OPEN, kernel)

        (score, out_frame) = get_movement_amount(fgmask)
        display(out_frame)
        print("score %0.2f" % score)

        idx = frame_complete(idx, frame_times, frame_waits)

        k = cv.waitKey(1) & 0xff
        if k == 27 or k == ord('q'):
            break# }}}

elif METHOD == 'MOG':
    fgbg = cv.bgsegm.createBackgroundSubtractorMOG()# {{{

    while True:
        ret, frame = cap.read()
        fgmask = fgbg.apply(frame)

        (score, out_frame) = get_movement_amount(fgmask)
        display(out_frame)
        print("score %0.2f" % score)

        idx = frame_complete(idx, frame_times, frame_waits)

        k = cv.waitKey(1) & 0xff
        if k == 27 or k == ord('q'):
            break# }}}

elif METHOD == 'MOG2':
    fgbg = cv.createBackgroundSubtractorMOG2()

    while True:
        _, frame = cap.read()
        if DOWNSCALE:
            dframe = downscale(frame)
        else:
            dframe = frame
        # cv.imshow("dscale", dframe)

        fgmask = fgbg.apply(dframe)

        # draw boxes around movement regions
        # capture(dframe, fgmask)

        (score, out_frame) = get_movement_amount(fgmask)

        if SHOW_DETECTION:
            cv.rectangle(out_frame, (10, 2), (100,20), (255,255,255), -1)
            cv.putText(out_frame, str(score[0][0]), (15, 15), cv.FONT_HERSHEY_SIMPLEX, 0.5 , (0,0,0))
            cv.imshow("final", out_frame)

        # display(out_frame)
        # print("score %0.2f" % score)

        idx = frame_complete(idx, frame_times, frame_waits)

        k = cv.waitKey(1) & 0xff
        if k == 27 or k == ord('q'):
            break

        if score > max_score:
            max_score = score
        if now() > last_publish + publish_interval:
            print("-------------------------------------------")
            print("  PUBLISH   %0.3f" % max_score)
            print("  FRAME LEN %0.3fms" % (sum(frame_waits) / len(frame_waits)))
            print("-------------------------------------------")

            max_score = 0
            last_publish = now()

elif METHOD == 'DELTA':
    first_frame = None

    while True:
        ret, frame = cap.read()

        dframe = downscale(frame)

        if first_frame is None:
            first_frame = dframe
            continue

        # compute the absolute difference between the current frame and first
        # frame
        f_delta = cv.absdiff(first_frame, dframe)
        thresh = cv.threshold(f_delta, 25, 255, cv.THRESH_BINARY)[1]

        # dilate the thresholded image to fill in holes, then find contours on
        # thresholded image
        thresh = cv.dilate(thresh, None, iterations=2)
        cnts = cv.findContours(thresh.copy(), cv.RETR_EXTERNAL,
            cv.CHAIN_APPROX_SIMPLE)
        cnts = imutils.grab_contours(cnts)

        # loop over the contours
        for c in cnts:
            # if the contour is too small, ignore it
            if cv.contourArea(c) < 900:
                continue

            # compute the bounding box for the contour, draw it on the frame,
            # and update the text
            (x, y, w, h) = cv.boundingRect(c)
            cv.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)

        cv.imshow("Security Feed", frame)

        idx = frame_complete(idx, frame_times, frame_waits)

        k = cv.waitKey(1) & 0xff
        if k == 27 or k == ord('q'):
            break

cap.release()
cv.destroyAllWindows()
