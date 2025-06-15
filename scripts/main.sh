#!/bin/bash

# ------------------------------------------------------------------------------
# main.sh
#
# Description:
#   Main driver script for the ETL pipeline.
#   Executes the following steps in sequence:
#     1. Data extraction (download raw dataset)
#     2. Data transformation (clean and convert to JSON)
#     3. Data loading (upload cleaned files to AWS S3)
#
# Usage:
#   Run this script from the project root to execute the full pipeline.
# ------------------------------------------------------------------------------

set -e 

echo "🔍 Step 1: Extracting raw data..."
./1_extract.sh
echo "✅ Extraction complete."

echo "🧹 Step 2: Transforming data..."
./2_transform.sh
echo "✅ Transformation complete."

echo "☁️  Step 3: Loading data to AWS S3..."
./3_load.sh
echo "✅ Data successfully uploaded to S3."

echo "🎉 ETL pipeline completed successfully!"