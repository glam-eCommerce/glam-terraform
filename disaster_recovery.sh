#!/bin/bash

set -e

# Ping the Singapore region endpoint to check if it's available
if curl --head --fail --silent http://www.glamecommerce.store/ > /dev/null; then
  echo "Singapore region is available"
else
  # Switch to the Tokyo workspace and apply the Terraform configuration
  echo "Singapore region is down! Switching to Tokyo region..."
  cd terraform-glam-jp-backup
  terraform workspace select glam-jp
  terraform apply -auto-approve
fi
