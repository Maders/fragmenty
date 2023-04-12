#!/bin/bash

if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install jq and try again."
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo "Error: git is not installed. Please install git and try again."
    exit 1
fi

# Read input JSON from Terraform
input=$(cat)
# Extract the "module" value from the input JSON
input_module=$(echo "$input" | jq -r '.module')
if [ -z "$input_module" ]; then
    echo "Error: No module provided in the input JSON."
    exit 1
fi

# Find the matching submodule and store the result
git submodule status | grep $input_module | while read -r line; do
    sha=$(echo $line | cut -d' ' -f1)
    module_path=$(echo $line | cut -d' ' -f2)
    module_name=$(basename $module_path)
    jq -n --arg module_name "sha_commit" --arg sha "$sha" '{($module_name): $sha}'
    break
done
