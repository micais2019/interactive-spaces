# https://learn.adafruit.com/assets/63404
# https://learn.adafruit.com/adafruit-dotstar-leds/python-circuitpython

# sudo pip3 install adafruit-circuitpython-dotstar

import time
import board
import adafruit_dotstar as dotstar
DOTCOUNT = 24 + (26 * 2)
dots = dotstar.DotStar(board.SCK, board.MOSI, DOTCOUNT, brightness=0.8)

i = 0
while True:
    
    for i in range(DOTCOUNT):
        dots[i] = (0, 100, 255) 
        time.sleep(0.01)
    
    for i in reversed(range(DOTCOUNT)):
        dots[i] = (0, 0, 0) 
        time.sleep(0.01)

    # i = (i + 1) % DOTCOUNT
