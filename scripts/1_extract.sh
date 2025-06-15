#!/bin/bash

# ------------------------------------------------------------------------------
# 1_extract.sh
#
# Description:
#   Checks if the raw dataset already exists. If not, downloads it from Kaggle,
#   unzips the required CSV file, renames it, and cleans up the zip file.
#
# Requirements:
#   - 'unzip' and 'curl' must be available in your system
#
# Usage:
#   Run this script from the root of the project to fetch the dataset.
# ------------------------------------------------------------------------------

if test -f "./../data/raw/dataset.csv"; then
    echo "raw dataset already exists, moving to the next phase..."
    exit 0
fi

echo "Downloading dataset..."
curl -L -o ./../data/raw/food-delivery-dataset.zip https://www.kaggle.com/api/v1/datasets/download/gauravmalik26/food-delivery-dataset

echo "Unzipping dataset..."
cd ./../data/raw || exit 1
unzip -o food-delivery-dataset.zip train.csv

echo "Renaming file..."
mv train.csv dataset.csv

echo "Cleaning up..."
rm food-delivery-dataset.zip 

