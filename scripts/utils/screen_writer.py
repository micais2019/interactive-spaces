#
# hardcoding an 8x6 screen into Dotstar strips, where each screen pixel is 4 dotstars
#
# this technique assumes strips run vertically with screen 0, 0 being top left
# and pixel 0 also being top left
#

COORDS = []

ph = 16 # pixel strip segment length

for y in range(6):
    COORDS.append([])
    for x in range(8):
        ll = ph * (2 * x) + (2 * y)         # upper left pixel in square
        rr = ph * (2 * x + 2) - (2 * y + 1) # upper right pixel in square

        # since this techinque always treats 4 strand pixels like
        COORDS[y].append((
            ll,     rr,
            ll + 1, rr - 1
        ))

def screen_to_pixel(x, y):
    return COORDS[y][x]

##
# Testing
##
if __name__ == "__main__":
    output = []
    for y in range(6):
        rows = ["", ""]
        for x in range(8):
            strip_pixels = screen_to_pixel(x, y)

            rows[0] += "%5i%5i  " % strip_pixels[:2]
            rows[1] += "%5i%5i  " % strip_pixels[2:]

        output.append("\n".join(rows))

    print("\n\n\n".join(output))
