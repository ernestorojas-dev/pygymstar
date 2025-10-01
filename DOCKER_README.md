# PyGMTSAR Docker Setup - Custom Repository

This repository contains a custom Docker setup for PyGMTSAR (Python InSAR) processing. This guide will help you build and run the Docker container for local InSAR analysis.

## 🚀 Quick Start

### Prerequisites
- Docker installed on your system
- At least 8GB RAM recommended
- 50GB+ free disk space for processing

### Build and Run

```bash
# Clone this repository
git clone <your-repo-link>
cd pygmtsar

# Build the Docker image
docker build . -f docker/pygmtsar.Dockerfile -t pygmtsar:latest --no-cache

# Run the container
docker run -dp 8888:8888 --name pygmtsar pygmtsar:latest

# Get the JupyterLab access URL
docker logs pygmtsar
```

## 📋 What's Included

This Docker image contains:

- **Base Environment**: Jupyter scipy-notebook (2025-01-28)
- **GMTSAR**: Complete GMTSAR toolkit with all dependencies
- **VTK**: VTK 9.3.1 for 3D visualization
- **PyGMTSAR**: Latest version with all Python dependencies
- **Example Notebooks**: Pre-loaded InSAR processing examples
- **Virtual Frame Buffer**: Xvfb for headless operation

## 🎯 Accessing the Application

After running the container, you'll get a JupyterLab URL like:
```
http://127.0.0.1:8888/lab?token=your-token-here
```

Copy this URL and paste it into your web browser to access the PyGMTSAR environment.

## 📁 Repository Structure

```
pygmtsar/
├── docker/
│   ├── pygmtsar.Dockerfile      # Main Docker configuration
│   ├── pygmtsar.ubuntu2204.Dockerfile  # Alternative Ubuntu build
│   ├── requirements.json        # Python dependencies
│   └── requirements.sh          # Dependency management script
├── pygmtsar/                    # PyGMTSAR source code
├── tests/                       # Test examples and notebooks
├── assets/                      # Images and documentation assets
├── notebooks/                   # Example Jupyter notebooks
└── scripts/                     # Utility scripts
```

## 🛠️ Container Management

### Basic Commands

```bash
# Check container status
docker ps

# View container logs
docker logs pygmtsar

# Stop the container
docker stop pygmtsar

# Start the container
docker start pygmtsar

# Remove the container
docker rm pygmtsar

# Remove the image
docker rmi pygmtsar:latest
```

### Advanced Usage

```bash
# Run with custom port
docker run -dp 9999:8888 --name pygmtsar pygmtsar:latest

# Run with volume mounts for data persistence
docker run -dp 8888:8888 \
  -v $(pwd)/data:/home/jovyan/data \
  -v $(pwd)/notebooks:/home/jovyan/notebooks \
  --name pygmtsar pygmtsar:latest

# Run with resource limits
docker run -dp 8888:8888 \
  --memory=8g \
  --cpus=4 \
  --name pygmtsar pygmtsar:latest
```

## 📊 Available Examples

The container includes several example notebooks:

- **Türkiye Earthquakes (2023)**: Large-scale deformation analysis
- **Imperial Valley (2015)**: Groundwater subsidence monitoring
- **Golden Valley (2021)**: Infrastructure subsidence analysis
- **Lake Sarez (2017)**: Landslide monitoring
- **Pico do Fogo (2014)**: Volcanic eruption analysis
- **Iran-Iraq Earthquake (2017)**: Co-seismic interferogram
- **Kalkarindji Flooding (2024)**: Flood extent mapping
- **Erzincan DEM (2019)**: High-resolution elevation mapping

## 🔧 Customization

### Building Custom Images

```bash
# Build with custom tag
docker build . -f docker/pygmtsar.Dockerfile -t my-pygmtsar:v1.0

# Build for specific platform
docker buildx build . -f docker/pygmtsar.Dockerfile \
  --platform linux/amd64 \
  -t pygmtsar:amd64
```

### Environment Variables

```bash
# Run with custom Jupyter settings
docker run -dp 8888:8888 \
  -e JUPYTER_ENABLE_LAB=yes \
  -e JUPYTER_TOKEN=my-custom-token \
  --name pygmtsar pygmtsar:latest
```

## 🐛 Troubleshooting

### Common Issues

**Port 8888 already in use:**
```bash
# Use different port
docker run -dp 9999:8888 --name pygmtsar pygmtsar:latest
```

**Out of memory:**
```bash
# Run with memory limit
docker run -dp 8888:8888 --memory=4g --name pygmtsar pygmtsar:latest
```

**Container won't start:**
```bash
# Check logs for errors
docker logs pygmtsar

# Run interactively for debugging
docker run -it pygmtsar:latest bash
```

**Build failures:**
```bash
# Clean Docker cache
docker system prune -a

# Rebuild with verbose output
docker build . -f docker/pygmtsar.Dockerfile -t pygmtsar:latest --no-cache --progress=plain
```

## 📈 Performance Tips

### For Low-Memory Systems (2-4GB RAM)
- Use `n_jobs=1` for data downloads
- Process smaller datasets
- Close unnecessary browser tabs

### For High-Performance Systems
- Use all available CPU cores
- Increase memory allocation
- Use SSD storage for better I/O

## 🔄 Updating PyGMTSAR

To update the PyGMTSAR library inside the running container:

```bash
# Method 1: Using container terminal
docker exec -it pygmtsar bash
sudo --preserve-env=PATH sh -c "pip3 install -U pygmtsar"

# Method 2: Using JupyterLab terminal
# Execute in a notebook cell:
import sys
!sudo {sys.executable} -m pip install -U pygmtsar
```

## 📚 Additional Resources

- **PyGMTSAR Documentation**: [Official Docs](https://github.com/AlexeyPechnikov/pygmtsar)
- **Docker Documentation**: [Docker Hub](https://hub.docker.com/r/pechnikov/pygmtsar)
- **Interactive Examples**: [Google Colab](https://colab.research.google.com/)
- **AI Assistant**: [InSAR.dev/ai](https://insar.dev/ai)

## 🤝 Contributing

To contribute to this Docker setup:

1. Fork the repository
2. Make your changes
3. Test the Docker build
4. Submit a pull request

## 📄 License

This Docker setup follows the same license as the PyGMTSAR project. See [LICENSE.TXT](LICENSE.TXT) for details.

## 🆘 Support

For issues specific to this Docker setup:

1. Check the troubleshooting section above
2. Review Docker logs: `docker logs pygmtsar`
3. Open an issue in this repository
4. For PyGMTSAR-specific issues, refer to the [official repository](https://github.com/AlexeyPechnikov/pygmtsar)

---

**Note**: This is a custom Docker setup for PyGMTSAR. For the official PyGMTSAR documentation and support, please visit the [official repository](https://github.com/AlexeyPechnikov/pygmtsar).
