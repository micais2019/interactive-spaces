# https://learn.adafruit.com/assets/63404
# https://learn.adafruit.com/adafruit-dotstar-leds/python-circuitpython

import time
import board
import adafruit_dotstar as dotstar
dots = dotstar.DotStar(board.SCK, board.MOSI, 8, brightness=0.8)

i = 0
while True:
    dots[i] = (255, 0, 0) 
    time.sleep(0.05) 
    dots[i] = (0, 0, 0)

    i = (i + 1) % 8
