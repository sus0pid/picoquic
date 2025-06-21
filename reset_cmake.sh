#!/bin/bash

# Remove CMake cache and intermediate build files
rm -rf CMakeCache.txt CMakeFiles/

# Reconfigure the project with CMake
# cmake .
cmake -DCMAKE_BUILD_TYPE=Debug .

# Optional: show status
echo "✅ CMake cache cleared and project reconfigured."

make
