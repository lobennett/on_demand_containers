#!/bin/bash

#SBATCH --job-name=pull_image
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=4G
#SBATCH --output=./log/pull_image-%j.out
#SBATCH --error=./log/pull_image-%j.err

# Pull apptainer image for containerized processing
# Can be run standalone or as a SLURM job
# 
# IMPORTANT: For large containers, this script may fail with memory errors on login nodes.
# If you encounter "squash error" or memory-related failures, submit this script via SLURM:
#   sbatch pull_image.sh docker://your_container_uri
#
# This script includes SLURM directives at the top for job submission.

set -e  # Exit on any error

# Check if a Docker URI was provided as an argument.
if [ -z "$1" ]; then
    echo "Error: No Docker URI provided."
    echo "Usage: $0 <docker_uri>"
    echo "Example: $0 docker://scr.svc.stanford.edu/bil-public/comp-env/ce"
    exit 1
fi

DOCKER_URI="$1"

# Check if the URI starts with the 'docker://' prefix.
if [[ ! "$DOCKER_URI" == docker://* ]]; then
    echo "Error: Invalid URI format. The URI must start with 'docker://'."
    echo "Usage: $0 <docker_uri>"
    echo "Example: $0 docker://scr.svc.stanford.edu/bil-public/comp-env/ce"
    exit 1
fi

DOCKER_URI="$1"

# Set apptainer directory with fallback logic
if [ -n "$SCRATCH" ] && [ -d "$SCRATCH" ]; then
    APPTAINER_DIR="$SCRATCH/.apptainer/on_demand_containers"
else
    APPTAINER_DIR="$(pwd)/apptainer"
fi

# Generate a valid filename from the Docker URI.
# 1. Remove the 'docker://' prefix.
# 2. Replace '/' and ':' with '_' and create filename.
FILENAME_BASE=$(echo "${DOCKER_URI#docker://}" | tr '/:' '_')
IMAGE_FILE="$APPTAINER_DIR/${FILENAME_BASE}.sif"

# Create the apptainer directory if it doesn't exist.
mkdir -p "$APPTAINER_DIR"

# Check if the image file already exists.
if [ -f "$IMAGE_FILE" ]; then
    echo "Image already exists: $IMAGE_FILE"
    echo "To re-download, please remove the existing file first:"
    echo "  rm $IMAGE_FILE"
    exit 0
fi

echo "Pulling apptainer image..."
echo "Source: $DOCKER_URI"
echo "Destination: $IMAGE_FILE"
echo ""
echo "Note: If this fails with memory errors on login nodes, run with sbatch:"
echo "  sbatch download_container.sh $DOCKER_URI"

# Pull the image using the provided URI and the generated destination path.
apptainer pull "$IMAGE_FILE" "$DOCKER_URI"

echo ""
echo "Successfully pulled image to: $IMAGE_FILE"
echo ""
echo "Next step: Run ./refresh_form.sh to update form.yml with this container option"