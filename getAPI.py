import boto3

client = boto3.client('apigatewayv2')

def getapiendpoint():
    try:
        apis = client.get_apis(
            MaxResults='1'
        )
        apisfulldetails = apis['Items']
        apiendpoint = apisfulldetails[0]
        myapiendpoint = apiendpoint['ApiEndpoint']
        return(myapiendpoint)
    except:
        return("An error has ocurred, try again.")

getapiendpoint()


