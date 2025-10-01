# PyGMTSAR Docker Setup Guide

This guide provides comprehensive instructions for building and running the PyGMTSAR (Python InSAR) application using Docker.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Building the Docker Image](#building-the-docker-image)
4. [Running the Container](#running-the-container)
5. [Accessing JupyterLab](#accessing-jupyterlab)
6. [Container Management](#container-management)
7. [Troubleshooting](#troubleshooting)
8. [Advanced Configuration](#advanced-configuration)

## Prerequisites

Before you begin, ensure you have the following installed:

- **Docker**: Version 20.10 or later
- **Docker Compose**: Version 2.0 or later (optional)
- **Git**: For cloning the repository
- **At least 8GB RAM**: Recommended for optimal performance
- **120GB free disk space**: For processing all examples

### System Requirements

| Configuration | RAM | CPU Cores | Disk Space | Performance |
|---------------|-----|-----------|------------|-------------|
| Minimum | 2GB | 1 | 20GB | Basic functionality |
| Recommended | 8GB | 4 | 50GB | Good performance |
| Optimal | 16GB+ | 8+ | 120GB | All examples |

## Quick Start

### Option 1: Use Pre-built Image (Recommended)

```bash
# Pull the pre-built image
docker pull pechnikov/pygmtsar

# Run the container
docker run -dp 8888:8888 --name pygmtsar pechnikov/pygmtsar

# Check the logs for JupyterLab URL
docker logs pygmtsar
```

### Option 2: Build from Source

```bash
# Clone the repository
git clone https://github.com/AlexeyPechnikov/pygmtsar.git
cd pygmtsar

# Build the Docker image
docker build . -f docker/pygmtsar.Dockerfile -t pygmtsar:latest --no-cache

# Run the container
docker run -dp 8888:8888 --name pygmtsar pygmtsar:latest
```

## Building the Docker Image

### Local Build

```bash
# Navigate to the project directory
cd /path/to/pygmtsar

# Build the image (this may take 1-2 hours)
docker build . -f docker/pygmtsar.Dockerfile -t pygmtsar:latest --no-cache
```

### Multi-Architecture Build

For building images for multiple platforms (AMD64 and ARM64):

```bash
# Create and configure buildx builder
docker buildx create --name pygmtsar
docker buildx use pygmtsar
docker buildx inspect --bootstrap

# Build for multiple platforms
docker buildx build . -f docker/pygmtsar.Dockerfile \
    --platform linux/amd64,linux/arm64 \
    --tag pygmtsar:$(date "+%Y-%m-%d") \
    --tag pygmtsar:latest \
    --pull --push --no-cache

# Clean up
docker buildx rm pygmtsar
```

### Build Process Details

The Docker build process includes:

1. **Base Image**: Jupyter scipy-notebook (2025-01-28)
2. **System Dependencies**: Git, curl, jq, csh, zip, htop, mc, netcdf-bin
3. **GMTSAR Installation**: Complete GMTSAR toolkit with dependencies
4. **VTK Installation**: VTK 9.3.1 for 3D visualization
5. **Python Libraries**: PyGMTSAR and visualization dependencies
6. **Virtual Frame Buffer**: Xvfb for headless operation
7. **Example Notebooks**: Pre-loaded Google Colab examples

## Running the Container

### Basic Run Command

```bash
docker run -dp 8888:8888 --name pygmtsar pygmtsar:latest
```

### Advanced Run Options

```bash
# With custom port mapping
docker run -dp 9999:8888 --name pygmtsar pygmtsar:latest

# With volume mounting for persistent data
docker run -dp 8888:8888 \
  -v $(pwd)/data:/home/jovyan/data \
  -v $(pwd)/notebooks:/home/jovyan/notebooks \
  --name pygmtsar pygmtsar:latest

# With resource limits
docker run -dp 8888:8888 \
  --memory=8g \
  --cpus=4 \
  --name pygmtsar pygmtsar:latest

# With environment variables
docker run -dp 8888:8888 \
  -e JUPYTER_ENABLE_LAB=yes \
  -e JUPYTER_TOKEN=your-token \
  --name pygmtsar pygmtsar:latest
```

### Docker Compose (Alternative)

Create a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  pygmtsar:
    image: pygmtsar:latest
    container_name: pygmtsar
    ports:
      - "8888:8888"
    volumes:
      - ./data:/home/jovyan/data
      - ./notebooks:/home/jovyan/notebooks
    environment:
      - JUPYTER_ENABLE_LAB=yes
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 8G
          cpus: '4'
```

Run with:
```bash
docker-compose up -d
```

## Accessing JupyterLab

### 1. Get the Access URL

```bash
# Check container logs for the JupyterLab URL
docker logs pygmtsar
```

The output will contain a URL like:
```
http://127.0.0.1:8888/lab?token=abc123def456...
```

### 2. Open in Browser

Copy the URL from the logs and paste it into your web browser. The URL includes an authentication token for security.

### 3. Access Notebooks

Once in JupyterLab, you'll find:

- **Example Notebooks**: Pre-loaded in the `notebooks/` directory
- **PyGMTSAR Documentation**: Available in the interface
- **Sample Data**: Ready for testing

## Container Management

### Starting and Stopping

```bash
# Start the container
docker start pygmtsar

# Stop the container
docker stop pygmtsar

# Restart the container
docker restart pygmtsar
```

### Monitoring

```bash
# Check container status
docker ps

# View container logs
docker logs pygmtsar

# Monitor resource usage
docker stats pygmtsar

# Execute commands inside container
docker exec -it pygmtsar bash
```

### Updating PyGMTSAR

To update the PyGMTSAR library inside the running container:

```bash
# Method 1: Using JupyterLab terminal
docker exec -it pygmtsar bash
sudo --preserve-env=PATH sh -c "pip3 install -U pygmtsar"

# Method 2: Using notebook cell
import sys
!sudo {sys.executable} -m pip install -U pygmtsar
```

### Data Persistence

```bash
# Create data directories
mkdir -p ./data ./notebooks

# Run with volume mounts
docker run -dp 8888:8888 \
  -v $(pwd)/data:/home/jovyan/data \
  -v $(pwd)/notebooks:/home/jovyan/notebooks \
  --name pygmtsar pygmtsar:latest
```

## Troubleshooting

### Common Issues

#### 1. Port Already in Use

```bash
# Check what's using port 8888
sudo netstat -tulpn | grep :8888

# Use a different port
docker run -dp 9999:8888 --name pygmtsar pygmtsar:latest
```

#### 2. Out of Memory

```bash
# Check available memory
free -h

# Run with memory limits
docker run -dp 8888:8888 --memory=4g --name pygmtsar pygmtsar:latest
```

#### 3. Build Failures

```bash
# Clean Docker cache
docker system prune -a

# Rebuild with verbose output
docker build . -f docker/pygmtsar.Dockerfile -t pygmtsar:latest --no-cache --progress=plain
```

#### 4. Container Won't Start

```bash
# Check container logs
docker logs pygmtsar

# Run in interactive mode for debugging
docker run -it pygmtsar:latest bash
```

### Performance Optimization

#### For Low-Memory Systems (2-4GB RAM)

```bash
# Set n_jobs=1 for downloads
# In notebook cells:
stack = Sentinel1Stack(data_dir, ...)
stack.download(n_jobs=1)  # Use single job for downloads
```

#### For High-Performance Systems

```bash
# Use all available cores
docker run -dp 8888:8888 \
  --cpus=$(nproc) \
  --memory=16g \
  --name pygmtsar pygmtsar:latest
```

## Advanced Configuration

### Custom JupyterLab Configuration

```bash
# Create custom config directory
mkdir -p ./jupyter_config

# Run with custom config
docker run -dp 8888:8888 \
  -v $(pwd)/jupyter_config:/home/jovyan/.jupyter \
  --name pygmtsar pygmtsar:latest
```

### Network Configuration

```bash
# Create custom network
docker network create pygmtsar-network

# Run with custom network
docker run -dp 8888:8888 \
  --network pygmtsar-network \
  --name pygmtsar pygmtsar:latest
```

### Security Configuration

```bash
# Run with custom user
docker run -dp 8888:8888 \
  --user 1000:1000 \
  --name pygmtsar pygmtsar:latest

# Run with read-only filesystem
docker run -dp 8888:8888 \
  --read-only \
  --tmpfs /tmp \
  --name pygmtsar pygmtsar:latest
```

## Example Processing Times

Based on testing on various configurations:

| Analysis Type | Scenes | Bursts | Interferograms | 2GB RAM | 4GB RAM | 8GB RAM |
|---------------|--------|--------|----------------|---------|---------|---------|
| Lake Sarez Landslides | 19 | 38 | 76 | 38 min | 24 min | 17 min |
| Türkiye Earthquake | 4 | 112 | 1 | 62 min | 33 min | 24 min |
| Golden Valley Subsidence | 30 | 30 | 57 | 18 min | 10 min | 7 min |
| Imperial Valley Groundwater | 5 | - | 9 | 21 min | 12 min | 9 min |

## Support and Resources

- **GitHub Repository**: https://github.com/AlexeyPechnikov/pygmtsar
- **PyPI Package**: https://pypi.python.org/pypi/pygmtsar/
- **Interactive Examples**: https://insar.dev
- **AI Assistant**: https://insar.dev/ai
- **Documentation**: https://pechnikov.dev

## License

This project is licensed under the MIT License. See the [LICENSE.TXT](LICENSE.TXT) file for details.

---

**Note**: This documentation is based on PyGMTSAR version 2.x. For older versions, please refer to the specific version documentation.
