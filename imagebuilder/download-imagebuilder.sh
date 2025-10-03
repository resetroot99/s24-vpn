#!/bin/bash

###############################################################################
# Strat24 ImageBuilder Downloader
# Downloads official GL.iNet Opal (GL-SFT1200) ImageBuilder
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
OPENWRT_VERSION="22.03.5"
TARGET="ramips"
SUBTARGET="mt7621"
PROFILE="glinet_gl-sft1200"

IMAGEBUILDER_URL="https://downloads.openwrt.org/releases/${OPENWRT_VERSION}/targets/${TARGET}/${SUBTARGET}/openwrt-imagebuilder-${OPENWRT_VERSION}-${TARGET}-${SUBTARGET}.Linux-x86_64.tar.xz"

IMAGEBUILDER_DIR="openwrt-imagebuilder-${OPENWRT_VERSION}-${TARGET}-${SUBTARGET}.Linux-x86_64"

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║       Strat24 OpenWRT ImageBuilder Downloader           ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if already downloaded
if [ -d "$IMAGEBUILDER_DIR" ]; then
    echo -e "${YELLOW}[!] ImageBuilder already exists: $IMAGEBUILDER_DIR${NC}"
    read -p "    Delete and re-download? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}[~] Removing existing ImageBuilder...${NC}"
        rm -rf "$IMAGEBUILDER_DIR"
    else
        echo -e "${GREEN}[✓] Using existing ImageBuilder${NC}"
        exit 0
    fi
fi

# Download ImageBuilder
echo -e "${BLUE}[→] Downloading OpenWRT ImageBuilder...${NC}"
echo "    Version: ${OPENWRT_VERSION}"
echo "    Target: ${TARGET}/${SUBTARGET}"
echo "    Profile: ${PROFILE}"
echo ""

if ! curl -L -O --progress-bar "$IMAGEBUILDER_URL"; then
    echo -e "${RED}[✗] Failed to download ImageBuilder${NC}"
    exit 1
fi

# Extract
echo -e "${BLUE}[→] Extracting ImageBuilder...${NC}"
if ! tar -xJf "openwrt-imagebuilder-${OPENWRT_VERSION}-${TARGET}-${SUBTARGET}.Linux-x86_64.tar.xz"; then
    echo -e "${RED}[✗] Failed to extract ImageBuilder${NC}"
    exit 1
fi

# Clean up
echo -e "${BLUE}[→] Cleaning up download archive...${NC}"
rm "openwrt-imagebuilder-${OPENWRT_VERSION}-${TARGET}-${SUBTARGET}.Linux-x86_64.tar.xz"

# Verify
if [ -d "$IMAGEBUILDER_DIR" ]; then
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║              ImageBuilder Ready!                         ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${GREEN}[✓] ImageBuilder downloaded successfully!${NC}"
    echo ""
    echo "Next step:"
    echo "  ./build-strat24-firmware.sh"
    echo ""
else
    echo -e "${RED}[✗] ImageBuilder directory not found after extraction${NC}"
    exit 1
fi

