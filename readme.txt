Client Requirement:

1. I have to enable encryption at rest for cloudtrail. The kms key and cloud trail are in eu-west-1 but the bucket ryt store log files is in us-east-1
So I have to create a s3 buckets with same permissions which the older bucket that store log files has

2. Rotate access key for Iam users every 90 days