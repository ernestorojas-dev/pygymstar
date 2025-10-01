#!/bin/bash
# PyGMTSAR Image Generation Script
# Usage: ./process.sh <test_script> <output_format> [output_dir]

set -e

# Default values
TEST_SCRIPT=${1:-"imperial_valley_2015.py"}
OUTPUT_FORMAT=${2:-"png"}
OUTPUT_DIR=${3:-"/workspace/output"}

echo "=========================================="
echo "PyGMTSAR Image Generation"
echo "=========================================="
echo "Test Script: $TEST_SCRIPT"
echo "Output Format: $OUTPUT_FORMAT"
echo "Output Directory: $OUTPUT_DIR"
echo "=========================================="

# Set environment variables
export DISPLAY=:99
export PYTHONPATH=/opt/conda/lib/python3.12/site-packages

# Start virtual framebuffer
echo "Starting virtual framebuffer..."
Xvfb :99 -screen 0 1280x1024x24 > /dev/null 2>&1 &
XVFB_PID=$!

# Function to cleanup on exit
cleanup() {
    echo "Cleaning up..."
    kill $XVFB_PID 2>/dev/null || true
}
trap cleanup EXIT

# Wait for Xvfb to start
sleep 2
echo "Virtual framebuffer started (PID: $XVFB_PID)"

# Navigate to tests directory
cd /workspace/tests
echo "Working directory: $(pwd)"

# Check if test script exists
if [ ! -f "$TEST_SCRIPT" ]; then
    echo "Error: Test script '$TEST_SCRIPT' not found in $(pwd)"
    echo "Available scripts:"
    ls -la *.py 2>/dev/null || echo "No Python scripts found"
    exit 1
fi

echo "Processing script: $TEST_SCRIPT"

# Create fixed version of the script (remove Colab-specific code)
echo "Creating fixed version of script..."
cat "$TEST_SCRIPT" \
    | sed '/if \x27google\.colab\x27 in sys\.modules:/,/^$/d' \
    | sed 's/^[[:blank:]]*!.*$//' \
    | awk '/username = \x27GoogleColab2023\x27/ {print "if __name__ == \x27__main__\x27:"; indent=1} {if(indent) sub(/^/, "    "); print}' \
    > "$TEST_SCRIPT.fixed.py"

# Set output format in the script if not JPG
if [ "$OUTPUT_FORMAT" != "jpg" ]; then
    echo "Converting output format to $OUTPUT_FORMAT..."
    sed -i "s/\.jpg/.$OUTPUT_FORMAT/g" "$TEST_SCRIPT.fixed.py"
fi

# Create output directory
mkdir -p "$OUTPUT_DIR/$TEST_SCRIPT"

# Run the test script
echo "Running test script..."
python3 "$TEST_SCRIPT.fixed.py"

# Copy generated images to output directory
echo "Copying generated files..."
cp *.jpg *.png *.svg *.pdf 2>/dev/null || true
cp *.jpg *.png *.svg *.pdf "$OUTPUT_DIR/$TEST_SCRIPT/" 2>/dev/null || true

# List generated files
echo "=========================================="
echo "Generated files:"
ls -la "$OUTPUT_DIR/$TEST_SCRIPT/" 2>/dev/null || echo "No files found in output directory"

# Count files by type
echo "=========================================="
echo "File count by type:"
find "$OUTPUT_DIR/$TEST_SCRIPT/" -name "*.jpg" | wc -l | xargs echo "JPG files:"
find "$OUTPUT_DIR/$TEST_SCRIPT/" -name "*.png" | wc -l | xargs echo "PNG files:"
find "$OUTPUT_DIR/$TEST_SCRIPT/" -name "*.svg" | wc -l | xargs echo "SVG files:"
find "$OUTPUT_DIR/$TEST_SCRIPT/" -name "*.pdf" | wc -l | xargs echo "PDF files:"

echo "=========================================="
echo "Test completed successfully!"
echo "Output directory: $OUTPUT_DIR/$TEST_SCRIPT"
echo "=========================================="

