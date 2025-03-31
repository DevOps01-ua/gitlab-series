#!/bin/bash

distribution_id=$1
max_checks=5
check_interval=30

# Trigger invalidation
invalidation_id=$(aws cloudfront create-invalidation --distribution-id $distribution_id --paths '/*' --query 'Invalidation.Id' --output text)
echo "Invalidation ID: $invalidation_id"

# Wait for invalidation to complete
checks=0
while [ "$checks" -lt "$max_checks" ]; do
    sleep $check_interval
    status=$(aws cloudfront get-invalidation --distribution-id $distribution_id --id $invalidation_id --query 'Invalidation.Status' --output text)
    echo "Invalidation Status: $status"

    if [ "$status" != "InProgress" ]; then
        echo "Invalidation completed!"
        exit 0
    fi

    ((checks++))
done

echo "Maximum checks reached. Invalidation might still be in progress."