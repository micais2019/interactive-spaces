#!/usr/bin/env bash

# run the micavibe book cover generator with datetime & index values
SKETCH_HOME=/Users/adam/projects/MICA/interactive-spaces-code/image-generation/compositor_3d
#                                           run for time
#                                           |          index value
#                                           |          |     one_shot?
#                                           |          |     |
processing-java --sketch=$SKETCH_HOME --run 1556032680 18230 true

# 1.5 ratio
# 2048 x 1365
