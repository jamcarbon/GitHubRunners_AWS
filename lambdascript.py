import boto3
import time

region = 'us-east-1'

ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
    print('Loading function')
    instance_ids = []
    response = ec2.describe_instances(Filters=[{'Name': 'instance-type', 'Values': ["t2.micro", "t4g.medium"]}])
    instances_full_details = response['Reservations']

    for instance_detail in instances_full_details:
        group_instances = instance_detail['Instances']

        for instance in group_instances:
            instance_id = instance['InstanceId']
            instance_ids.append(instance_id)

    try:
        responses = ec2.start_instances(
            InstanceIds=[
                instance_ids[0],
            ],

            DryRun=False  # Make it False to test
        )

        print('Initiating instance...')
        print("Instance " + instance_ids[0] + "has been initiated")
    except:
        print("Instance is on a start that can not be started, please wait 5 minutes.")
        time.sleep(300)
        lambda_handler(event, context)
