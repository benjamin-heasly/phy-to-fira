# Start with the MATLAB base image (published on Docker Hub).
FROM mathworks/matlab:r2022b

# Become root to install more toolboxes.
USER root
WORKDIR /root

# Run mpm to install MATLAB toolboxes, then delete mpm itself to save space.
# - Statistics_and_Machine_Learning_Toolbox
RUN wget -q https://www.mathworks.com/mpm/glnxa64/mpm \
    && chmod +x mpm \
    && ./mpm install \
    --release=r2022b \
    --destination=/opt/matlab/R2022b/ \
    --products Statistics_and_Machine_Learning_Toolbox \
    || (echo "MPM Installation Failure. See below for more information:" && cat /tmp/mathworks_root.log && false) \
    && rm -f mpm /tmp/mathworks_root.log

# Obtain the Plexon OmniPlex and MAP Offline SDK Bundle.
# https://plexon.com/wp-content/uploads/2017/08/OmniPlex-and-MAP-Offline-SDK-Bundle_0.zip
USER matlab
WORKDIR /home/matlab/
RUN wget -q "https://plexon.com/wp-content/uploads/2017/08/OmniPlex-and-MAP-Offline-SDK-Bundle_0.zip" \
    && unzip "OmniPlex-and-MAP-Offline-SDK-Bundle_0.zip" \
    && unzip "OmniPlex and MAP Offline SDK Bundle/Matlab Offline Files SDK.zip" \
    && mv "Matlab Offline Files SDK" /home/matlab/Matlab-Offline-Files-SDK \
    && rm -rf "OmniPlex and MAP Offline SDK Bundle" \
    && rm "OmniPlex-and-MAP-Offline-SDK-Bundle_0.zip"

# Get the build script to compile the Plexon mexPlex mex-function.
USER root
COPY ./mex-build/mex-build.sh /home/matlab/mex-build.sh
RUN chown matlab:matlab /home/matlab/mex-build.sh && chmod 755 /home/matlab/mex-build.sh

# Build mexPlex.
USER matlab
WORKDIR /home/matlab
RUN /home/matlab/mex-build.sh

# Get git so we can fetch toolboxes, then clean up the package manager stuff to save space.
USER root
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install --no-install-recommends --yes \
    git \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# Get npy-matlab, pegged to a specific commit to make this reproducible (no repo tags in this repo).
# commit b7b0a4ef6ba26d98a8c54e651d5444083c88311c is from 2018-11-14
USER matlab
WORKDIR /home/matlab
RUN git clone https://github.com/kwikteam/npy-matlab.git /home/matlab/npy-matlab \
    && git -C /home/matlab/npy-matlab checkout b7b0a4ef6ba26d98a8c54e651d5444083c88311c

# Get Gold Lab FIRA code, pegged to a specific commit to make this reproducible (no tags in this repo).
# commit 9d5179793e6ecfd2771ecc13d803cd1b3adc9c6e is from 2023-02-06
RUN git clone https://github.com/TheGoldLab/Lab_Matlab_Utilities.git /home/matlab/Lab_Matlab_Utilities \
    && git -C /home/matlab/Lab_Matlab_Utilities checkout 9d5179793e6ecfd2771ecc13d803cd1b3adc9c6e

# Get the Matlab code for converting .plx and Phy files to FIRA.
COPY ./matlab /home/matlab/phy-to-fira

# Configure Matlab on startup.
COPY ./matlab/container-startup.m /home/matlab/Documents/MATLAB/startup.m
