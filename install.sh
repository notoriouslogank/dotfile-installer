#!/bin/bash

# Navigate to ~ first
cd ~

# Create backup directory
mkdir ~/backups

# Check if ~/.config exists and create it if not
if ! test -f ~/.config; then
    mkdir ~/.config
fi

# Create backups for config files
if test -f /etc/ssh/banner; then
    sudo mv /etc/ssh/banner ~/backups/banner.bak
fi

if test -f /etc/ssh/ssh_config; then
    sudo mv /etc/ssh/ssh_config ~/backups/ssh_config.bak
fi

if test -f /etc/ssh/sshd_config; then
    sudo mv /etc/ssh/sshd_config ~/backups/sshd_config.bak
fi

if test -f ~/.bashrc; then
    sudo mv ~/.bashrc ~/backups/.bashrc.bak
fi

if test -f ~/.zshrc; then
    sudo mv ~/.zshrc ~/backups/.zshrc.bak
fi

if test -f ~/.tmux.conf; then
    sudo mv ~/.tmux.conf ~/backups/.tmux.conf.bak
fi

# Update apt
sudo apt update -y # Need to check for package manager to make it system-agnostic

# Application list
APPLICATIONS="neofetch ranger git lsd bpytop htop zsh toilet figlet tmux"

# Install apps
sudo apt install $APPLICATIONS -y

# Create repository dest
mkdir ~/repositories

# Clone repositories
cd ~/repositories

type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" # Oh-my-zsh

cd ~/repositories

curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg &&
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
    sudo apt update &&
    sudo apt install gh -y # GitHub CLI

# Create banner
sudo figlet -f slant $HOST >/etc/ssh/banner

# Move config files to necessary destinations
sudo mv assets/etc/ssh/ssh_config /etc/ssh/ssh_config &&
    sudo mv assets/etc/ssh/sshd_config /etc/ssh/sshd_config &&
    sudo mv -r assets/.config/bpytop ~/.config &&
    sudo mv -r assets/.config/neofetch ~/.config &&
    sudo mv -r assets/home_dir/* ~ &&
    clear &&
    echo "Okay, well, it's done. Let's see if it actually worked..."
