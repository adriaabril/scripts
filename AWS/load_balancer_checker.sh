#!/bin/bash

# Get all AWS profiles configured in ~/.aws/config
PROFILES=$(aws configure list-profiles)

# Function to check for ECS clusters
check_ecs_clusters() {
    local profile=$1
    
    clusters=$(aws ecs list-clusters --profile "$profile" --query 'clusterArns' --output text)
    
    if [ -n "$clusters" ]; then
        echo "$clusters"
    fi
}

# Function to check unused load balancers
check_unused_lb() {
    local profile=$1
    
    # Check if the account has any ECS clusters
    ecs_clusters=$(check_ecs_clusters "$profile")
    if [ -n "$ecs_clusters" ]; then
        return  # Skip checking unused LBs if ECS clusters exist
    fi
    
    # Get all load balancers
    lbs=$(aws elbv2 describe-load-balancers --profile "$profile" --query 'LoadBalancers[*].LoadBalancerArn' --output text)
    
    if [ -z "$lbs" ]; then
        return
    fi
    
    for lb_arn in $lbs; do
        
        # Get target groups for the load balancer
        target_groups=$(aws elbv2 describe-target-groups --profile "$profile" --query "TargetGroups[?LoadBalancerArns[?contains(@, '$lb_arn')]].TargetGroupArn" --output text)
        
        if [ -z "$target_groups" ]; then
            echo "Profile: $profile - UNUSED Load Balancer: $lb_arn"
            continue
        fi
        
        # Check if any target group has registered targets
        unused=true
        for tg_arn in $target_groups; do
            targets=$(aws elbv2 describe-target-health --profile "$profile" --target-group-arn "$tg_arn" --query 'TargetHealthDescriptions[*].Target.Id' --output text)
            
            if [ -n "$targets" ]; then
                unused=false
                break
            fi
        done
        
        if [ "$unused" = true ]; then
            echo "Profile: $profile - UNUSED Load Balancer: $lb_arn"
        fi
    done
}

# Iterate through all profiles and check for unused load balancers
for profile in $PROFILES; do
    check_unused_lb "$profile"
done
