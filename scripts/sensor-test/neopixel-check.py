import time
import board
import neopixel
num_pixels = 12
pixels = neopixel.NeoPixel(board.D18, num_pixels)

while True:

	print("ON")
	pixels.fill((255, 0, 0))
	pixels.show()
	time.sleep(1)
	
	print("OFF")
	pixels.fill((0, 0, 0))
	pixels.show()
	time.sleep(1)
