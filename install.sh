#!/bin/bash
parent_path=$(
    cd "$(dirname "${BASH_SOURCE[0]}")"
    pwd -P
)
cd "$parent_path"
echo "$parent_path"

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

# Update apt and install applications
declare -a apps=("neofetch" "ranger" "git" "bpytop" "htop" "zsh" "toilet" "figlet" "tmux" "curl" "cmake" "pkg-config" "libfreetype6-dev" "libfontconfig1-dev" "libxcb-xfixes0-dev" "libxkbcommon-dev" "python3" "zsh-doc" "rustc")
sudo apt update -y
for i in "${apps[@]}"; do
    type -p "$i" >/dev/null || (sudo apt install "$i" -y)
done

# Font(s)
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Mononoki/Regular/MononokiNerdFontMono-Regular.ttf
curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Mononoki/Bold/MononokiNerdFontMono-Bold.ttf
curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/AnonymousPro/Regular/AnonymiceProNerdFontMono-Regular.ttf
sudo cp * /usr/local/share/fonts
fc-cache -f -v

# Oh-my-zsh
if ! test -f ~/.oh-my-zsh; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# GitHub CLI
if ! test -f /usr/bin/gh; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    sudo apt update
    sudo apt install gh -y
fi

# Alacritty
git clone https://github.com/alacritty/alacritty.git
cd alacritty
#curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
rustup override set stable
rustup update stable
cargo build --release
infocmp alacritty
sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
sudo cp target/release/alacritty /usr/local/bin # or anywhere else in $PATH
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
sudo update-desktop-database
sudo mkdir -p /usr/local/share/man/man1
sudo mkdir -p /usr/local/share/man/man5
scdoc <extra/man/alacritty.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty.1.gz >/dev/null
scdoc <extra/man/alacritty-msg.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz >/dev/null
scdoc <extra/man/alacritty.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty.5.gz >/dev/null
scdoc <extra/man/alacritty-bindings.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty-bindings.5.gz >/dev/null

# lsd
cargo install --git https://github.com/lsd-rs/lsd.git --branch master

# Create banner
sudo figlet -f $HOST >~/banner
sudo cp ~/banner /etc/ssh/banner
sudo rm ~/banner

# Move config files to necessary destinations
cd "$parent_path"
sudo cp "$parent_path/assets/etc/ssh/ssh_config" "/etc/ssh/ssh_config"
echo "Moved ssh_config."
sudo cp "$parent_path/assets/etc/ssh/sshd_config" "/etc/ssh/sshd_config"
echo "Moved sshd_config."
sudo cp -r "$parent_path/assets/.config/bpytop" ~/.config
echo "Moved bpytop."
sudo cp -r "$parent_path/assets/.config/neofetch" ~/.config
echo "Moved neofetch to .config."
sudo cp -r "$parent_path/assets/.config/alacritty" ~/.config
echo "Moved alacritty to .config."
sudo cp -r "$parent_path/assets/home_dir/.zshrc" ~
echo "Moved .bashrc to ~"
sudo cp -r "$parent_path/assets/home_dir/.bashrc" ~
echo "Moved .tmux.conf to ~"
sudo cp -r "$parent_path/assets/home_dir/.tmux.conf" ~
echo "Okay, well, it's done. Let's see if it actually worked..."

# TODO: install alacritty (meaning also setup rust)
