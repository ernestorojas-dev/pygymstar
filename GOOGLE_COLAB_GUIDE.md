# PyGMTSAR Google Colab Setup Guide

This guide will help you run PyGMTSAR (Python InSAR) processing on Google Colab. Google Colab provides free access to GPU/CPU resources and is perfect for InSAR analysis without needing powerful local hardware.

## 🚀 Quick Start

### Step 1: Open Google Colab
1. Go to [Google Colab](https://colab.research.google.com/)
2. Sign in with your Google account
3. Create a new notebook or open an existing one

### Step 2: Install PyGMTSAR
Copy and paste this code into the first cell of your notebook:

```python
# PyGMTSAR Installation for Google Colab
import platform, sys, os

if 'google.colab' in sys.modules:
    # Install PyGMTSAR stable version from PyPI
    !{sys.executable} -m pip install -q pygmtsar
    
    # Install GMTSAR binaries and dependencies
    import importlib.resources as resources
    with resources.as_file(resources.files('pygmtsar.data') / 'google_colab.sh') as google_colab_script_filename:
        !sh {google_colab_script_filename}
    
    # Enable custom widget manager for interactive plots
    from google.colab import output
    output.enable_custom_widget_manager()
    
    # Initialize virtual framebuffer for 3D visualization
    import xvfbwrapper
    display = xvfbwrapper.Xvfb(width=800, height=600)
    display.start()

# Set up PATH for GMTSAR binaries
PATH = os.environ['PATH']
if PATH.find('GMTSAR') == -1:
    PATH = os.environ['PATH'] + ':/usr/local/GMTSAR/bin/'

# Verify installation
from pygmtsar import __version__
print(f"PyGMTSAR version: {__version__}")
```

### Step 3: Import Required Libraries
```python
# Import PyGMTSAR and other required libraries
import pygmtsar
import xarray as xr
import numpy as np
import pandas as pd
import geopandas as gpd
import matplotlib.pyplot as plt
import pyvista as pv
import panel
from dask.distributed import Client
import dask

# Configure plotting
plt.rcParams['figure.figsize'] = [12, 4]
plt.rcParams['figure.dpi'] = 100
pv.set_plot_theme("document")
panel.extension(comms='ipywidgets')
panel.extension('vtk')

print("All libraries imported successfully!")
```

## 📋 Complete Setup Template

Here's a complete template you can copy and use:

```python
# =============================================================================
# PyGMTSAR Google Colab Setup - Complete Template
# =============================================================================

# 1. Installation
import platform, sys, os

if 'google.colab' in sys.modules:
    print("Installing PyGMTSAR and dependencies...")
    !{sys.executable} -m pip install -q pygmtsar
    
    import importlib.resources as resources
    with resources.as_file(resources.files('pygmtsar.data') / 'google_colab.sh') as google_colab_script_filename:
        !sh {google_colab_script_filename}
    
    from google.colab import output
    output.enable_custom_widget_manager()
    
    import xvfbwrapper
    display = xvfbwrapper.Xvfb(width=800, height=600)
    display.start()
    print("Installation completed!")

# 2. Environment Setup
PATH = os.environ['PATH']
if PATH.find('GMTSAR') == -1:
    PATH = os.environ['PATH'] + ':/usr/local/GMTSAR/bin/'

# 3. Import Libraries
import pygmtsar
import xarray as xr
import numpy as np
import pandas as pd
import geopandas as gpd
import matplotlib.pyplot as plt
import pyvista as pv
import panel
from dask.distributed import Client
import dask
from contextlib import contextmanager

# 4. Configure Visualization
plt.rcParams['figure.figsize'] = [12, 4]
plt.rcParams['figure.dpi'] = 100
plt.rcParams['figure.titlesize'] = 24
plt.rcParams['axes.titlesize'] = 14
plt.rcParams['axes.labelsize'] = 12

pv.set_plot_theme("document")
panel.extension(comms='ipywidgets')
panel.extension('vtk')

# 5. Display Version
from pygmtsar import __version__
print(f"✅ PyGMTSAR version: {__version__}")
print("✅ Setup completed successfully!")
```

## 🎯 Example: Basic InSAR Processing

Here's a complete example of processing Sentinel-1 data:

```python
# =============================================================================
# Example: Türkiye Earthquakes 2023 Analysis
# =============================================================================

# 1. Define data directory and DEM
data_dir = '/content/data'
dem_file = '/content/dem.tif'

# 2. Initialize Sentinel-1 stack
stack = pygmtsar.Sentinel1Stack(data_dir, dem_file)

# 3. Define area of interest (Türkiye earthquake region)
# WKT format for the earthquake area
wkt = """
POLYGON((36.0 37.0, 37.5 37.0, 37.5 38.5, 36.0 38.5, 36.0 37.0))
"""

# 4. Download Sentinel-1 data
print("Downloading Sentinel-1 data...")
stack.download(wkt=wkt)

# 5. Process interferograms
print("Processing interferograms...")
stack.intf()

# 6. Perform SBAS analysis
print("Performing SBAS analysis...")
stack.sbas()

# 7. Generate velocity map
print("Generating velocity map...")
velocity = stack.velocity()

# 8. Display results
velocity.plot(figsize=(12, 8))
plt.title('Ground Velocity Map - Türkiye Earthquakes 2023')
plt.show()
```

## 🔧 Advanced Configuration

### Memory Management
```python
# Configure Dask for better memory management
import dask
dask.config.set({
    'array.slicing.split_large_chunks': True,
    'array.chunk-size': '128MB'
})

# Start Dask client for parallel processing
client = Client()
print(f"Dask dashboard: {client.dashboard_link}")
```

### Custom Area of Interest
```python
# Define custom area using coordinates
# Format: (min_lon, min_lat, max_lon, max_lat)
area_of_interest = (36.0, 37.0, 37.5, 38.5)

# Convert to WKT format
wkt = f"""
POLYGON(({area_of_interest[0]} {area_of_interest[1]}, 
         {area_of_interest[2]} {area_of_interest[1]}, 
         {area_of_interest[2]} {area_of_interest[3]}, 
         {area_of_interest[0]} {area_of_interest[3]}, 
         {area_of_interest[0]} {area_of_interest[1]}))
"""
```

## 📊 Available Examples

### 1. Earthquake Analysis
```python
# Central Türkiye Earthquakes (2023)
# Large-scale deformation analysis covering 56 bursts
wkt = "POLYGON((36.0 37.0, 37.5 37.0, 37.5 38.5, 36.0 38.5, 36.0 37.0))"
```

### 2. Volcanic Monitoring
```python
# Pico do Fogo Volcano Eruption (2014)
# Volcanic deformation mapping
wkt = "POLYGON((-24.4 14.8, -24.2 14.8, -24.2 15.0, -24.4 15.0, -24.4 14.8))"
```

### 3. Ground Subsidence
```python
# Imperial Valley Groundwater Subsidence (2015)
# Groundwater-related subsidence monitoring
wkt = "POLYGON((-115.8 32.6, -115.4 32.6, -115.4 33.0, -115.8 33.0, -115.8 32.6))"
```

## 🎨 Visualization Examples

### 3D Interactive Maps
```python
# Create 3D visualization
import pyvista as pv

# Load velocity data
velocity_data = stack.velocity()

# Create 3D plot
plotter = pv.Plotter()
plotter.add_mesh(velocity_data, cmap='RdBu_r')
plotter.show()
```

### Time Series Analysis
```python
# Plot time series for specific points
import matplotlib.pyplot as plt

# Get time series data
ts_data = stack.timeseries()

# Plot for specific coordinates
plt.figure(figsize=(12, 6))
plt.plot(ts_data.time, ts_data.sel(lon=36.5, lat=37.5, method='nearest'))
plt.title('Time Series - Ground Deformation')
plt.xlabel('Time')
plt.ylabel('Displacement (mm)')
plt.show()
```

## ⚡ Performance Optimization

### For Free Colab (Limited Resources)
```python
# Use single job for downloads to avoid memory issues
stack.download(wkt=wkt, n_jobs=1)

# Process smaller areas
# Limit to 2-3 scenes for free Colab
```

### For Colab Pro (More Resources)
```python
# Use multiple jobs for faster processing
stack.download(wkt=wkt, n_jobs=4)

# Process larger areas
# Can handle 10+ scenes
```

## 🐛 Troubleshooting

### Common Issues

**1. Installation Fails**
```python
# Try alternative installation
!pip install --upgrade pip
!pip install pygmtsar --no-cache-dir
```

**2. Memory Issues**
```python
# Restart runtime and run setup again
# Runtime -> Restart Runtime
```

**3. GMTSAR Not Found**
```python
# Check PATH
import os
print(os.environ['PATH'])

# Manually add GMTSAR to PATH
os.environ['PATH'] += ':/usr/local/GMTSAR/bin/'
```

**4. Visualization Issues**
```python
# Re-enable widgets
from google.colab import output
output.enable_custom_widget_manager()
```

## 📚 Pre-built Examples

### Available Colab Notebooks

| Example | Description | Colab Link |
|---------|-------------|------------|
| **Türkiye Earthquakes** | Large-scale deformation | [Open](https://colab.research.google.com/drive/1TARVTB7z8goZyEVDRWyTAKJpyuqZxzW2) |
| **Pico do Fogo Volcano** | Volcanic eruption | [Open](https://colab.research.google.com/drive/1dDFG8BoF4WfB6tOF5sAi5mjdBKRbhxHo) |
| **Imperial Valley** | Groundwater subsidence | [Open](https://colab.research.google.com/drive/1h4XxJZwFfm7EC8NUzl34cCkOVUG2uJr4) |
| **Golden Valley** | Infrastructure monitoring | [Open](https://colab.research.google.com/drive/1ipiQGbvUF8duzjZER8v-_R48DSpSmgvQ) |
| **Lake Sarez** | Landslide monitoring | [Open](https://colab.research.google.com/drive/1O3aZtZsTrQIldvCqlVRel13wJRLhmTJt) |

## 💡 Tips and Best Practices

### 1. **Save Your Work**
```python
# Save notebook to Google Drive
from google.colab import drive
drive.mount('/content/drive')

# Save results
velocity.to_netcdf('/content/drive/MyDrive/velocity_map.nc')
```

### 2. **Monitor Resources**
```python
# Check available memory
import psutil
print(f"Available memory: {psutil.virtual_memory().available / 1024**3:.1f} GB")
```

### 3. **Use Checkpoints**
```python
# Save intermediate results
stack.save_checkpoint('checkpoint_1')
```

### 4. **Optimize for Colab**
- Use smaller areas for free Colab
- Process data in chunks
- Save results frequently
- Use Colab Pro for larger projects

## 🔗 Additional Resources

- **Official PyGMTSAR**: [GitHub Repository](https://github.com/AlexeyPechnikov/pygmtsar)
- **Interactive Examples**: [InSAR.dev](https://insar.dev)
- **AI Assistant**: [InSAR.dev/ai](https://insar.dev/ai)
- **Video Tutorials**: [YouTube Channel](https://www.youtube.com/channel/UCSEeXKAn9f_bDiTjT6l87Lg)
- **Premium Content**: [Patreon](https://www.patreon.com/pechnikov)

## 🆘 Getting Help

1. **Check the troubleshooting section above**
2. **Visit the official PyGMTSAR repository**
3. **Use the AI Assistant at insar.dev/ai**
4. **Join the community discussions**

---

**Note**: This guide is specifically for running PyGMTSAR on Google Colab. For local installation, see the [Docker Setup Guide](DOCKER_SETUP.md).
