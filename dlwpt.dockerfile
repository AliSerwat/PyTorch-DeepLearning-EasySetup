# Start from an Ubuntu 20.04 base image
FROM ubuntu:20.04

# Avoid prompts from apt during installation
ENV DEBIAN_FRONTEND=noninteractive

# Set up Conda environment variables
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH

# Install necessary packages, Miniconda, and set up Conda environment in one layer
RUN apt-get update && apt-get install -y \
    wget bzip2 ca-certificates git curl gnupg lsb-release libarchive13 \
    && wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh \
    && /bin/bash ~/miniconda.sh -b -p $CONDA_DIR \
    && rm ~/miniconda.sh \
    && conda init bash \
    && conda update -n base -c defaults conda \
    && conda install -n base -c conda-forge conda-libmamba-solver \
    && conda config --set solver libmamba \
    && conda create -n pytorch_env python=3.8 \
    && conda clean -afy \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* $CONDA_DIR/pkgs /root/.conda/cache/*

# Set shell to use conda environment by default
SHELL ["conda", "run", "-n", "pytorch_env", "/bin/bash", "-c"]

# Install common packages
RUN conda install -y \
    numpy pandas matplotlib plotly jupyter jupyterlab seaborn scipy sympy \
    && conda install -y -c conda-forge ipyvolume diskcache \
    && conda install -y -c simpleitk simpleitk

# Install both GPU and CPU PyTorch versions
RUN conda install -y -c pytorch -c nvidia \
    pytorch torchvision torchaudio pytorch-cuda=12.1 \
    && conda install -y -c pytorch \
    pytorch torchvision torchaudio cpuonly

# Final updates and cleanup
RUN conda update --all \
    && conda clean -afy \
    && rm -rf $CONDA_DIR/pkgs /root/.conda/cache/*

# Set the default command to activate 'pytorch_env' when container starts
CMD ["conda", "run", "--no-capture-output", "-n", "pytorch_env", "/bin/bash"]