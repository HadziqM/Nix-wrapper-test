#!/usr/bin/env bash

mkdir -p ~/.config/nix

# Check if flakes are already enabled
if ! grep -q "experimental-features = nix-command flakes" ~/.config/nix/nix.conf 2>/dev/null; then
  echo "Enabling flakes and nix-command..."
  echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
  echo "Successfully enabled flakes."
else
  echo "Flakes are already enabled."
fi

echo "Installing Nix (daemon mode)..."
curl -L https://nixos.org/nix/install -o /tmp/install-nix.sh
sh /tmp/install-nix.sh --daemon
