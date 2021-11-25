import json
import requests


API = "http://ip-api.com/json/73.45.23.12"
data = requests.get(API).json()
print(data)
print(json.dumps(data))