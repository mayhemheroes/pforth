#!/bin/bash
set -euo pipefail

# RLENV Build Script
# This script rebuilds the application from source located at /rlenv/source/pforth/
#
# Original image: ghcr.io/mayhemheroes/pforth:master
# Git revision: 04304f4bcde865e10a121dffd3de51c70bf7b097

# ============================================================================
# Environment Variables
# ============================================================================
# No special environment variables needed for C/Make build

# ============================================================================
# REQUIRED: Change to Source Directory
# ============================================================================
cd /rlenv/source/pforth/platforms/unix

# ============================================================================
# Clean Previous Build (recommended)
# ============================================================================
# Remove old build artifacts to ensure fresh rebuild
make clean 2>/dev/null || true

# ============================================================================
# Build Commands (NO NETWORK, NO PACKAGE INSTALLATION)
# ============================================================================
# Build pforth_standalone using the standard Make process
# This includes:
# 1. Compile C sources to create pforth (dictionary app)
# 2. Run pforth to generate pforth.dic (dictionary file)
# 3. Convert pforth.dic to pfdicdat.h (embedded dictionary header)
# 4. Compile with embedded dictionary to create pforth_standalone
make all

# ============================================================================
# Copy Artifacts (use 'cat >' for busybox compatibility)
# ============================================================================
# The build produces pforth_standalone in the current directory
# We need to ensure it's accessible at /platforms/unix/pforth_standalone
# Using cat > for busybox compatibility
cat pforth_standalone > /platforms/unix/pforth_standalone

# ============================================================================
# Set Permissions
# ============================================================================
chmod 777 /platforms/unix/pforth_standalone 2>/dev/null || true

# 777 allows validation script (running as UID 1000) to overwrite during rebuild

# ============================================================================
# REQUIRED: Verify Build Succeeded
# ============================================================================
if [ ! -f /platforms/unix/pforth_standalone ]; then
    echo "Error: Build artifact not found at /platforms/unix/pforth_standalone"
    exit 1
fi

# Verify executable bit
if [ ! -x /platforms/unix/pforth_standalone ]; then
    echo "Warning: Build artifact is not executable"
fi

# Verify file size (pforth_standalone should be reasonable size)
SIZE=$(stat -c%s /platforms/unix/pforth_standalone 2>/dev/null || stat -f%z /platforms/unix/pforth_standalone 2>/dev/null || echo 0)
if [ "$SIZE" -lt 10000 ]; then
    echo "Warning: Build artifact is suspiciously small ($SIZE bytes)"
fi

echo "Build completed successfully: /platforms/unix/pforth_standalone ($SIZE bytes)"
