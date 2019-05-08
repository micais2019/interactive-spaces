# download all data from the 4 MICAVIBE feeds

import sys
import os
import re
import time
import json
import re
from io import StringIO

if sys.version_info < (3, 0):
    print("make sure you're using python3 or python version 3.0 or higher")
    os.exit(1)

import urllib.parse
import http.client

def parse_next_value(instr):
    if not instr:
        return None
    for link in [h.strip() for h in instr.split(';')]:
        if re.match('rel="next"', link):
            try:
                nurl = re.search("<(.+)>", link)[1]
                return nurl
            except:
                print('no URL found in link header', link)
    return None


def download(url, out_file, label):
    source = urllib.parse.urlparse(url)
    conn = http.client.HTTPSConnection(source.hostname, source.port)
    conn.request("GET", url)
    response = conn.getresponse()
    body = response.read()
    body_json = json.loads(body)
    if len(body_json) > 0:
        for record in body_json:
            ts = record['created_epoch']
            line = "{},{}\n".format(record['created_epoch'], record['value'])
            out_file.write(line)
        print(
            "< {} {} ending on {} {} ({} total)".format(
                len(body_json),
                label,
                record['id'], record['created_at'],
                response.getheader('X-Pagination-Total')
            )
        )
        return parse_next_value(response.getheader('Link'))
    return None


def get_all_data(url, file_path, label):
    data = StringIO()
    next_page = download(url, data, label)
    while next_page: 
        time.sleep(1)
        next_page = download(next_page, data, label)
    with open(file_path, 'w') as out_file:
        out_file.write(data.getvalue())
    data.close()


if __name__ == "__main__":
    #
    # https://io.adafruit.com/api/v2/mica_ia/feeds/mood/data
    # https://io.adafruit.com/api/v2/mica_ia/feeds/split-motion/data
    # https://io.adafruit.com/api/v2/mica_ia/feeds/sound/data
    # https://io.adafruit.com/api/v2/mica_ia/feeds/sound-2/data
    #
    destination = "/var/www/app/shared/data/"

    collections = (
        ("Mood", "https://io.adafruit.com/api/v2/mica_ia/feeds/mood/data", destination + 'mood.csv'),
        ("Motion", "https://io.adafruit.com/api/v2/mica_ia/feeds/split-motion/data", destination + 'motion.csv'),
        ("Sound 1", "https://io.adafruit.com/api/v2/mica_ia/feeds/sound/data", destination + 'sound-1.csv'),
        ("Sound 2", "https://io.adafruit.com/api/v2/mica_ia/feeds/sound-2/data", destination + 'sound-2.csv'),
    )

    for label, url, filepath in collections:
        print("---------------------------------------------------------")
        print(time.time(), "getting", url, "into", filepath)
        print("---------------------------------------------------------")
        get_all_data(url, filepath, label)
