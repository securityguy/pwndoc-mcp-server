#!/bin/sh
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
sudo cp pwndoc-mcp-server /usr/local/bin
