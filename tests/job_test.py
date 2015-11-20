#!/usr/bin/env python
#Created by Sam Gleske
#Reads Jenkins lastBuild API input until a build is finished.
#Prints out console log when build is finished.
#Exits non-zero if failed build or zero if success.

import json
import sys
import time
import urllib

#assume always first argument and first argument is a proper URL to Jenkins
response = {}
STATUS = 0
while True:
    url = urllib.urlopen(sys.argv[1])
    response = json.load(url)
    url.close()
    if not response['building']:
        break
    time.sleep(1)

url = urllib.urlopen(response['url'] + 'consoleText')
console = url.read()
url.close()

if 'SUCCESS' != response['result']:
    STATUS = 1

print console
sys.exit(STATUS)
