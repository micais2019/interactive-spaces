#####################
## COMPUTER VISION!
## Adapted from: https://software.intel.com/en-us/node/754940
## and: https://docs.opencv.org/3.4/db/d5c/tutorial_py_bg_subtraction.html
#####################
import numpy
import cv2

# defaults
import sys
import signal
import time

METHOD = 'MOG2'
DOWNSCALE = True
WITH_THRESHOLD = False

class SplitMotionDetector:
    def __init__(
        self, event_handler, interval_seconds=10, trigger_interval_seconds=0,
        movement_threshold=10, headless=False, camera_id=-1,
        xsteps=4, ysteps=4
    ):
        self.handler = event_handler
        self.capture_device = None
        self.camera_id = camera_id

        self.trigger_interval_seconds = trigger_interval_seconds
        self.interval_seconds = interval_seconds
        self.movement_threshold = movement_threshold

        self.headless = headless
        self.font = cv2.FONT_HERSHEY_SIMPLEX

        self.fgbg = None

        self.ranges = [ [ None for x in range(xsteps) ] for y in range(ysteps) ]
        self.scores = [ 0 for x in range(xsteps * ysteps) ]
        self.xsteps = xsteps
        self.ysteps = ysteps
        self.wstep = 0
        self.hstep = 0

        self.setup()

    def call_handler(self, handler_method, *args):
        method = getattr(self.handler, handler_method, None)
        if callable(method):
            method(*args)

    def shutdown(self, sig=None, frame=None):
        self.call_handler("on_shutdown")
        print("stop signal detected")
        self.capture_device.release()
        sys.exit(0)

    def setup(self):
        # capture video stream from camera source. -1 -> get any camera
        self.capture_device = cv2.VideoCapture(self.camera_id)

        self.fgbg = cv2.createBackgroundSubtractorMOG2()

        # attach interrupt handler for clean shutdown on SIGINT
        signal.signal(signal.SIGINT, self.shutdown)
        signal.signal(signal.SIGTERM, self.shutdown)

        self.call_handler("on_setup", self)

    def run(self):
        # track time between intervals
        last_interval = time.time()
        last_trigger = time.time()

        # track the maximum motion value per-interval
        max_motion_value = 0

        while True:
            # take a new frame of video
            _, frame = self.capture_device.read()

            if DOWNSCALE:
                dframe = self.__downscale(frame)
            else:
                dframe = frame

            size = dframe.shape[:2]
            blank = numpy.zeros([size[0], size[1], 1], numpy.uint8)

            if self.ranges[0][0] is None:
                height, width = dframe.shape[:2]
                self.wstep = int(width / self.xsteps)
                self.hstep = int(height / self.ysteps)
                self.ranges = [
                    [
                        [
                            x * self.wstep,
                            y * self.hstep,
                            x * self.wstep + self.wstep - 1,
                            y * self.hstep + self.hstep - 1
                        ] for y in range(self.ysteps)
                    ] for x in range(self.xsteps)
                ]

            fgmask = self.__bgdetect(dframe)

            sc = 0
            for row in self.ranges:
                for col in row:
                    subsection = fgmask[col[1]:col[3], col[0]:col[2]]
                    self.scores[sc] = self.__get_motion_score(subsection)
                    if not self.headless:
                        cv2.rectangle(blank, (col[0], col[1]), (col[2], col[3]), (self.scores[sc] * 2), -1)
                        cv2.putText(
                            blank, "%i" % sc, #self.scores[sc],
                            (col[0], col[1] + self.hstep - 4),
                            self.font, 1, 255, 1, cv2.LINE_AA
                        )
                    sc += 1

            self.call_handler('on_update', self.scores)

            now = time.time()

            if not self.headless:
                cv2.imshow("motion", fgmask)
                cv2.imshow("pixel", blank)

            # cv2.imwrite("pixel.png", dframe)
            # exit()

            # send accumulated data every interval_seconds
            if (now - last_interval) > self.interval_seconds:
                self.call_handler("on_interval", self.scores)
                last_interval = now
                max_motion_value = 0

            # cv2.imwrite('/home/pi/images/frame.jpg', mod)
            if cv2.waitKey(1) & 0xFF == 27:
                break

        self.shutdown()

    def __downscale(self, frame):
        """Resize to a smaller frame, go to greyscale and blur slightly."""
        sframe = cv2.resize(frame, None, None, 0.75, 0.75)

        gray = cv2.cvtColor(sframe, cv2.COLOR_BGR2GRAY)
        gray = cv2.GaussianBlur(gray, (21, 21), 0)

        return gray

    def __bgdetect(self, frame):
        """Apply Background Detection algorithm"""
        return self.fgbg.apply(frame)

    def __get_motion_score(self, frame):
        if WITH_THRESHOLD:
            _, thresh = cv2.threshold(frame, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
            mean, score = cv2.meanStdDev(thresh)
            return score[0][0]
        else:
            mean, score = cv2.meanStdDev(frame)
            return score[0][0]
