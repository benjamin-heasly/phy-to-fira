#!/bin/sh

set -e

sudo docker build -t ninjaben/phy-to-fira:local .

# sudo docker run -ti --rm ninjaben/phy-to-fira:local /bin/bash

# Run a container locally to check if mexPlex is present and runnable.
# Since this step actually runs Matlab, we'll need to configure a license.
# This assumes a local ./licence.lic issued for a local MAC address.
# There are other ways to set up the Matlab license with Docker, too: https://hub.docker.com/r/mathworks/matlab
LICENSE_MAC_ADDRESS=$(cat /sys/class/net/en*/address)
LICENSE_FILE="$(pwd)/license.lic"
sudo docker run --rm \
  --mac-address "$LICENSE_MAC_ADDRESS" \
  -v $LICENSE_FILE:/licenses/license.lic \
  -e MLM_LICENSE_FILE=/licenses/license.lic \
  ninjaben/phy-to-fira:local \
  -batch "success = testMexPlex()"

# Local test to convert a .plx file.
LICENSE_MAC_ADDRESS=$(cat /sys/class/net/en*/address)
LICENSE_FILE="$(pwd)/license.lic"
sudo docker run --rm \
  --mac-address "$LICENSE_MAC_ADDRESS" \
  -v $LICENSE_FILE:/licenses/license.lic \
  -e MLM_LICENSE_FILE=/licenses/license.lic \
  -v "/home/ninjaben/Desktop/codin/gold-lab/plexon_data/MrM:/MrM" \
  ninjaben/phy-to-fira:local \
  -batch "convertedFile = phyToFira('/MrM/Kilosort/MM_2022_11_28C_V-ProRec-results/phy/params.py', '/MrM/Raw/MM_2022_11_28C_V-ProRec.plx', '/MrM/spmADPODR5.m', '/MrM/Converted', 'spike_list', [zeros([1000, 1]), (0:999)'], 'sig_list', 49:51)"
