#!/bin/bash

# List all security group IDs
all_sgs=$(aws ec2 describe-security-groups --query "SecurityGroups[*].GroupId" --output text)

# List all security groups in use by network interfaces
attached_sgs=$(aws ec2 describe-network-interfaces --query "NetworkInterfaces[].Groups[].GroupId" --output text)

# Find unused security groups
unused_sgs=()
for sg in $all_sgs; do
  if ! echo "$attached_sgs" | grep -q "$sg"; then
    unused_sgs+=("$sg")
  fi
done

# If no unused security groups found, exit
if [ ${#unused_sgs[@]} -eq 0 ]; then
  echo "No unused security groups found."
  exit 0
fi

# Display unused security groups
echo "The following unused Security Groups were found:"
for sg in "${unused_sgs[@]}"; do
  echo "- $sg"
done

# Ask for confirmation to delete
read -p "Do you want to delete these Security Groups? (y/n): " confirm
if [[ $confirm != "y" && $confirm != "Y" ]]; then
  echo "Skipping deletion."
  exit 0
fi

# Delete each unused security group
for sg in "${unused_sgs[@]}"; do
  if aws ec2 delete-security-group --group-id "$sg" 2>/dev/null; then
    echo "Successfully deleted Security Group: $sg"
  else
    echo "Failed to delete Security Group: $sg"
  fi
done

