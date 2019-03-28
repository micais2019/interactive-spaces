import time
import board
import neopixel
pixels = neopixel.NeoPixel(board.D18, 12)

time.sleep(1)
print("ON")
pixels.fill((255, 0, 0))

time.sleep(1)
print("OFF")
pixels.fill((0, 0, 0))
