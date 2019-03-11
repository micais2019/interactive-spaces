#####################
## COMPUTER VISION!
## Adapted from https://software.intel.com/en-us/node/754940
#####################
import numpy
import cv2
from datetime import datetime

class MotionDetector:
    def __init__(
        self, event_handler, interval_seconds=10, movement_threshold=10, headless=False
    ):
        self.handler = event_handler
        self.capture_device = None

        self.frame1 = None
        self.frame2 = None
        self.frame3 = None

        self.interval_seconds = interval_seconds
        self.movement_threshold = movement_threshold

        self.headless = headless
        self.font = cv2.FONT_HERSHEY_SIMPLEX

        self.setup()

    def call_handler(self, handler_method, *args):
        method = getattr(self.handler, handler_method, None)
        if callable(method):
            # print("call {} with args {}".format(handler_method, ', '.join(str(a) for a in args)))
            method(*args)

    def interrupt(self, sig, frame):
        print("stop signal detected")
        self.capture_device.release()
        sys.exit(0)

    def setup(self):
        # capture video stream from camera source. 0 refers to first camera, 1 refers to 2nd and so on.
        self.capture_device = cv2.VideoCapture(0)

        # hold 2 frames as reference
        _, self.frame1 = self.capture_device.read()
        _, self.frame2 = self.capture_device.read()

        # attach interrupt handler for clean shutdown on SIGINT
        signal.signal(signal.SIGINT, self.interrupt)
        signal.signal(signal.SIGTERM, self.interrupt)

        self.call_handler("on_setup", self)

    def run(self):
        # track time between intervals
        last_interval = datetime.utcnow()

        # track the maximum motion value per-interval
        max_motion_value = 0

        while True:
            # take a new frame of video
            _, self.frame3 = self.capture_device.read()
            rows, cols, _ = numpy.shape(self.frame3)
            if not self.headless:
                cv2.imshow("dist", frame3)

            # how far apart are frame1 and frame3?
            dist = self.__dist_map(self.frame1, self.frame3)

            # rotate frames
            self.frame1 = self.frame2
            self.frame2 = self.frame3

            # apply Gaussian smoothing
            mod = cv2.GaussianBlur(dist, (9, 9), 0)

            # apply thresholding
            _, thresh = cv2.threshold(mod, 100, 255, 0)

            # calculate standard deviation test
            _, stDev = cv2.meanStdDev(mod)
            st_dev_value = stDev[0][0]

            max_motion_value = max(st_dev_value, max_motion_value)

            self.call_handler('on_update', st_dev_value)

            # render text to the screen
            if not self.headless:
                cv2.putText(
                    self.frame2,
                    "Standard Deviation - {}".format(round(st_dev_value, 0)),
                    (70, 70),
                    self.font,
                    1,
                    (255, 0, 255),
                    1,
                    cv2.LINE_AA,
                )

            if stDev > self.movement_threshold:
                self.call_handler("on_trigger", st_dev_value, max_motion_value)
                if not self.headless:
                    cv2.imshow("motion", mod)

            # send accumulated data every interval_seconds
            now = datetime.utcnow()
            if (now - last_interval).seconds > self.interval_seconds:
                self.call_handler("on_interval", max_motion_value)

                last_interval = now
                max_motion_value = 0

            # cv2.imwrite('/home/pi/images/frame.jpg', mod)
            if cv2.waitKey(1) & 0xFF == 27:
                break


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

