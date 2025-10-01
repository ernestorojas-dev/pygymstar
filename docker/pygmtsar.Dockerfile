# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html
# host platform compilation:
# docker build . -f pygmtsar.Dockerfile -t pechnikov/pygmtsar:latest --no-cache
# cross-compilation:
# docker buildx build . -f pygmtsar.Dockerfile -t pechnikov/pygmtsar:latest-amd64 --no-cache --platform linux/amd64 --load
# multiple hosts compilation:
# amd64 image:
# docker buildx build . -f docker/pygmtsar.Dockerfile \
#       --platform linux/amd64 \
#       --tag pechnikov/pygmtsar:$(date "+%Y-%m-%d")-amd64 \
#       --tag pechnikov/pygmtsar:latest-amd64 \
#       --pull --push --no-cache
# arm64 image:
# docker buildx build . -f docker/pygmtsar.Dockerfile \
#     --platform linux/arm64 \
#     --tag pechnikov/pygmtsar:$(date "+%Y-%m-%d")-arm64 \
#     --tag pechnikov/pygmtsar:latest-arm64 \
#     --pull --push --no-cache
# create a multi-arch manifest:
# docker buildx imagetools create \
#     --tag pechnikov/pygmtsar:latest \
#     pechnikov/pygmtsar:latest-amd64 \
#     pechnikov/pygmtsar:latest-arm64
FROM quay.io/jupyter/scipy-notebook:2025-01-28

##########################################################################################
# Start initialization
##########################################################################################
USER root

# grant passwordless sudo rights
RUN echo "${NB_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# install command-line tools
RUN apt-get -y update && apt-get -y upgrade && apt-get -y install \
    git subversion curl jq csh zip htop mc netcdf-bin \
&&  apt-get clean \
&&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

##########################################################################################
# Install GMTSAR
##########################################################################################
# install dependencies
RUN apt-get -y update && apt-get -y install \
    autoconf make gfortran \
    gdal-bin libgdal-dev \
    libtiff5-dev \
    libhdf5-dev \
    liblapack-dev \
    gmt libgmt-dev \
&&  apt-get clean \
&&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# define installation and binaries search paths
ARG GMTSAR=/usr/local/GMTSAR
ARG ORBITS=/usr/local/orbits
ENV PATH=${GMTSAR}/bin:$PATH

# install GMTSAR from git
RUN cd $(dirname ${GMTSAR}) \
&&  git config --global advice.detachedHead false \
&&  git clone --branch master https://github.com/gmtsar/gmtsar GMTSAR \
&&  cd ${GMTSAR} \
&&  git checkout e98ebc0f4164939a4780b1534bac186924d7c998 \
&&  autoconf \
&&  ./configure --with-orbits-dir=${ORBITS} CFLAGS='-z muldefs' LDFLAGS='-z muldefs' \
&&  make -j$(nproc) \
&&  make install \
&&  make clean

# system cleanup
RUN apt-get -y remove --purge \
    libgdal-dev autoconf make gfortran \
    libtiff5-dev libhdf5-dev liblapack-dev libgmt-dev \
&&  apt-get autoremove -y --purge

##########################################################################################
# Install VTK
##########################################################################################
# install dependencies
RUN apt-get -y update && apt-get -y install \
    libopengl0 mesa-utils \
    libgl1-mesa-dev libegl1-mesa-dev libgles2-mesa-dev \
    cmake ninja-build python3-dev build-essential \
&&  apt-get clean \
&&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install python vtk library
RUN git clone --depth=1 --branch v9.3.1 https://gitlab.kitware.com/vtk/vtk.git \
&&  cd vtk \
&&  mkdir build && cd build \
&&  cmake ../ \
  -GNinja \
  -DCMAKE_BUILD_TYPE=Release \
  -DVTK_DEFAULT_RENDER_WINDOW_OFFSCREEN=ON \
  -DVTK_OPENGL_HAS_EGL=ON \
  -DVTK_OPENGL_HAS_OSMESA=OFF \
  -DVTK_USE_X=OFF \
  -DCMAKE_INSTALL_PREFIX=/opt/conda \
  -DVTK_WRAP_PYTHON=ON \
  -DVTK_PYTHON_VERSION=3 \
&&  ninja -j$(nproc) \
&&  ninja install \
&&  cd ../.. \
&&  rm -fr vtk

# system cleanup
RUN apt-get -y remove --purge \
    libgl1-mesa-dev libegl1-mesa-dev libgles2-mesa-dev \
    cmake ninja-build python3-dev build-essential \
&&  apt-get autoremove -y --purge

##########################################################################################
# Install Python Libraries
##########################################################################################
# install dependencies to build rasterio
RUN apt-get -y update && apt-get -y install \
    libhdf5-dev pkg-config \
    libgdal-dev build-essential \
&&  apt-get clean \
&&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install PyGMTSAR and visualization libraries
# install rasterio PyGMTSAR dependency because it requires compilation on ARM64
RUN /opt/conda/bin/pip3 install --no-cache-dir \
    xvfbwrapper \
    ipywidgets \
    jupyter_bokeh \
    panel \
    ipyleaflet \
    rasterio

# install recent pyvista with invalid dependencies specification
RUN /opt/conda/bin/pip3 install --no-cache-dir matplotlib pillow pooch scooby typing-extensions \
&&  /opt/conda/bin/pip3 install --no-cache-dir --no-deps pyvista

# system cleanup
RUN apt-get -y remove --purge \
    libhdf5-dev pkg-config \
    libgdal-dev build-essential \
&&  apt-get autoremove -y --purge

##########################################################################################
# Install Virtual Frame Buffer for PyVista
##########################################################################################
# install dependencies to compile
RUN apt-get -y update && apt-get -y install \
    xvfb \
&&  apt-get clean \
&&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# modify start-notebook.py to start Xvfb
RUN sed -i '/import sys/a \
# Start Xvfb\n\
import xvfbwrapper\n\
display = xvfbwrapper.Xvfb(width=1280, height=1024)\n\
display.start()' /usr/local/bin/start-notebook.py

##########################################################################################
# Add PyGMTSAR examples
##########################################################################################
# download Google Colab notebooks from Google Drive
RUN wget -q https://raw.githubusercontent.com/AlexeyPechnikov/pygmtsar/refs/heads/pygmtsar2/notebooks/dload.sh \
    && chmod +x dload.sh \
    && ./dload.sh colab_notebooks \
    && rm -f dload.sh \
    && mv colab_notebooks ${HOME}/notebooks \
    && chown -R ${NB_UID}:${NB_GID} ${HOME}/notebooks

##########################################################################################
# Install PyGMTSAR
##########################################################################################
ADD "https://api.github.com/repos/AlexeyPechnikov/pygmtsar/commits?per_page=1" latest_commit
RUN /opt/conda/bin/pip3 install --no-cache-dir git+https://github.com/AlexeyPechnikov/gmtsar.git@pygmtsar2#subdirectory=pygmtsar \
&&  rm -f latest_commit

##########################################################################################
# End initialization
##########################################################################################
# switch user
USER    ${NB_UID}
WORKDIR "${HOME}"

RUN rm -rf work
