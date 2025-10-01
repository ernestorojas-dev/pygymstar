# PyGMTSAR Image Generation Scripts

This directory contains scripts and workflows for generating images from PyGMTSAR test cases using Docker containers.

## Files

- `process.sh` - Bash script for running PyGMTSAR tests in Docker
- `generate_images.py` - Python script for programmatic image generation
- `README.md` - This documentation file

## GitHub Actions Workflow

The main workflow is located at `.github/workflows/save-images.yml` and provides:

### Features

- **Multiple Output Formats**: PNG, JPG, SVG, PDF
- **Multiple Destinations**: Artifacts, Git commits, S3 upload
- **Matrix Strategy**: Run multiple test cases in parallel
- **Manual Triggers**: Workflow dispatch with customizable options
- **Scheduled Runs**: Daily execution at 2 AM UTC
- **Automatic Triggers**: On push to `pygmtsar2` branch

### Usage

#### Manual Trigger

1. Go to Actions tab in GitHub
2. Select "Generate and Save PyGMTSAR Images"
3. Click "Run workflow"
4. Configure options:
   - **Test case**: Choose specific test or "all"
   - **Output format**: PNG, JPG, SVG, or PDF
   - **Destination**: Artifacts, commit, or S3

#### Automatic Triggers

- **Push**: Runs when test files or Docker files change
- **Schedule**: Daily at 2 AM UTC
- **Pull Request**: Runs on PRs to `pygmtsar2` branch

### Output Destinations

#### 1. Artifacts (Default)
- Images saved as GitHub Actions artifacts
- 30-day retention
- Downloadable from Actions UI
- No additional setup required

#### 2. Git Commit
- Images committed to `generated-images/` directory
- Organized by test case
- Requires write permissions to repository
- Good for version control of outputs

#### 3. S3 Upload
- Images uploaded to S3 bucket
- Organized by test case and run number
- Requires AWS credentials in GitHub Secrets:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_DEFAULT_REGION` (optional, defaults to us-east-1)
  - `S3_BUCKET`

## Local Usage

### Using the Bash Script

```bash
# Make script executable
chmod +x scripts/process.sh

# Run in Docker container
docker run --rm \
  -v "$(pwd):/workspace" \
  -v "$(pwd)/output:/workspace/output" \
  pechnikov/pygmtsar:latest \
  /workspace/scripts/process.sh imperial_valley_2015.py png
```

### Using the Python Script

```bash
# Make script executable
chmod +x scripts/generate_images.py

# Run in Docker container
docker run --rm \
  -v "$(pwd):/workspace" \
  -v "$(pwd)/output:/workspace/output" \
  pechnikov/pygmtsar:latest \
  python3 /workspace/scripts/generate_images.py imperial_valley_2015 --format png
```

## Available Test Cases

- `imperial_valley_2015` - Imperial Valley groundwater analysis
- `goldenvalley` - Golden Valley subsidence analysis
- `iran_iraq_earthquake_2017` - Iran-Iraq earthquake co-seismic interferogram
- `kalkarindji_flooding_2024` - Kalkarindji flooding map
- `la_cumbre_volcano_eruption_2020` - La Cumbre volcano eruption
- `lakesarez_landslides_2017` - Lake Sarez landslides SBAS analysis
- `pico_do_fogo_volcano_eruption_2014` - Pico do Fogo volcano eruption
- `turkie_earthquakes_2023` - Türkiye earthquakes analysis
- `turkie_elevation_2019` - Türkiye elevation map

## File Formats

### Raster Images
- **PNG**: Lossless, good for scientific plots
- **JPG**: Smaller file size, good for photos
- **WebP**: Modern format, smaller than PNG

### Vector Images
- **SVG**: Scalable vector graphics, good for diagrams
- **PDF**: Portable document format, good for reports

## Troubleshooting

### Container Issues
- Ensure Docker has sufficient memory (8GB+ recommended)
- Check that output directory is writable
- Verify test scripts exist in `/workspace/tests`

### Permission Issues
- Ensure scripts are executable (`chmod +x`)
- Check container user permissions
- Verify volume mount paths

### Missing Files
- Check that test scripts generate output files
- Verify output format conversion is working
- Look for error messages in container logs

### Large Files
- Use S3 for large binary files
- Consider Git LFS for version control
- Compress images if needed

## Security Best Practices

- Store AWS credentials in GitHub Secrets
- Use least-privilege IAM policies for S3
- Avoid committing large binary files to main branch
- Use dedicated branches for generated content

## Performance Tips

- Use matrix strategy for parallel execution
- Cache Docker layers when possible
- Use appropriate output formats for use case
- Consider file size vs. quality trade-offs

## Examples

### Generate All Test Cases as PNG
```bash
# Via GitHub Actions
# Go to Actions → Run workflow → Select "all" test case, "png" format

# Via local Docker
docker run --rm \
  -v "$(pwd):/workspace" \
  -v "$(pwd)/output:/workspace/output" \
  pechnikov/pygmtsar:latest \
  python3 /workspace/scripts/generate_images.py all --format png
```

### Generate Specific Test as SVG
```bash
docker run --rm \
  -v "$(pwd):/workspace" \
  -v "$(pwd)/output:/workspace/output" \
  pechnikov/pygmtsar:latest \
  python3 /workspace/scripts/generate_images.py imperial_valley_2015 --format svg
```

### Upload to S3
```bash
# Set up AWS credentials in GitHub Secrets, then run workflow with S3 destination
# Or manually upload:
aws s3 sync ./output/ s3://your-bucket/pygmtsar-images/
```

