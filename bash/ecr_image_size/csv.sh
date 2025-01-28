#!/bin/bash

# Ensure 'bc' command is installed before proceeding
if ! command -v bc >/dev/null 2>&1; then
    echo "Error: 'bc' is required but not installed. Please install 'bc' to proceed."
    exit 1
fi

# Ensure 'aws' CLI is installed before proceeding
if ! command -v aws >/dev/null 2>&1; then
    echo "Error: 'aws' CLI is required but not installed. Please install 'aws' to proceed."
    exit 1
fi

# Ensure 'jq' command is installed before proceeding
if ! command -v jq >/dev/null 2>&1; then
    echo "Error: 'jq' is required but not installed. Please install 'jq' to proceed."
    exit 1
fi

# Output CSV file
output_file="ecr_image_sizes.csv"
echo "Repository Name,Image Size (MB)" > $output_file

# Fetch the list of ECR repositories
repos=$(aws ecr describe-repositories --query 'repositories[*].repositoryName' --output text)

# Check if repositories were found
if [ -z "$repos" ]; then
    echo "No ECR repositories found."
    exit 1
fi

# Loop through each repository and fetch image details
for repo in $repos; do
    echo "Processing repository: $repo"

    # Fetch the image details for the repository
    images=$(aws ecr list-images --repository-name $repo --query 'imageIds[*]' --output json)

    if [ "$images" == "[]" ]; then
        echo "  No images found in repository."
        continue
    fi

    # Fetch details for the last image in the repository
    image_details=$(aws ecr describe-images --repository-name $repo --query 'imageDetails[-1]' --output json)

    # Parse details of the last image
    image_size=$(echo $image_details | jq -r '.imageSizeInBytes')

    if [ "$image_size" == "null" ]; then
        echo "  No size information available for the last image."
        continue
    fi

    # Convert size from bytes to MB for readability
    image_size_mb=$(echo "scale=2; $image_size / 1000 / 1000" | bc)

    # Append the repository name and image size to the CSV file
    echo "$repo,$image_size_mb" >> $output_file

done

# Notify the user of the output location
echo "ECR image size details have been saved to $output_file."
