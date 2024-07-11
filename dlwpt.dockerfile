# Start from an Ubuntu 20.04 base image
FROM ubuntu:20.04

# Avoid prompts from apt during installation
ENV DEBIAN_FRONTEND=noninteractive

# Set up Conda environment variables
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH

# Install necessary packages, Miniconda, tmux, SSH, and set up Conda environment in one layer
RUN apt-get update && apt-get install -y \
    wget bzip2 ca-certificates git curl gnupg lsb-release libarchive13 tmux openssh-server \
    && wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh \
    && /bin/bash ~/miniconda.sh -b -p $CONDA_DIR \
    && rm ~/miniconda.sh \
    && conda init bash \
    && conda update -n base -c defaults conda \
    && conda install -n base -c conda-forge conda-libmamba-solver \
    && conda config --set solver libmamba \
    && conda create -n pytorch_env python=3.10 \
    && conda clean -afy \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* $CONDA_DIR/pkgs /root/.conda/cache/*

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

# Install VSCode
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
    && install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ \
    && sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list' \
    && apt-get install -y apt-transport-https \
    && apt-get update \
    && apt-get install -y code \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* microsoft.gpg

# Set up SSH
RUN mkdir /var/run/sshd \
    && echo 'root:root' | chpasswd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Expose SSH port
EXPOSE 22
EXPOSE 8888

# Create a script to run VSCode with necessary arguments
RUN echo '#!/bin/bash\ncode --no-sandbox --user-data-dir=/root/.vscode-root "$@"' > /usr/local/bin/code-root \
    && chmod +x /usr/local/bin/code-root

# Include the example command to keep the container running
CMD ["sh", "-c", "while true; do echo hello world; sleep 30; done"]
