#!/bin/sh
# Alejandro @10/26/2026 NMIS-2131 Start an AppFlow flow only when it is not already active
# Usage: start_appflow_flow.sh <flow name> <region>
flow_name="$1"
region="$2"

status=$(aws appflow describe-flow --flow-name "$flow_name" --region "$region" --query flowStatus --output text)
if [ "$status" = "Active" ]; then
  echo "$flow_name is already active, start-flow skipped"
  exit 0
fi

aws appflow start-flow --flow-name "$flow_name" --region "$region"
