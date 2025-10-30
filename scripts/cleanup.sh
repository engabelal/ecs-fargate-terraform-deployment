#!/bin/bash
# Cleanup script to destroy all infrastructure and backend resources

set -e

REGION="eu-north-1"
HOSTED_ZONE_ID="Z08774931MPILO50GC8SS"

echo "🗑️  Infrastructure Cleanup Script"
echo "=================================="
echo ""
echo "⚠️  WARNING: This will destroy ALL resources!"
echo ""

# Function to cleanup environment
cleanup_environment() {
    local ENV=$1
    echo ""
    echo "🔴 Cleaning up $ENV environment..."
    
    if [ -d "terraform/environments/$ENV" ]; then
        cd terraform/environments/$ENV
        
        if [ -f "terraform.tfstate" ] || [ -f ".terraform/terraform.tfstate" ]; then
            echo "📋 Planning destroy for $ENV..."
            terraform plan -destroy
            
            read -p "👉 Destroy $ENV environment? (yes/no): " confirm
            if [ "$confirm" = "yes" ]; then
                echo "💥 Destroying $ENV..."
                terraform destroy -auto-approve
                echo "✅ $ENV destroyed"
            else
                echo "⏭️  Skipped $ENV"
            fi
        else
            echo "⚠️  No state found for $ENV"
        fi
        
        cd ../../..
    else
        echo "⚠️  $ENV environment not found"
    fi
}

# Main cleanup flow
echo "Select cleanup option:"
echo "1) Destroy specific environment (dev/staging/prod)"
echo "2) Destroy all environments"
echo "3) Destroy all + backend (S3 + DynamoDB)"
echo "4) Destroy all + backend + Hosted Zone"
echo ""
read -p "Enter option (1-4): " option

case $option in
    1)
        read -p "Enter environment (dev/staging/prod): " env
        cleanup_environment $env
        ;;
    2)
        cleanup_environment "dev"
        cleanup_environment "staging"
        cleanup_environment "prod"
        ;;
    3)
        cleanup_environment "dev"
        cleanup_environment "staging"
        cleanup_environment "prod"
        
        echo ""
        echo "🔴 Cleaning up backend resources..."
        read -p "👉 Destroy backend (S3 + DynamoDB)? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            cd terraform/backend-setup
            terraform destroy -auto-approve
            echo "✅ Backend destroyed"
            cd ../..
        fi
        ;;
    4)
        cleanup_environment "dev"
        cleanup_environment "staging"
        cleanup_environment "prod"
        
        echo ""
        echo "🔴 Cleaning up backend resources..."
        read -p "👉 Destroy backend (S3 + DynamoDB)? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            cd terraform/backend-setup
            terraform destroy -auto-approve
            cd ../..
        fi
        
        echo ""
        echo "🔴 Cleaning up Route53 Hosted Zone..."
        echo "⚠️  This will delete: awsapp.cloudycode.dev"
        read -p "👉 Delete Hosted Zone? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            # Delete all records except NS and SOA
            echo "🗑️  Deleting DNS records..."
            RECORDS=$(aws route53 list-resource-record-sets \
                --hosted-zone-id $HOSTED_ZONE_ID \
                --query 'ResourceRecordSets[?Type != `NS` && Type != `SOA`]' \
                --output json)
            
            if [ "$RECORDS" != "[]" ]; then
                echo "$RECORDS" | jq -c '.[]' | while read record; do
                    NAME=$(echo $record | jq -r '.Name')
                    TYPE=$(echo $record | jq -r '.Type')
                    echo "  Deleting: $NAME ($TYPE)"
                    
                    CHANGE_BATCH=$(cat <<EOF
{
  "Changes": [{
    "Action": "DELETE",
    "ResourceRecordSet": $record
  }]
}
EOF
)
                    aws route53 change-resource-record-sets \
                        --hosted-zone-id $HOSTED_ZONE_ID \
                        --change-batch "$CHANGE_BATCH" > /dev/null
                done
            fi
            
            # Delete hosted zone
            echo "🗑️  Deleting Hosted Zone..."
            aws route53 delete-hosted-zone --id $HOSTED_ZONE_ID
            echo "✅ Hosted Zone deleted"
            echo ""
            echo "⚠️  Remember to update Namecheap DNS settings!"
        fi
        ;;
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "💰 Cost Impact:"
echo "  - Stopped all billable resources"
echo "  - No more charges (except Hosted Zone if kept: \$0.50/month)"
