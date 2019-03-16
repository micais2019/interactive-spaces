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
DOWNSCALE = False
WITH_THRESHOLD = True

class MotionDetector:
    def __init__(
        self, event_handler, interval_seconds=10, trigger_interval_seconds=0,
        movement_threshold=10, headless=False, camera_id=-1
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

        self.setup()

    def call_handler(self, handler_method, *args):
        method = getattr(self.handler, handler_method, None)
        if callable(method):
            # print("call {} with args {}".format(handler_method, ', '.join(str(a) for a in args)))
            method(*args)

    def shutdown(self, sig=None, frame=None):
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
            # if not self.headless:
            #     cv2.imshow("frame", frame)

            if DOWNSCALE:
                dframe = self.__downscale(frame)
            else:
                dframe = frame

            fgmask = self.__bgdetect(dframe)
            score = self.__get_motion_score(fgmask)

            max_motion_value = max(score, max_motion_value)

            self.call_handler('on_update', score)

            # render text to the screen
            if not self.headless:
                cv2.putText(
                    fgmask,
                    "Standard Deviation - {}".format(round(score, 0)),
                    (70, 70),
                    self.font,
                    1,
                    (255, 0, 255),
                    1,
                    cv2.LINE_AA,
                )

            now = time.time()

            # only trigger every trigger_interval_seconds seconds
            if score > self.movement_threshold and (now - last_trigger) > self.trigger_interval_seconds:
                self.call_handler("on_trigger", score, max_motion_value)
                if not self.headless:
                    cv2.imshow("motion", fgmask)
                last_trigger = now

            # send accumulated data every interval_seconds
            if (now - last_interval) > self.interval_seconds:
                self.call_handler("on_interval", max_motion_value)
                last_interval = now
                max_motion_value = 0

            # cv2.imwrite('/home/pi/images/frame.jpg', mod)
            if cv2.waitKey(1) & 0xFF == 27:
                break

        self.shutdown()

    def __dist_map(self, frame1, frame2):
        """outputs pythagorean distance between two frames"""
        frame1_32 = numpy.float32(frame1)
        frame2_32 = numpy.float32(frame2)
        diff32 = frame1_32 - frame2_32
        norm32 = numpy.sqrt(
            diff32[:, :, 0] ** 2 + diff32[:, :, 1] ** 2 + diff32[:, :, 2] ** 2
        ) / numpy.sqrt(255 ** 2 + 255 ** 2 + 255 ** 2)
        dist = numpy.uint8(norm32 * 255)
        return dist

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
