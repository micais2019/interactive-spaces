import time
import digitalio
from micropython import const

from random import random
from math import floor

_DEBOUNCED_STATE = const(0x01)
_UNSTABLE_STATE = const(0x02)
_CHANGED_STATE = const(0x04)

class Debouncer(object):
    """Debounce an input pin or an arbitrary predicate"""

    def __init__(self, io_or_predicate, interval=0.010):
        """Make am instance.
           :param DigitalInOut/function io_or_predicate: the pin (from board) to debounce
           :param int interval: bounce threshold in seconds (default is 0.010, i.e. 10 milliseconds)
        """
        self.state = 0x00
        if isinstance(io_or_predicate, digitalio.DigitalInOut):
            self.function = lambda: io_or_predicate.value
        else:
            self.function = io_or_predicate
        if self.function():
            self._set_state(_DEBOUNCED_STATE | _UNSTABLE_STATE)
        self.previous_time = 0
        self.interval = interval


    def _set_state(self, bits):
        self.state |= bits


    def _unset_state(self, bits):
        self.state &= ~bits


    def _toggle_state(self, bits):
        self.state ^= bits


    def _get_state(self, bits):
        return (self.state & bits) != 0


    def update(self):
        """Update the debouncer state. MUST be called frequently"""
        now = time.monotonic()
        self._unset_state(_CHANGED_STATE)
        current_state = self.function()
        if current_state != self._get_state(_UNSTABLE_STATE):
            self.previous_time = now
            self._toggle_state(_UNSTABLE_STATE)
        else:
            if now - self.previous_time >= self.interval:
                if current_state != self._get_state(_DEBOUNCED_STATE):
                    self.previous_time = now
                    self._toggle_state(_DEBOUNCED_STATE)
                    self._set_state(_CHANGED_STATE)


    @property
    def value(self):
        """Return the current debounced value."""
        return self._get_state(_DEBOUNCED_STATE)


    @property
    def rose(self):
        """Return whether the debounced value went from low to high at the most recent update."""
        return self._get_state(_DEBOUNCED_STATE) and self._get_state(_CHANGED_STATE)


    @property
    def fell(self):
        """Return whether the debounced value went from high to low at the most recent update."""
        return (not self._get_state(_DEBOUNCED_STATE)) and self._get_state(_CHANGED_STATE)

################ END OTHER CODE

import board
import time

def to_switch(pin):
    button = digitalio.DigitalInOut(pin)
    button.direction = digitalio.Direction.INPUT
    button.pull = digitalio.Pull.UP
    return Debouncer(button)

# WIRING: rpi pin to button then button to GND
BUTTONS = [to_switch(pin) for pin in [
    board.D23, # 2
    board.D3,  # 8 
    board.D19, # 6
    board.D12, # 5
    board.D25, # 3
    board.D4,  # 9
    board.D21, # 7
    board.D5,  # 4

    board.D2,  # 0
    board.D27, # 1
]]

# 1. Figure out which pins are connected to which physical buttons
# 2. Reorder COLORS to match BUTTONS index to COLORS index
# 3. Reorder OUTPUTS to match order of buttons from L to R
COLORS = [
    (0, 192, 0),
    (250, 128, 0), # yellow 
    (234, 21, 0),  # orange
    (216, 0, 39),
    (255, 0, 0),
    (108, 0, 147), # (160, 32, 255),
    (0, 64, 255),
    (0, 0, 150),
]


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

def lerp_color(c1, c2, amt):
    from_a = [ c / 255.0 for c in c1 ]
    to_a =   [ c / 255.0 for c in c2 ]

    amt = max(min(amt, 1.0), 0.0)
    lerp = lambda start, stop, amt: (1.0 * amt) * (stop - start) + start

    maxes = [ 255, 255, 255 ]

    return [
        int(lerp(from_a[i], to_a[i], amt) * maxes[i]) for i in range(len(from_a))
    ]

interval_seconds = 0.4
last_interval = time.time()

import board
import adafruit_dotstar as dotstar
DOTCOUNT = 20 # 24 + (26 * 2)
dots = dotstar.DotStar(board.SCK, board.MOSI, DOTCOUNT, brightness=0.8)

h_step = 256 / 8
HUES = [ i * h_step for i in range(8) ]


FADE = 0
SHOW = 1
mode = SHOW

high = 255
low = 0
steps = 0
maxsteps = 400

c = 1
n = 0 

frame = 0

fadesteps = 0
maxfade = 400

while True:
    now = time.time()

    frame += 1

    for bidx in range(len(BUTTONS)):
        button = BUTTONS[bidx]
        button.update()

        if button.fell:
            fadesteps = 0
            print("B ON ", bidx, button.state)
            if bidx == 3:
                interval_seconds = interval_seconds + 0.1
            elif bidx == 7:
                if interval_seconds - 0.1 >= 0: 
                    interval_seconds = interval_seconds - 0.1
            elif bidx == 6:
                n = (n + 8) % 255
            elif bidx == 2:
                n = (n - 8) % 255
            elif bidx == 5:
                if c < DOTCOUNT :
                    c = c + 1
            elif bidx == 1:
                if c > 1:
                    c = c - 1
                
    if not BUTTONS[4].value:
        fadesteps = (fadesteps + 1) % maxfade
        dots.fill(lerp_color((255, 255, 255), (0, 0, 0), fadesteps / maxfade))
        
    elif (now - last_interval) > interval_seconds:
        dots.fill((0, 0, 0))

        for i in range(c):
            dots[floor(random() * DOTCOUNT)] = wheel(n)

        last_interval = now


# The MIT License (MIT)
#
# Copyright (c) 2019 Dave Astels for Adafruit Industries
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Author(s): Dave Astels
#
