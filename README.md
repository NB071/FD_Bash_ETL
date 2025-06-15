<p align="center">
  <img src="https://nimabargestan.com/wp-content/uploads/2025/06/FD-Bash-Etl-1.png" alt="ETL Pipeline Diagram" width="500" height="500">
</p>

# 🛠️ FD_Bash_ETL: Delivery Data Pipeline with AWS + Bash

This project implements a complete **ETL (Extract-Transform-Load)** pipeline in **Bash and AWK**, designed to clean and prepare delivery dataset files, convert them to JSON, and optionally visualize them in **Amazon QuickSight (QS)** using a manifest.

---

## 📦 Project Overview

This project processes raw delivery data (`dataset.csv`) through:

1. **Extraction** from remote source (Kaggle)
2. **Transformation** into a clean, validated dataset
3. **Loading** to an AWS S3 bucket
4. **Visualization** via **Amazon QuickSight** with a prepared `manifest.json`

---

## 📁 Project Structure

```text
FD_Bash_ETL/
├── assets/                     # Supporting files
│   ├── delivery_dashboard.pdf  # Exported QuickSight dashboard
│   ├── manifest.json           # Used to load JSON into QuickSight
│   ├── sample_output_console.png
│   └── sample_result_aws_s3.png
├── data/
│   ├── processed/              # Cleaned output
│   │   ├── dataset.json
│   │   └── dataset.csv
│   └── raw/                    # Original raw input
│       └── dataset.csv
├── scripts/
│   ├── 1_extract.sh            # Downloads & unzips dataset
│   ├── 2_transform.sh          # Cleans & validates data using AWK
│   ├── 3_load.sh               # Uploads cleaned files to S3
│   └── main.sh                 # Runs full ETL pipeline
```

---

## 🔧 Requirements

- `bash`
- `awk`
- `curl`
- `unzip`
- [`jq`](https://stedolan.github.io/jq/) (for JSON transformation)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) (configured with `aws configure`)

---

## 🚀 How to Run

Run all stages in order with:

```bash
cd scripts && ./main.sh
```

## ☁️ AWS Setup

- **🪣 S3 Upload**

Ensure you've configured AWS CLI:

```bash
aws configure
```

Your cleaned dataset will be uploaded to:

- s3://`<your-bucket-name>`/`<your-bucket-path>`/dataset.csv
- s3://`<your-bucket-name>`/`<your-bucket-path>`/dataset.json

*where `<your-bucket-name>` & `<your-bucket-path>` are clearly indicated as constants defined inside **3_load.sh** along with other ones*

- **📊 Amazon QuickSight**

To visualize the data in QuickSight:

1. Use `assets/manifest.json` for importing the JSON dataset.
2. In QuickSight, go to `New Dataset → S3 → Upload a manifest file`.
3. Ensure your S3 bucket *permissions* allow QuickSight to access the data.

---

## 🖼️ Sample Visuals

Browse visual assets in the `assets/`folder:
- 📊 `delivery_dashboard.pdf`: Full dashboard export
- ✅ `sample_result_aws_s3.png`: AWS upload confirmation
- 🧪 `sample_output_console.png`: CLI output of transformation stage

---

## 🧾 License

This project is licensed under the MIT License.
