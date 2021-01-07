#!/usr/bin/python3
# -*- coding:utf-8 -*-

#import logging
#import traceback
import sys
import os
from waveshare_epd import epd2in13b_V3
import time
from PIL import Image,ImageDraw,ImageFont

def main():
    if (len(sys.argv) == 3):
        serviceText = sys.argv[1]
        codeText = sys.argv[2]
        print_ePaper(serviceText, codeText)
    elif (len(sys.argv) == 2 and sys.argv[1] == "clear"):
        clear_ePaper()
    else:
        print("Usage: ./print2epaper.py [clear] | [Service 2faCode]")
        exit()

def print_ePaper(serviceText, codeText):
    picdir = os.path.join(os.getenv("HOME"), '.2paco', 'pic')

    try:
        #logging.basicConfig(level=logging.DEBUG)
        #logging.info("2paco.sh is Printing 2FA to ePaper...")
        
        epd = epd2in13b_V3.EPD()
        #logging.info("init and Clear")
        epd.init()
        time.sleep(1)
        
        # Drawing on the image
        #logging.info("Drawing")
        serviceFont = ImageFont.truetype(os.path.join(picdir, 'Font.ttc'), 26)
        codeFont = ImageFont.truetype(os.path.join(picdir, 'Font.ttc'), 58)
        
        # Drawing on the Horizontal image
        #logging.info("1.Drawing on the Horizontal image...") 
        HBlackimage = Image.new('1', (epd.height, epd.width), 255)
        HRYimage = Image.new('1', (epd.height, epd.width), 255)
        
        drawblack = ImageDraw.Draw(HBlackimage)
        drawry = ImageDraw.Draw(HRYimage)
    
        wService, hService = drawblack.textsize(serviceText, font = serviceFont)
        wCode, hCode = drawblack.textsize(codeText, font = codeFont)

        serviceImage = Image.open(os.path.join(picdir, serviceText + '.bmp'))
        HBlackimage.paste(serviceImage, (int((epd.height - wService) / 2) - 32 , 12))
        
        drawblack.text(((epd.height - wService) / 2 + 8, 9), serviceText.upper(), font = serviceFont, fill = 0)
        drawblack.text(((epd.height - wCode) / 2, hService + 13), codeText, font = codeFont, fill = 0)
        
        rotated = HBlackimage.rotate(180.0, expand=1)

        epd.display(epd.getbuffer(rotated), epd.getbuffer(HRYimage))
        
        epd.Dev_exit()
            
    except KeyboardInterrupt:    
        #logging.info("ctrl + c:")
        epd2in13b_V3.epdconfig.module_exit()
        exit()

def clear_ePaper():
    try:
        epd = epd2in13b_V3.EPD()
        epd.init()
        epd.Clear()

    except KeyboardInterrupt:
        epd2in13b_V3.epdconfig.module_exit()
        exit()

if __name__ == "__main__":
    main()
