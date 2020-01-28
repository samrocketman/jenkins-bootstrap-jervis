#!/usr/bin/env python3

import requests

r = requests.get('http://localhost:8080/crumbIssuer/api/json', auth=('user', 'pass'))

print('hello')
