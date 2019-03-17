import numpy as np
import cv2
import time

METHOD = 'LAB'

# capture video stream from camera source. -1 -> get any camera
cap = cv2.VideoCapture(1)

def now():
    return time.time() * 1000.0

def downscale(frame):
    return cv2.resize(frame, None, None, 0.5, 0.5)

def frame_complete(idx, times, diffs):
    if idx > 0:
        prev = idx - 1
    else:
        prev = FT_MAX - 1
    # measure interval between this frame and last in ms
    times[idx] = now()
    diffs[idx] = times[idx] - times[prev]
    return (idx + 1) % FT_MAX

FT_MAX = 30 # get average time of last 30 frames
frame_times = [now() for i in range(FT_MAX)]
frame_waits = [0 for i in range(FT_MAX)]
idx = 0

while True:
    ret, frame = cap.read()

    dframe = downscale(frame)
    cv2.imshow("dframe", dframe)

    # LAB colorspace
    if METHOD == 'LAB':
        lframe = cv2.cvtColor(frame, cv2.COLOR_BGR2LAB)
        lc, ac, bc = cv2.split(lframe)
    elif METHOD == 'HSL':
        lframe = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
        hc, sc, lc = cv2.split(lframe)

    idx = frame_complete(idx, frame_times, frame_waits)

    print("light %0.4f frame %0.2f" % (np.average(lc), sum(frame_waits) / len(frame_waits)))

    k = cv2.waitKey(1) & 0xff
    if k == 27 or k == ord('q'):
        break# }}}
