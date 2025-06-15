#!/bin/bash

# ------------------------------------------------------------------------------
# # 2_transform.sh: Clean and transform delivery dataset
#
# Pre-condition:
#   - dataset.csv exists at ../data/raw/
#   - dataset.csv has exactly 20 columns (including header)
#
# Post-condition:
#   - Cleaned CSV saved to ../data/processed/dataset.csv with:
#       • all fields trimmed (leading/trailing spaces removed)
#       • no "NaN" or empty values
#       • valid delivery_person_age (18–100)
#       • delivery_person_ratings in [0.0, 5.0], formatted to 1 decimal
#       • valid non-zero geo-coordinates: 
#           → lat in [-90, 90], lon in [-180, 180]
#       • order_date normalized to YYYY-MM-DD
#       • weathercondition prefix removed and fields lowercased
#       • categorical text fields lowercased
#       • Festival field mapped: "yes" → 1, "no" → 0
#       • Time_taken(min) stripped to minutes, must be > 0
#
#   - Cleaned JSON saved to ../data/processed/dataset.json with:
#       • structured grouping of delivery, location, timing, and order details
#       • numeric fields properly typed (age, ratings, lat/lon, etc.)
# ------------------------------------------------------------------------------

DATASET_RAW_PATH="../data/raw/dataset.csv"
DATASET_CLEANED_CSV="../data/processed/dataset.csv"
DATASET_CLEANED_JSON="../data/processed/dataset.json"
GEN_NUM_COLS=20

echo "Cleaning CSV: Trimming, validating, and transforming..."

# Copy header to output file
head -n 1 "$DATASET_RAW_PATH" > "$DATASET_CLEANED_CSV"

awk -v out="$DATASET_CLEANED_CSV" -v gNF="$GEN_NUM_COLS" '
BEGIN {
    FS = OFS = ","
    cleaned = 0
    dropped = 0
} 
NR > 1 {
    valid = 1
    if (NF != gNF) { dropped++; next }                                                      # remove malformed rows
    for (i = 1; i <= NF; i++) {
        gsub(/^ *| *$/, "", $i)                                                             # trim spaces
        if (length($i) == 0 || $i == "NaN") { valid = 0; break }                            # skip row if value is NaN or empty after tirm
        if (i == 3 && (int($i) < 18 || int($i) > 100)) { valid = 0; break }                 # 18 < delivery_person_age < 100
        if (i == 4) {                                                                       # 0.0 <= delivery_person_ratings <= 5.0
            if ($i + 0.0 < 0.0 || $i + 0.0 > 5.0) { valid = 0; break } 
            $i = sprintf("%.1f", $i)
        }

        # validate coordinates:
        # - Latitude (columns 5 & 7) must be in [-90, 90] and not 0.0
        # - Longitude (columns 6 & 8) must be in [-180, 180] and not 0.0
        if ((i == 5 || i == 7) && ($i + 0 < -90 || $i + 0 > 90 || $i + 0.0 == 0.0)) { valid = 0; break }
        if ((i == 6 || i == 8) && ($i + 0 < -180 || $i + 0 > 180 || $i + 0.0 == 0.0)) { valid = 0; break }

        if (i == 9){                                                                        # convert order_date to ISO format
            split($i, arr, "-")
            if (length(arr[1]) && length(arr[2]) && length(arr[3])) {
                $i = sprintf("%04d-%02d-%02d", arr[3], arr[2], arr[1])
            } else { valid = 0; break } 
        }
        if (i == 12) {                                                                      # weatherconditions without redundant prefix and in lowercase
            split($i, arr, " ")
            $i = tolower(arr[2])
        }
        if (i == 13 || i == 15 || i == 16 || i == 19) {                                     # lowercase categories
            $i = tolower($i)
        }

        if (i == 17 && ($i + 0 < 0 || $i + 0 > 10)) { valid = 0; break }                    # 0 <= multiple delivery <= 10

        if (i == 18) {                                                                      # convert field Festival(yes/no) -> 1/0
            if (tolower($i) == "yes") {
                $i = 1
            } else if (tolower($i) == "no") {
                $i = 0
            } else { valid = 0; break } 
        }

        if (i == 20) {                                                                      # remove prefix (min) from field Time_taken
            split($i, arr, " ")
            if (arr[2] == 0 || arr[2] < 0) { valid = 0; break } 
            $i = arr[2]
        }

    }
    # add valid rows to output
    if (valid) {
        print $0 >> out
        cleaned++
    } else {
        dropped++
    }
}
END {
    print "#Rows kept/modified: " cleaned > "/dev/stderr"
    print "#Rows dropped: " dropped > "/dev/stderr"
}
' "$DATASET_RAW_PATH"

echo "CSV cleaning complete. Saved to $DATASET_CLEANED_CSV"
echo "Converting cleaned CSV to structured JSON..."

# Convert CSV to structured JSON using jq
jq -sR '
  split("\n") |
  .[1:] |
  map(select(length > 0)) |
  map(split(",")) |
  map({
    "id": .[0],
    "delivery_person": {
      "id": .[1],
      "age": (.[2] | tonumber),
      "rating": (.[3] | tonumber)
    },
    "restaurant_location": {
      "latitude": (.[4] | tonumber),
      "longitude": (.[5] | tonumber)
    },
    "delivery_location": {
      "latitude": (.[6] | tonumber),
      "longitude": (.[7] | tonumber)
    },
    "order_timing": {
      "order_date": .[8],
      "time_ordered": .[9],
      "time_picked": .[10]
    },
    "conditions": {
      "weather": .[11],
      "traffic": .[12],
      "vehicle_condition": (.[13] | tonumber)
    },
    "order_details": {
      "type": .[14],
      "vehicle_type": .[15],
      "multiple_deliveries": (.[16] | tonumber),
      "festival": .[17],
      "city": .[18]
    },
    "delivery_metrics": {
      "time_taken_minutes": (.[19] | tonumber)
    }
  })' "$DATASET_CLEANED_CSV" > "$DATASET_CLEANED_JSON"

echo "JSON transformation complete. Saved to $DATASET_CLEANED_JSON"