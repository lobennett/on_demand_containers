#!/bin/bash

# On Sherlock, run this script to pull example apptainer images required for the application. 
current_user=$(whoami)
out_directory=/scratch/users/$current_user/.apptainer

# Make out directory if doesn't exist
mkdir -p $out_directory

# Check directory exists
if [ $? -eq 0 ]; then
    echo "Directory created or already exists: $out_directory"
else
    echo "Failed to create directory: $out_directory"
    exit 1
fi

# Define container images and their names
declare -A containers
containers=(
    ["base"]="docker://ghcr.io/lobennett/base:latest"
)

# Initialize JSON content
json_content="{"

# Pull each container and add to JSON
for container_name in "${!containers[@]}"; do
    apptainer_image="${containers[$container_name]}"
    out_path="$out_directory/${container_name}.sif"

    echo "Pulling $container_name container..."
    apptainer pull "$out_path" "$apptainer_image"

    # Add to JSON content
    if [ "$json_content" != "{" ]; then
        json_content="$json_content,"
    fi
    json_content="$json_content\"$container_name\": \"$out_path\""
done

# Close JSON content
json_content="$json_content}"

# Write to JSON file
json_file="./container_options.json"
echo "$json_content" > "$json_file"

if [ $? -eq 0 ]; then
    echo "Successfully wrote container paths to $json_file"
else
    echo "Failed to write container paths to $json_file"
    exit 1
fi

echo "Container pull process complete."