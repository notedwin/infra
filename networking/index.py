import json
import boto3
import redis

rc = boto3.client('elasticache').describe_cache_clusters()['CacheClusters'][0]

rc.configuration_endpoint.address
rc.configuration_endpoint.port




def handler(event, context):
    if event["httpMethod"] == 'GET':
        return { "statusCode": 404, "body": "Not found" }

    if event["httpMethod"] == 'POST':
        return { "statusCode": 200, "body": event["body"] }

    return {
        'statusCode': 404,
        'body': "underfined behavior"
    }

if __name__ == '__main__':
    handler(event={'Records': [{'body': '{"message": "Hello World"}'}]})
