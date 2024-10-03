#!/usr/bin/env bash

# Model Downloader Script
#
# This script downloads model files from Hugging Face using the huggingface-cli.
# It processes a specially formatted input string to set the download parameters.
#
# Usage:
#   ./model_downloader.sh <input_string>
#
# Input String Format:
#   The input string should be in the format: "author_model-revision"
#
#   Example: "bartowski_Mistral-7B-Instruct-v0.3-exl2-4_25"
#
#   Where:
#   - "bartowski" is the author
#   - "Mistral-7B-Instruct-v0.3-exl2" is the model name
#   - "4_25" is the revision
#
# The script will process this string to:
#   1. Set the download path: "bartowski/Mistral-7B-Instruct-v0.3-exl2"
#   2. Set the local directory: "/app/models/bartowski_Mistral-7B-Instruct-v0.3-exl2-4_25"
#   3. Set the revision: "4_25"
#
# Example usage:
#   ./model_downloader.sh bartowski_Mistral-7B-Instruct-v0.3-exl2-4_25
#
# This will execute:
#   HF_HUB_ENABLE_HF_TRANSFER=1 huggingface-cli download \
#       bartowski/Mistral-7B-Instruct-v0.3-exl2 \
#       --local-dir models/bartowski_Mistral-7B-Instruct-v0.3-exl2-4_25 \
#       --revision 4_25 \
#       --cache-dir /app/models/.cache

if [ $# -eq 0 ]; then
    echo "Usage: $0 <model_string>"
    exit 1
fi

input_string="$1"

local_dir="/app/models/$input_string"

revision=$(echo "$input_string" | rev | cut -d'-' -f1 | rev)

download_path=$(echo "$input_string" | sed 's/-[^-]*$//')
download_path=$(echo "$download_path" | sed 's/_/\//' )

HF_HUB_ENABLE_HF_TRANSFER=1 huggingface-cli \
    download \
    "$download_path" \
    --local-dir "$local_dir" \
    --revision "$revision" \
    --cache-dir /app/models/.cache