import json
import redis
import os
import logging
import requests
import time

redis_url = os.getenv('REDIS_URL', 'None')

r = redis.from_url(redis_url, decode_responses=True)

API = "http://ip-api.com/json/"


def pull_hackers():
    ret = []
    t = time.time() - (60*60*5)
    for hacker in r.zrangebyscore("hackers", t, time.time()):
        data = r.hgetall(hacker)
        data["time"] = time.strftime('%H:%M:%S', time.localtime(float(hacker)))
        ret.append(data)
    return ret


def populate_redis(user, ip):
    # print(user,ip)
    try:
        if r.exists(ip):
            data = r.hgetall(ip)
        else:
            data = requests.get(API + ip).json()
            r.hmset(ip, {"lon": data["lon"], "lat": data["lat"]})
        # print(data)
        t = time.time()
        # print(t)
        r.hmset(t, {"user": user, "ip": ip,
                "lon": data["lon"], "lat": data["lat"]})
        # print(r.hgetall(t))
        r.zadd("hackers", {t: t})
        # get from a sorted set
        # print(r.zrangebyscore("hackers",t,time.time()))
    except Exception as e:
        logging.error(e)


def parseData(data):
    # rsyslog returns a space infront of data since its coming from part of a log.
    data_arr = list(filter(None, str(data).split(' ')))
    print(f"data: {data_arr}")
    if data_arr[3] in ["root", "pi", "ubuntu"]:
        user = data_arr[3]
        ip = data_arr[5]
    else:
        user = data_arr[5]
        ip = data_arr[7]

    populate_redis(user, ip)


def handler(event, context):
    print(event)
    method = event["requestContext"]["http"]["method"]
    if method == "GET":
        hacker = pull_hackers()
        return {
            "statusCode": 200,
            "body": json.dumps({"list": hacker})
        }

    elif method == "POST":
        message = json.loads(event["body"])["message"]
        parseData(message)
        return {
            "statusCode": 200,
            "body": json.dumps({"message": f"POST Success {message}"})
        }
    else:
        r.flushall()
        return {
            "statusCode": 405,
            "body": json.dumps({"message": "Method not allowed"})
        }


if __name__ == '__main__':
    handler(event={'Records': [{'body': '{"message": "Hello World"}'}]})
