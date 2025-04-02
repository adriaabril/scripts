#!/bin/bash

# Get all AWS profiles configured in ~/.aws/config
PROFILES=$(aws configure list-profiles)

for PROFILE in $PROFILES; do
    export AWS_PROFILE=$PROFILE
    CLUSTERS=$(aws eks list-clusters --query "clusters[]" --output text)
        if [ -z "$CLUSTERS" ]; then
        continue
    fi
    for CLUSTER in $CLUSTERS; do
        echo "Profile: $PROFILE"
        echo "    Cluster: $CLUSTER"
        
        # Get the version of the current cluster
        VERSION=$(aws eks describe-cluster --name $CLUSTER --query "cluster.version" --output text)
        
        echo "    Version: $VERSION"
    done
    
    echo "-------------------------------------------------"
done
