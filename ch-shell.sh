#!usr/bin/env bash
SHELL_PATH=$(command -v zsh || command -v bash)

if [ -z "$SHELL_PATH" ]; then
  echo "Error: No valid shell found in Nix environment!"
  exit 1
fi

echo "Using shell: $SHELL_PATH"

# Ensure it's listed in /etc/shells
if ! grep -q "$SHELL_PATH" /etc/shells; then
  echo "Adding $SHELL_PATH to /etc/shells..."
  echo "$SHELL_PATH" | sudo tee -a /etc/shells
fi

# Change the default shell
echo "Changing shell to $SHELL_PATH for user $USER..."
chsh -s "$SHELL_PATH"

echo "Done! Restart your terminal or log out and back in."
