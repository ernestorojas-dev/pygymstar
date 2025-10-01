#!/usr/bin/env python3
"""
PyGMTSAR Image Generation Script

This script can be used to generate images from PyGMTSAR test cases
in a Docker container or local environment.

Usage:
    python3 generate_images.py <test_case> [output_format] [output_dir]

Examples:
    python3 generate_images.py imperial_valley_2015
    python3 generate_images.py goldenvalley png
    python3 generate_images.py all svg /tmp/output
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path

def setup_environment():
    """Set up environment variables for headless operation"""
    os.environ['DISPLAY'] = ':99'
    os.environ['PYTHONPATH'] = '/opt/conda/lib/python3.12/site-packages'
    
    # Start virtual framebuffer if not already running
    try:
        subprocess.run(['pgrep', 'Xvfb'], check=True, capture_output=True)
        print("Xvfb already running")
    except subprocess.CalledProcessError:
        print("Starting Xvfb...")
        subprocess.Popen(['Xvfb', ':99', '-screen', '0', '1280x1024x24'], 
                        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def process_test_script(script_path, output_format='png', output_dir='/workspace/output'):
    """Process a single test script and generate images"""
    script_name = Path(script_path).stem
    
    print(f"Processing: {script_name}")
    print(f"Output format: {output_format}")
    print(f"Output directory: {output_dir}")
    
    # Create output directory
    output_path = Path(output_dir) / script_name
    output_path.mkdir(parents=True, exist_ok=True)
    
    # Read and modify the script
    with open(script_path, 'r') as f:
        content = f.read()
    
    # Remove Colab-specific code
    lines = content.split('\n')
    filtered_lines = []
    skip_until_empty = False
    
    for line in lines:
        if 'if \'google.colab\' in sys.modules:' in line:
            skip_until_empty = True
            continue
        if skip_until_empty and line.strip() == '':
            skip_until_empty = False
            continue
        if skip_until_empty:
            continue
        if line.strip().startswith('!'):
            continue
        filtered_lines.append(line)
    
    # Add main section
    modified_content = '\n'.join(filtered_lines)
    if 'if __name__ == \'__main__\':' not in modified_content:
        modified_content += '\n\nif __name__ == \'__main__\':\n    pass\n'
    
    # Change output format if needed
    if output_format != 'jpg':
        modified_content = modified_content.replace('.jpg', f'.{output_format}')
    
    # Write modified script
    modified_script = script_path.replace('.py', '.fixed.py')
    with open(modified_script, 'w') as f:
        f.write(modified_content)
    
    # Run the script
    try:
        result = subprocess.run([sys.executable, modified_script], 
                              capture_output=True, text=True, timeout=1800)
        
        if result.returncode != 0:
            print(f"Error running script: {result.stderr}")
            return False
        
        # Copy generated files to output directory
        current_dir = Path.cwd()
        image_extensions = ['.jpg', '.png', '.svg', '.pdf']
        
        copied_files = []
        for ext in image_extensions:
            for file_path in current_dir.glob(f'*{ext}'):
                dest_path = output_path / file_path.name
                file_path.rename(dest_path)
                copied_files.append(dest_path)
        
        print(f"Generated {len(copied_files)} files:")
        for file_path in copied_files:
            print(f"  - {file_path}")
        
        return True
        
    except subprocess.TimeoutExpired:
        print("Script execution timed out (30 minutes)")
        return False
    except Exception as e:
        print(f"Error executing script: {e}")
        return False
    finally:
        # Clean up modified script
        if os.path.exists(modified_script):
            os.remove(modified_script)

def main():
    parser = argparse.ArgumentParser(description='Generate PyGMTSAR images')
    parser.add_argument('test_case', help='Test case name or "all" for all tests')
    parser.add_argument('--format', '-f', default='png', 
                       choices=['png', 'jpg', 'svg', 'pdf'],
                       help='Output format (default: png)')
    parser.add_argument('--output-dir', '-o', default='/workspace/output',
                       help='Output directory (default: /workspace/output)')
    parser.add_argument('--tests-dir', '-t', default='/workspace/tests',
                       help='Tests directory (default: /workspace/tests)')
    
    args = parser.parse_args()
    
    # Set up environment
    setup_environment()
    
    # Change to tests directory
    tests_dir = Path(args.tests_dir)
    if not tests_dir.exists():
        print(f"Tests directory not found: {tests_dir}")
        sys.exit(1)
    
    os.chdir(tests_dir)
    
    # Get list of test scripts
    if args.test_case == 'all':
        test_scripts = list(tests_dir.glob('*.py'))
    else:
        test_script = tests_dir / f"{args.test_case}.py"
        if not test_script.exists():
            print(f"Test script not found: {test_script}")
            sys.exit(1)
        test_scripts = [test_script]
    
    # Process each script
    success_count = 0
    for script in test_scripts:
        if process_test_script(script, args.format, args.output_dir):
            success_count += 1
    
    print(f"\nCompleted: {success_count}/{len(test_scripts)} tests successful")
    
    if success_count == 0:
        sys.exit(1)

if __name__ == '__main__':
    main()

