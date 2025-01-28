#!/bin/bash
# List all security group IDs
all_sgs=$(aws ec2 describe-security-groups --query "SecurityGroups[*].GroupId" --output text)

# List all security groups in use by network interfaces
attached_sgs=$(aws ec2 describe-network-interfaces --query "NetworkInterfaces[].Groups[].GroupId" --output text)

# Initialize variables
counter=1
batch=()
batch_size=10

# Function to process and delete a batch of security groups
process_batch() {
  if [ ${#batch[@]} -eq 0 ]; then
    return
  fi

  echo "The following unused Security Groups were found:"
  for sg in "${batch[@]}"; do
    echo "- $sg"
  done

  # Ask for confirmation to delete the batch
  read -p "Do you want to delete these Security Groups? (y/n): " confirm
  if [[ $confirm == "y" || $confirm == "Y" ]]; then
    for sg in "${batch[@]}"; do
      delete_output=$(aws ec2 delete-security-group --group-id "$sg" 2>&1)
      if [[ $? -eq 0 ]]; then
        echo "Successfully deleted Security Group: $sg"
      else
        echo "Failed to delete Security Group: $sg"
        echo "Error: $delete_output"
      fi
    done
  else
    echo "Skipping deletion of this batch."
  fi

  # Clear the batch
  batch=()
}

# Find unused security groups and group them in batches
for sg in $all_sgs; do
  if ! echo "$attached_sgs" | grep -q "$sg"; then
    batch+=("$sg")
    if [ ${#batch[@]} -eq $batch_size ]; then
      process_batch
    fi
  fi
done
