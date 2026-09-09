#!/bin/bash

SG_ID="sg-0e17db6ab1dfaa76a"
AMI_ID="ami-0220d79f3f480ecf5"
HOST_ID="Z020801033VIO4NL0L0YA"
DOMAIN_NAME="rakesh.bond"

for instance in $@
do
   INSTANCEID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type 't3.micro' \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text)
    
    if [ $instance == "frontend" ]; then
        IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCEID \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text
        )
        RECORD_NAME="rakesh.bond" #frontend name
    else
        IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCEID \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text
        )
        RECORD_NAME="$instance.rakesh.bond" #mongodb.rakesh.bond
    fi 
    echo "IP address = $IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $HOST_ID \
    --change-batch '
    {
        "Comment": "Creating a new A record",
        "Changes": [
            {
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "'$RECORD_NAME'",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [
                {
                    "Value": "'$IP'"
                }
                ]
            }
            }
        ]
    }
    '
    echo "record updated for $instance"
done
