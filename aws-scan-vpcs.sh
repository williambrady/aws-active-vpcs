#!/usr/bin/bash
# set -x
#
# Find all VPCs with assets in them. Initial use case is determining where vulnerabiliity scan engines should reside.
#
#####

if [ "$#" -ne 1 ]
  then
  echo -e "\nUsage: $0 aws-profile \n";
  exit 1;
fi

# Set defaults
aws_region="us-east-1"
aws_profile="$1"

# Set simple logging
exectime=`date +%Y-%m-%d-%H%M%S`
log="$exectime-vpc-scan.csv"
errlog="$exectime-vpc-scan-error.log"

# Set pretty SDTOUT options
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
nc='\033[0m'

# Build functions
function aws_test_id (){
  # 1: aws_profile
  aws sts get-caller-identity --profile $1
}

function aws_scan_vpc_resources () {
  # 1: aws_profile
  # 2: aws_region
  echo "Scan EC2 instances for the VPC ID"
  vpc_list=`aws ec2 describe-instances --profile $1 --region $2 | jq -r -c ' .Reservations[] | .Instances[].VpcId ' | uniq`
  echo "$vpc_list"
  # echo "Scan RDS instances for VPC ID"

}

# Get it done.
echo -e "${green}Verify we have access. ${nc}"
aws_test_id $aws_profile
echo -e "${green}Discover VPCs attached to EC2 instances. ${nc}"
aws_scan_vpc_resources $aws_profile $aws_region

echo " "
echo -e "${green}Process Complete.${nc}"
echo " "
