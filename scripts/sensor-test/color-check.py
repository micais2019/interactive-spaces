# https://code.likeagirl.io/finding-dominant-colour-on-an-image-b4e075f98097
# https://github.com/skt7/dominant-colors-in-an-image-using-k-means-clustering
import cv2
import numpy as np
from sklearn.cluster import KMeans # pip install sklearn (y tho?)
from collections import Counter
import json
import time

KMEANS = True

def now():
    return time.time() * 1000.0


def downscale(frame):
    sframe = cv2.resize(frame, None, None, 0.5, 0.5)
    # return cv2.GaussianBlur(sframe, (21, 21), 0)
    return sframe


def frame_complete(idx, times, diffs):
    if idx > 0:
        prev = idx - 1
    else:
        prev = FT_MAX - 1
    # measure interval between this frame and last in ms
    times[idx] = now()
    diffs[idx] = times[idx] - times[prev]
    return (idx + 1) % FT_MAX


def get_dominant_color(image, k=4):
    """
    takes an image as input and returns the dominant color in the image as a list

    dominant color is found by performing k means on the pixel colors and returning the centroid
    of the largest cluster
    processing time is sped up by working with a smaller image; this can be done with the
    image_processing_size param which takes a tuple of image dims as input
    >>> get_dominant_color(my_image, k=4, image_processing_size = (25, 25))
    [56.2423442, 34.0834233, 70.1234123]
    """
    #resize image if new dims provided
    image = cv2.resize(image, None, None, 0.25, 0.25, interpolation = cv2.INTER_AREA)

    #reshape the image to be a list of pixels
    image = image.reshape((image.shape[0] * image.shape[1], 3))

    #cluster the pixels and assign labels
    clt = KMeans(n_clusters = k)
    labels = clt.fit_predict(image)

    #count labels to find most popular
    label_counts = Counter(labels)

    #subset out most popular centroid
    dominant_color = clt.cluster_centers_[label_counts.most_common(1)[0][0]]

    return list(int(c) for c in dominant_color)



FT_MAX = 5 # get average time of last frames
frame_times = [now() for i in range(FT_MAX)]
frame_waits = [0 for i in range(FT_MAX)]
idx = 0



# capture video stream from camera source. -1 -> get any camera
frame = None
dframe = None

cap = cv2.VideoCapture(1)

while frame is None:
    _, frame = cap.read()
    try:
        dframe = downscale(frame)
    except:
        time.sleep(1)
        cap = cv2.VideoCapture(1)


height, width = dframe.shape[:2]
x1 = int(width / 3)
y1 = int(height / 8)
x2 = width - x1
y2 = height - y1

yh = y2 - y1

zones = [
    {
        "shape": [(x1, y1), (x2, int(y1 + yh/3))],
        "color": (0, 0, 0)
    },
    {
        "shape": [(x1, int(y1 + yh/3)), (x2, int(y2 - yh/3))],
        "color": (0, 0, 0)
    },
    {
        "shape": [(x1, int(y1 + yh/3 * 2)), (x2, y2)],
        "color": (0, 0, 0)
    },
]

zone_idx = 0

while True:
    ret, frame = cap.read()
    if frame is None:
        print("why no image?")
        continue

    dframe = downscale(frame)

    # pick zone to measure
    zone = zones[zone_idx]
    shape = zone["shape"]

    #reshaping to a list of pixels
    #                [y1:y2, x1:x2]
    img_data = dframe[shape[0][1]:shape[1][1], shape[0][0]:shape[1][0]]

    if KMEANS:
        # BGR (default) to RGB colorspace
        img_data = cv2.cvtColor(img_data, cv2.COLOR_BGR2HSV)

        #using k-means to cluster pixels, get HSV color out
        color = get_dominant_color(img_data, 2)
        s_val = color[1]
        v_val = color[2]

        # boost saturation
        color[1] = s_val + ((255 - s_val) * 0.25)
        # boost brightness
        # color[2] = v_val + ((255 - v_val) * 0.25)

        hsv_color = np.array([[[int(c) for c in color]]], np.uint8)
        bgr_color = cv2.cvtColor(hsv_color, cv2.COLOR_HSV2BGR)
        color = bgr_color[0][0]

        zone["color"] = tuple(int(n) for n in [color[0], color[1], color[2]])
    else:
        img_data = cv2.cvtColor(img_data, cv2.COLOR_BGR2HSV)
        # print("img_slice", img_data[0:1, 0:1])
        hsv_color = np.array([[[int(np.mean(c)) for c in cv2.split(img_data)]]], np.uint8)
        bgr_color = cv2.cvtColor(hsv_color, cv2.COLOR_HSV2BGR)
        # print("bgr_color", bgr_color)
        color = bgr_color[0][0]

        zone["color"] = tuple(int(n) for n in [color[0], color[1], color[2]])

    cv2.rectangle(dframe, (x1, y1), (x2, y2), (255, 0, 0), 1)

    for zone in zones:
        cv2.rectangle(dframe,
            (x1 + zone["shape"][0][0], zone["shape"][0][1]),
            (x1 + zone["shape"][1][0], zone["shape"][1][1]),
            zone["color"],
            -1
        )

    cv2.imshow("dframe", dframe)

    zone_idx = (zone_idx + 1) % len(zones)

    idx = frame_complete(idx, frame_times, frame_waits)
    print("zone", zone_idx, "color", color, "frame time", np.mean(frame_waits))

    k = cv2.waitKey(1) & 0xff
    if k == 27 or k == ord('q'):
        break
