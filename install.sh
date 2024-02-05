#!/bin/bash

# Navigate to ~ first
cd ~

# Create backup directory
if ! test -f ~/backups; then
    mkdir ~/backups
fi

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

# Application list
declare -a apps=("neofetch" "ranger" "git" "bpytop" "htop" "zsh" "toilet" "figlet" "tmux" "curl")

# Update apt and install applications
sudo apt update -y
for i in "${apps[@]}"; do
    type -p "$i" >/dev/null || (sudo apt install "$i" -y)
done

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" # Oh-my-zsh

cd ~/repositories

curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg &&
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
    sudo apt update &&
    sudo apt install gh -y # GitHub CLI

# Create banner
sudo figlet -f slant $HOST >~/banner
sudo cp ~/banner /etc/ssh/banner
sudo rm ~/banner

# Move config files to necessary destinations
cd ~/dotfiles-installer
sudo cp assets/etc/ssh/ssh_config /etc/ssh/ssh_config &&
    sudo cp assets/etc/ssh/sshd_config /etc/ssh/sshd_config &&
    sudo cp -r assets/.config/bpytop ~/.config &&
    sudo cp -r assets/.config/neofetch ~/.config &&
    sudo cp -r assets/home_dir/* ~ &&
    clear &&
    echo "Okay, well, it's done. Let's see if it actually worked..."
