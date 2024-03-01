import boto3

def lambda_handler(event, context):
    # Initialize DynamoDB client
    dynamodb = boto3.resource('dynamodb')
    table_name = 'Visitors'
    table = dynamodb.Table(table_name)
    
    key = {'id': 'visitors'}
    
    try:
        # Get item to check if it exists
        response = table.get_item(
            Key=key,
            ProjectionExpression='visitor_count'
        )
        
        if 'Item' in response:
            # Item exists, update count
            update_expression = 'SET #counter_alias = #counter_alias + :increment_value'
            expression_attribute_values = {':increment_value': 1}
            expression_attribute_names = {'#counter_alias': 'visitor_count'}

            # Update item
            response = table.update_item(
                Key=key,
                UpdateExpression=update_expression,
                ExpressionAttributeValues=expression_attribute_values,
                ExpressionAttributeNames=expression_attribute_names,
                ReturnValues='ALL_NEW'
            )

            count = response['Attributes']['visitor_count']
            return {
                'statusCode': 200,
                'body': 'Update successful',
                'result': count
            }
        else:
            # Item doesn't exist, create it with initial count
            table.put_item(
                Item={'id': 'visitors', 'visitor_count': 1}
            )
            return {
                'statusCode': 200,
                'body': 'Item created with initial count',
                'result': 1
            }
    except Exception as e:
        # Handle exceptions
        return {
            'statusCode': 500,
            'body': f'Error: {str(e)}'
        }
