#!/bin/bash

BUCKET_NAME="my-nginx-config-bucket"
CONFIG_FILE="test.conf"
LOCAL_PATH="/etc/nginx/nginx.conf"
TEMP_PATH="/tmp/$CONFIG_FILE"

echo "Checking for new configuration in S3..."
if aws s3 cp "s3://$BUCKET_NAME/$CONFIG_FILE" $TEMP_PATH 2>/dev/null; then
    echo "Configuration file downloaded successfully."

    # Check if the downloaded config is different from the existing one
    if ! cmp -s $TEMP_PATH $LOCAL_PATH; then
        echo "New configuration found. Updating Nginx config."
        # Replace the existing Nginx config
        sudo mv $TEMP_PATH $LOCAL_PATH
        # Restart Nginx to apply the new config
        sudo systemctl restart nginx
        echo "Nginx configuration updated and service restarted."
    else
        echo "No changes in Nginx config."
        # Remove the temporary file if no changes
        rm $TEMP_PATH
    fi
else
    echo "Configuration file not found in S3 (404 error). Skipping update."
fi
