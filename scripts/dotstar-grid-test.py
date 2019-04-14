# https://learn.adafruit.com/assets/63404
# https://learn.adafruit.com/adafruit-dotstar-leds/python-circuitpython

import time
import board
import adafruit_dotstar as dotstar
from utils import screen_writer

DOTCOUNT = 192
dots = dotstar.DotStar(board.SCK, board.MOSI, DOTCOUNT, brightness=0.8, auto_write=False)

while True:
    for y in range(6):
        for x in range(8):
            pxls = screen_writer.screen_to_pixel(x, y)

            for pixel in pxls:
                dots[pixel] = (255, 0, 0)
            dots.show()
            time.sleep(0.2) 

            for pixel in pxls:
                dots[pixel] = (0, 0, 0)
            dots.show()
            time.sleep(0.2) 

