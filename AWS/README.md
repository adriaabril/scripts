# AWS Related Scripts

## load_balancer_checker.sh
A script I used to identify forgotten load balancers in every account to then safely remove them.

It will look for LB that don't have any targets assigned.

The script will only print those LB in accounts that don't have any ECS cluster
(in case they really are in use for dynamic environments)

### Requirements
- Have a .aws/config set up
