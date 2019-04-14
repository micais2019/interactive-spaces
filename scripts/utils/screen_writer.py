#
# hardcoding an 8x6 screen into Dotstar strips, where each screen pixel is 4 dotstars
#
# this technique assumes strips run vertically with screen 0, 0 being top left
# and pixel 0 also being top left
#

COORDS = []

ph = 16 # pixel strip segment length

# strands:

#
# <-----------------------< 0
# >----------------------->
# etc.
#

COORDS = [
 [
     (15, 14, 16, 17), (13, 12, 18, 19), (11, 10, 20, 21), (9, 8, 22, 23), (7, 6, 24, 25), (5, 4, 26, 27), (3, 2, 28, 29), (1, 0, 30, 31)
 ], 
 [
     (47, 46, 48, 49), (45, 44, 50, 51), (43, 42, 52, 53), (41, 40, 54, 55), (39, 38, 56, 57), (37, 36, 58, 59), (35, 34, 60, 61), (33, 32, 62, 63)
 ], 
 [
     (79, 78, 80, 81), (77, 76, 82, 83), (75, 74, 84, 85), (73, 72, 86, 87), (71, 70, 88, 89), (69, 68, 90, 91), (67, 66, 92, 93), (65, 64, 94, 95)
 ], 
 [
     (111, 110, 112, 113), (109, 108, 114, 115), (107, 106, 116, 117), (105, 104, 118, 119), (103, 102, 120, 121), (101, 100, 122, 123), (99, 98, 124, 125), (97, 96, 126, 127)
 ], 
 [
     (143, 142, 144, 145), (141, 140, 146, 147), (139, 138, 148, 149), (137, 136, 150, 151), (135, 134, 152, 153), (133, 132, 154, 155), (131, 130, 156, 157), (129, 128, 158, 159)
 ], 
 [
     (175, 174, 176, 177), (173, 172, 178, 179), (171, 170, 180, 181), (169, 168, 182, 183), (167, 166, 184, 185), (165, 164, 186, 187), (163, 162, 188, 189), (161, 160, 190, 191)
 ], 
]

def screen_to_pixel(x, y):
    """Returns a set of 4 pixel values that correspond to an x,y coordinate"""
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
