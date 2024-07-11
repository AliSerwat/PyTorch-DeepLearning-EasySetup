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

# Install VSCode
RUN apt-get update \
    && apt-get install -y wget gpg apt-transport-https \
    && wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
    && install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list \
    && apt-get update \
    && apt-get install -y code \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* microsoft.gpg

# Set up SSH
RUN mkdir /var/run/sshd \
    && echo 'root:root' | chpasswd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Expose SSH and Jupyter ports
EXPOSE 22 8888

# Create a script to run VSCode with necessary arguments
RUN echo '#!/bin/bash\ncode --no-sandbox --user-data-dir=/root/.vscode-root "$@"' > /usr/local/bin/code-root \
    && chmod +x /usr/local/bin/code-root

# Start SSH service and keep the container running
CMD service ssh start && tail -f /dev/null