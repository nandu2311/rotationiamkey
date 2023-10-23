import boto3
from datetime import datetime, timedelta, timezone
import os

sns_client = boto3.client("sns", region_name="ap-south-1")  # Replace with your desired AWS region
sns_topic_arn = os.environ['secretsnstopic']  # Read the environment variable

# sns_client = boto3.client("sns")
# sns_topic_name = "MyAccessKeyRotationTopic"  # Change to your desired SNS topic name
# email_subscription = "nandkishor.sr91@gmail.com"  # Change to your email address

# # Create an SNS topic
# sns_response = sns_client.create_topic(Name=sns_topic_name)
# sns_topic_arn = sns_response['TopicArn']

# # Subscribe an email address to the SNS topic
# sns_client.subscribe(
#     TopicArn=sns_topic_arn,
#     Protocol="email",
#     Endpoint=email_subscription
# )

client = boto3.client("iam")
paginator = client.get_paginator('list_users')

# max_key_age = 90
#excluded_users = ["user1", "user2"] # List of usernames to exclude

max_key_age_minutes = 10

max_key_age_timedelta = timedelta(minutes=max_key_age_minutes)


def rotate_key(key_creation_date):
    current_date = datetime.now(timezone.utc)
    age = (current_date - key_creation_date).total_seconds() / 60
    # age = (current_date - key_creation_date).days
    return age

for response in paginator.paginate():
    for user in response['Users']:
        username = user['UserName']

          # Create a new access key for the user
        response = client.create_access_key(UserName=username)
        access_key_id = response['AccessKey']['AccessKeyId']
        secret_access_key = response['AccessKey']['SecretAccessKey']


        # if username in excluded_users:
        #     # Skip processing excluded users
        #     continue

        listkey = client.list_access_keys(UserName=username)
        for accesskey in listkey['AccessKeyMetadata']:
            accesskey_id = accesskey['AccessKeyId']
            key_creation_date = accesskey['CreateDate']
            age = rotate_key(key_creation_date)
            if age > max_key_age_minutes:
                print(f"Deactivating key for the following user: {username}")
                client.update_access_key(UserName=username, AccessKeyId=accesskey_id, Status='Inactive')
                
            # # Send an SNS notification
            #     message = f"Access key for IAM user {username} has been rotated and deactivated."
            #     sns_client.publish(TopicArn=sns_topic_arn, Message=message, Subject="IAM Access Key Rotation")

            if sns_topic_arn:
                # Send an SNS notification
                message = f"Access key for IAM user {username} has been rotated and deactivated."
                sns_client.publish(TopicArn=sns_topic_arn, Message=message, Subject="IAM Access Key Rotation")
            else:
                print("SNS_TOPIC_ARN environment variable is not set. Skipping SNS notification.")