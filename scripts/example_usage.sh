#!/bin/bash
# Example usage of PyGMTSAR image generation scripts

set -e

echo "=========================================="
echo "PyGMTSAR Image Generation Examples"
echo "=========================================="

# Create output directory
mkdir -p ./output

echo "Example 1: Generate Imperial Valley test as PNG"
echo "Command:"
echo "docker run --rm \\"
echo "  -v \"\$(pwd):/workspace\" \\"
echo "  -v \"\$(pwd)/output:/workspace/output\" \\"
echo "  pechnikov/pygmtsar:latest \\"
echo "  /workspace/scripts/process.sh imperial_valley_2015.py png"
echo ""

# Uncomment to run the example:
# docker run --rm \
#   -v "$(pwd):/workspace" \
#   -v "$(pwd)/output:/workspace/output" \
#   pechnikov/pygmtsar:latest \
#   /workspace/scripts/process.sh imperial_valley_2015.py png

echo "Example 2: Generate all tests as SVG using Python script"
echo "Command:"
echo "docker run --rm \\"
echo "  -v \"\$(pwd):/workspace\" \\"
echo "  -v \"\$(pwd)/output:/workspace/output\" \\"
echo "  pechnikov/pygmtsar:latest \\"
echo "  python3 /workspace/scripts/generate_images.py all --format svg"
echo ""

# Uncomment to run the example:
# docker run --rm \
#   -v "$(pwd):/workspace" \
#   -v "$(pwd)/output:/workspace/output" \
#   pechnikov/pygmtsar:latest \
#   python3 /workspace/scripts/generate_images.py all --format svg

echo "Example 3: Generate specific test with custom output directory"
echo "Command:"
echo "docker run --rm \\"
echo "  -v \"\$(pwd):/workspace\" \\"
echo "  -v \"\$(pwd)/custom_output:/workspace/custom_output\" \\"
echo "  pechnikov/pygmtsar:latest \\"
echo "  python3 /workspace/scripts/generate_images.py goldenvalley --format pdf --output-dir /workspace/custom_output"
echo ""

echo "Example 4: Using the existing running container"
echo "If you have a running PyGMTSAR container named 'pygmtsar':"
echo "docker exec pygmtsar /workspace/scripts/process.sh imperial_valley_2015.py png"
echo ""

echo "=========================================="
echo "Available test cases:"
echo "- imperial_valley_2015"
echo "- goldenvalley"
echo "- iran_iraq_earthquake_2017"
echo "- kalkarindji_flooding_2024"
echo "- la_cumbre_volcano_eruption_2020"
echo "- lakesarez_landslides_2017"
echo "- pico_do_fogo_volcano_eruption_2014"
echo "- turkie_earthquakes_2023"
echo "- turkie_elevation_2019"
echo "=========================================="

echo "Available output formats:"
echo "- png (default)"
echo "- jpg"
echo "- svg"
echo "- pdf"
echo "=========================================="

echo "To run any example, uncomment the corresponding section in this script."
echo "Make sure you have the PyGMTSAR Docker image:"
echo "docker pull pechnikov/pygmtsar:latest"

