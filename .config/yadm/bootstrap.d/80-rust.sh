#!/bin/bash

set -e

# Install Rust
if [[ ! $(command -v rustup) ]]; then
  printf "Installing rustup\n"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi
