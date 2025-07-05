#!/bin/bash

# Simple script to add a container to OnDemand
# Usage: ./add_container.sh docker://container_uri

set -e  # Exit on any error

# Check if a Docker URI was provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <docker_uri>"
    echo ""
    echo "Examples:"
    echo "  $0 docker://scr.svc.stanford.edu/bil-public/comp-env/ce"
    echo "  $0 docker://codercom/code-server"
    echo "  $0 docker://jupyter/datascience-notebook"
    echo ""
    echo "This script will:"
    echo "  1. Download the container image"
    echo "  2. Update the form.yml with the new container option"
    exit 1
fi

DOCKER_URI="$1"

echo "Adding container: $DOCKER_URI"
echo ""

# Step 1: Download the container
echo "Step 1: Downloading container..."
if ./download_container.sh "$DOCKER_URI"; then
    echo "✓ Container downloaded successfully"
else
    echo "✗ Container download failed"
    echo ""
    echo "This may be due to memory constraints on login nodes."
    echo "Try submitting as a SLURM job instead:"
    echo "  sbatch download_container.sh $DOCKER_URI"
    echo ""
    echo "After the job completes, run:"
    echo "  ./refresh_form.sh"
    exit 1
fi

echo ""

# Step 2: Update the form
echo "Step 2: Updating form.yml..."
if ./refresh_form.sh; then
    echo "✓ Form updated successfully"
else
    echo "✗ Form update failed"
    exit 1
fi

echo ""
echo "🎉 Container added successfully!"
echo "You can now access it through the OnDemand web interface."