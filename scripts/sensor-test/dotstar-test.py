# https://learn.adafruit.com/assets/63404
# https://learn.adafruit.com/adafruit-dotstar-leds/python-circuitpython

# sudo pip3 install adafruit-circuitpython-dotstar

import time
import board
import adafruit_dotstar as dotstar
DOTCOUNT = 16 # 24 + (26 * 2)
dots = dotstar.DotStar(board.SCK, board.MOSI, DOTCOUNT, brightness=0.8)

def wheel(pos):
    """
    Input a hue value from 0 to 255 to get a color value in (r, g, b) format.
    The colours are a transition r - g - b - back to r.
    """
    if pos < 0 or pos > 255:
        r = g = b = 0
    elif pos < 85:
        r = int(pos * 3)
        g = int(255 - pos*3)
        b = 0
    elif pos < 170:
        pos -= 85
        r = int(255 - pos*3)
        g = 0
        b = int(pos*3)
    else:
        pos -= 170
        r = 0
        g = int(pos*3)
        b = int(255 - pos*3)
    return (r, g, b)

i = 0
while True:
    
    for i in range(100, 256):
        c = wheel(i)
        print("{} {}".format(i, c))
        dots.fill(c) 
        time.sleep(0.1)

    # i = (i + 1) % DOTCOUNT
