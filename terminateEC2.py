#!/usr/bin/python
import boto3
import sys

client = boto3.client('autoscaling')

def terminateallEC2(argv):
    response = client.describe_auto_scaling_groups(MaxRecords=1)
    autoscalingfulldetails = response['AutoScalingGroups']
    autoscalegroups = autoscalingfulldetails[0]
    myautoscalinggroup = autoscalegroups['AutoScalingGroupName']
    currentdesiredcapacity = autoscalegroups['DesiredCapacity']
    print("The current running instances are: ", currentdesiredcapacity)
    nocapacity = 0

    try:
        setcapacity = client.set_desired_capacity(
            AutoScalingGroupName=myautoscalinggroup,
            DesiredCapacity=nocapacity,
            HonorCooldown=False,
        )
        print("All instances have been terminated.")
    except:
        print("An error has ocurred, try again.")

if __name__ == "__main__":
   terminateallEC2(sys.argv[1:])