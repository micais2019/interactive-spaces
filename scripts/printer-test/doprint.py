import sys

from escpos.printer import Usb


def usage():
    print("usage: qr_code.py <content>")


if __name__ == '__main__':
    if len(sys.argv) != 2:
        usage()
        sys.exit(1)

    content = sys.argv[1]

    # Adapt to your needs
    p = Usb(0x0416, 0x5011)
    p.qr(content, center=True)
    p.text('yo, I figured out how to use the printer\n\n')
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

