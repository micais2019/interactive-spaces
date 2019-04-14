# https://learn.adafruit.com/assets/63404
# https://learn.adafruit.com/adafruit-dotstar-leds/python-circuitpython

# sudo pip3 install adafruit-circuitpython-dotstar

import time
import board
import adafruit_dotstar as dotstar
DOTCOUNT = 8
dots = dotstar.DotStar(board.SCK, board.MOSI, DOTCOUNT, brightness=0.8)

i = 0
while True:
    dots.fill((255, 0, 0))

    time.sleep(0.2) 

    dots.fill((0, 0, 0))

    time.sleep(0.3) 

    # i = (i + 1) % DOTCOUNT
