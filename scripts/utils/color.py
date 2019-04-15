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
