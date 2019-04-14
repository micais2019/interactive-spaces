# sudo pip3 install python-escpos --pre
import sys

from escpos.printer import Usb

if __name__ == '__main__':
    p = Usb(0x0416, 0x5011)
    p.text('micavibe.com/mood\n\n')
    p.image('tomicavibe_mood.png')
    p.text('\n\n\n\n')

# from escpos.connections import getUSBPrinter
#
# # Bus 020 Device 008:
# #   ID 0416:5011 Winbond Electronics Corp. POS58 USB Printer  Serial: Printer
# printer = getUSBPrinter()(idVendor=0x0416,
#                           idProduct=0x5011) # Create the printer object with the connection params
#
# printer.text("Hello World")
# printer.lf()
#

