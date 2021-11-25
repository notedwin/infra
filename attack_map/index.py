import json
import boto3
import redis
import os
import logging
import requests
import time

redis_url = os.getenv('REDIS_URL', 'None')

r = redis.from_url(redis_url, decode_responses=True)

API = "http://ip-api.com/json/"

def populate_redis(user,ip):
    print(user,ip)
    try:
        if r.exists(ip):
            data = r.hgetall(ip)
        else:
            data = requests.get(API + ip).json()
            print(data)
            r.hmset(ip,{"lon": data["lon"], "lat": data["lat"]})
        
        t = time.time()
        print(t)
        r.hmset(t,{"user": user, "ip": ip, "lon": data["lon"], "lat": data["lat"]})
        print(r.hgetall(t))
        r.zadd("hackers",{"time": t})
        for hacker in r.zrangebyscore("hackers", 0, time.time()):
            print(hacker)
    except Exception as e:
        print(e)

    
def parseData(data):
    data_arr = str(data).split(' ')
    print(f"data: {data_arr}")
    if (data_arr[3] == "root" or data_arr[3] == "pi"):
        user = data_arr[3]
        ip = data_arr[5]        
        populate_redis(user,ip)
    else:
        user = data_arr[5]
        ip = data_arr[7]
        populate_redis(user,ip)
        
    
        


def handler(event, context):
    if event["httpMethod"] == 'GET':
        return { "statusCode": 404, "body": "Not found" }

    if event["httpMethod"] == 'POST':
        parseData(event["body"])
        return { "statusCode": 200, "body": "Success" }

    return {
        'statusCode': 404,
        'body': "underfined behavior"
    }

if __name__ == '__main__':
    handler(event={'Records': [{'body': '{"message": "Hello World"}'}]})
