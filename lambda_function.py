import json
import logging
from datetime import datetime

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Lambda function handler for containerized deployment
    """
    logger.info("Lambda function started")
    logger.info(f"Event: {json.dumps(event)}")
    
    try:
        # Get request details
        request_id = context.aws_request_id
        function_name = context.function_name
        function_version = context.function_version
        memory_limit = context.memory_limit_in_mb
        
        # Process the event
        if 'name' in event:
            greeting = f"Hello, {event['name']}!"
        else:
            greeting = "Hello from containerized Lambda!"
        
        # Create response
        response = {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "message": greeting,
                "timestamp": datetime.utcnow().isoformat(),
                "request_id": request_id,
                "function_name": function_name,
                "function_version": function_version,
                "memory_limit_mb": memory_limit,
                "input_event": event
            })
        }
        
        logger.info(f"Response: {json.dumps(response)}")
        return response
        
    except Exception as e:
        logger.error(f"Error processing request: {str(e)}")
        return {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps({
                "error": "Internal server error",
                "message": str(e),
                "timestamp": datetime.utcnow().isoformat()
            })
        }
