#!/usr/bin/python

import sys, getopt
import boto3

def main(argv):
   # !/usr/bin/python

   ec2 = boto3.resource('ec2')
   client = boto3.client('autoscaling')

   response = client.describe_auto_scaling_groups(MaxRecords=1)
   autoscalingfulldetails = response['AutoScalingGroups']
   autoscalegroups = autoscalingfulldetails[0]
   myautoscalinggroup = autoscalegroups['AutoScalingGroupName']
   currentdesiredcapacity = autoscalegroups['DesiredCapacity']

   print("There are currently ", currentdesiredcapacity, " instances schedule to start or running:", "\n")

   instances = ec2.instances.filter(
      Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
   for instance in instances:
      print(instance.id, instance.instance_type, "\n")

   awscost = currentdesiredcapacity * 0.5

   print("The current cost for all resources deployed in AWS is aproximately: ", "$", awscost, "per hour.")


if __name__ == "__main__":
   main(sys.argv[1:])