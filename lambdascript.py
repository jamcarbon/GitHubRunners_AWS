import boto3

client = boto3.client('autoscaling')

def lambda_handler(event, context):
    response = client.describe_auto_scaling_groups(MaxRecords=1)
    autoscalingfulldetails = response['AutoScalingGroups']
    autoscalegroups = autoscalingfulldetails[0]
    myautoscalinggroup = autoscalegroups['AutoScalingGroupName']
    currentdesiredcapacity = autoscalegroups['DesiredCapacity']
    print("The current Kubernetes cluster desired capacity is: ", currentdesiredcapacity)
    desiredcapacity = currentdesiredcapacity + 3

    try:
        setcapacity = client.set_desired_capacity(
            AutoScalingGroupName=myautoscalinggroup,
            DesiredCapacity=desiredcapacity,
            HonorCooldown=False,
        )
        print("The desired capacity has been set to: ", desiredcapacity)
        return("Succesfully added 6 more jobs and Kubernetes cluster desired capacity has been increased by 3.")
    except:
        return("An error has ocurred, please try again.")
    