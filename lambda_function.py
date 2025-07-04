import boto3
import json
import time
from datetime import datetime

logs = boto3.client('logs')
s3 = boto3.client('s3')
bucket = 'cw-log-archive-prod'

def lambda_handler(event, context):
    paginator = logs.get_paginator('describe_log_groups')
    for page in paginator.paginate():
        for group in page['logGroups']:
            group_name = group['logGroupName']
            streams = logs.describe_log_streams(
                logGroupName=group_name,
                orderBy='LastEventTime',
                descending=True,
                limit=1
            )
            if not streams['logStreams']:
                continue

            stream = streams['logStreams'][0]['logStreamName']
            log_events = logs.get_log_events(
                logGroupName=group_name,
                logStreamName=stream,
                limit=50,
                startFromHead=False
            )

            data = {
                "logGroup": group_name,
                "logStream": stream,
                "events": log_events['events']
            }

            now = datetime.utcnow().strftime('%Y-%m-%dT%H-%M-%SZ')
            key = f"{group_name.strip('/').replace('/', '_')}/{now}.json"
            s3.put_object(
                Bucket=bucket,
                Key=key,
                Body=json.dumps(data),
                ContentType='application/json'
            )
    return {"status": "done"}
