#!/bin/bash

# Setup script to dynamically populate form.yml with available container options
# This script scans for .sif files and updates the form.yml with container options

set -e  # Exit on any error

echo "Setting up OnDemand container form options..."

# Set apptainer directory with fallback logic (same as in pull_image.sh and script.sh.erb)
if [ -n "$SCRATCH" ] && [ -d "$SCRATCH" ]; then
    APPTAINER_DIR="$SCRATCH/.apptainer/on_demand_containers"
else
    APPTAINER_DIR="$(pwd)/apptainer"
fi

echo "Scanning for containers in: $APPTAINER_DIR"

# Create apptainer directory if it doesn't exist
mkdir -p "$APPTAINER_DIR"

# Find all .sif files and extract container names
CONTAINER_OPTIONS=""
if [ -d "$APPTAINER_DIR" ]; then
    # Get all .sif files and remove the .sif extension
    for sif_file in "$APPTAINER_DIR"/*.sif; do
        if [ -f "$sif_file" ]; then
            # Extract filename without path and extension
            container_name=$(basename "$sif_file" .sif)
            # Add to options list with proper YAML formatting
            if [ -z "$CONTAINER_OPTIONS" ]; then
                CONTAINER_OPTIONS="      - [\"$container_name\", \"$container_name\"]"
            else
                CONTAINER_OPTIONS="$CONTAINER_OPTIONS\n      - [\"$container_name\", \"$container_name\"]"
            fi
        fi
    done
fi

# If no containers found, provide a helpful message
if [ -z "$CONTAINER_OPTIONS" ]; then
    echo "No .sif files found in $APPTAINER_DIR"
    echo "You can add containers using the download_container.sh script:"
    echo "  ./download_container.sh docker://scr.svc.stanford.edu/bil-public/comp-env/ce"
    echo "Setting up form.yml with placeholder option..."
    CONTAINER_OPTIONS="      - [\"No containers available - run download_container.sh first\", \"\"]"
fi

# Create a backup of the original form.yml
cp form.yml form.yml.backup

# Update form.yml with container options
# Use sed to replace the container options section
sed -i.tmp '/^  container:/,/^  [^ ]/{
    /^  container:/,/^    # Container options will be dynamically populated/ {
        /^    options:/ {
            N
            s/^    options:.*/    options:/
            a\
'"$CONTAINER_OPTIONS"'
        }
    }
}' form.yml

# Clean up temporary file
rm -f form.yml.tmp

echo "Updated form.yml with container options:"
echo -e "$CONTAINER_OPTIONS"

echo "Setup complete! The form.yml has been updated with available container options."
echo "Original form.yml backed up as form.yml.backup"