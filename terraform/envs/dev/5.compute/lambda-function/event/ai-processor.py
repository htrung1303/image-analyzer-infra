import json
import boto3
import os
from datetime import datetime
import logging
import base64
from openai import OpenAI

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
s3_client = boto3.client('s3')
sqs_client = boto3.client('sqs')
client = OpenAI()

def lambda_handler(event, context):
    """
    Process image analysis requests from SQS worker queue
    """
    try:
        logger.info(f"Processing {len(event['Records'])} message(s)")
        
        for record in event['Records']:
            # Parse the SQS message
            message_body = json.loads(record['body'])
            logger.info(f"Processing message: {message_body}")
            
            # Extract image information from the message
            image_id = message_body.get('image_id')
            
            if not image_id:
                logger.error("Missing image_id in message")
                continue
            
            # Construct S3 key from image_id
            bucket_name = os.environ['S3_IMAGES_BUCKET']
            image_key = f"images/{image_id}"
            
            # Download image from S3
            local_image_path = f"/tmp/{image_id}"
            
            try:
                s3_client.download_file(bucket_name, image_key, local_image_path)
                logger.info(f"Downloaded image: {image_key}")
            except Exception as e:
                logger.error(f"Failed to download image {image_key}: {str(e)}")
                continue
            
            # Convert image to Base64
            try:
                with open(local_image_path, 'rb') as image_file:
                    image_data = image_file.read()
                    image_base64 = base64.b64encode(image_data).decode('utf-8')
                logger.info(f"Converted image to Base64, size: {len(image_base64)} characters")
            except Exception as e:
                logger.error(f"Failed to convert image to Base64: {str(e)}")
                continue
            
            # Perform AI analysis with Base64 image
            analysis_result = perform_image_analysis(image_base64)
            
            # Send result back to ECS via SQS results queue
            result_message = {
                'image_id': image_id,
                'status': 'completed',
                'analysis': analysis_result,
                'timestamp': datetime.utcnow().isoformat()
            }
            
            sqs_client.send_message(
                QueueUrl=os.environ['SQS_RESULTS_QUEUE_URL'],
                MessageBody=json.dumps(result_message)
            )
            
            logger.info(f"Analysis completed for image {image_id}")
            
        return {
            'statusCode': 200,
            'body': json.dumps('Processing completed successfully')
        }
        
    except Exception as e:
        logger.error(f"Error processing messages: {str(e)}")
        raise

def perform_image_analysis(image_base64):
    response = client.responses.create(
        model="gpt-4.1",
        input=[
            {
                "role": "user",
                "content": [
                    { "type": "input_text", "text": "What's in this image? Please return a simple answer with list of objects" },
                    {
                        "type": "input_image",
                        "image_url": f"data:image/jpeg;base64,{image_base64}",
                    },
                ],
            }
        ],
    )

    return response.output_text