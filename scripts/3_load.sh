#!/bin/bash

# ------------------------------------------------------------------------------
# 3_load.sh
#
# Description:
#   This script checks if an AWS S3 bucket exists and creates it if not.
#   Then it uploads the cleaned CSV and JSON dataset files to the specified
#   path within the bucket.
#
# Pre-condition:
#   - AWS CLI is installed and configured with appropriate credentials.
#   - dataset.csv and dataset.json exist in ../data/processed/.
#
# Post-condition:
#   - Files are uploaded to s3://fd-analytics-bucket/cleaned/
#
# Usage:
#   Run this script after cleaning/transformation is complete.
# ------------------------------------------------------------------------------

AWS_BUCKET_NAME="fd-analytics-bucket"
AWS_BUCKET_PATH="cleaned"
AWS_BUCKET_REGION="ca-central-1"
CSV_PATH="../data/processed/dataset.csv"
JSON_PATH="../data/processed/dataset.json"

echo "Checking if S3 bucket '$AWS_BUCKET_NAME' exists..."

# create/check s3 bucket
if aws s3api head-bucket --bucket "$AWS_BUCKET_NAME" 2>/dev/null; then
    echo "AWS Bucket $AWS_BUCKET_NAME already exists."
else
    echo "AWS Bucket $AWS_BUCKET_NAME does not exist. Creating..."
    aws s3api create-bucket \
        --bucket "$AWS_BUCKET_NAME" \
        --region "$AWS_BUCKET_REGION" \
        --create-bucket-configuration LocationConstraint="$AWS_BUCKET_REGION"
    echo "AWS Bucket created."
fi

# upload both cleaned CSV & JSON files
echo "Uploading cleaned CSV file..."
aws s3 cp "$CSV_PATH" s3://$AWS_BUCKET_NAME/$AWS_BUCKET_PATH/dataset.csv
echo "CSV uploaded to s3://$AWS_BUCKET_NAME/$AWS_BUCKET_PATH/dataset.csv"

echo "Uploading cleaned JSON file..."
aws s3 cp "$JSON_PATH" s3://$AWS_BUCKET_NAME/$AWS_BUCKET_PATH/dataset.json
echo "JSON uploaded to s3://$AWS_BUCKET_NAME/$AWS_BUCKET_PATH/dataset.json"

echo "Files uploaded successfully!"
