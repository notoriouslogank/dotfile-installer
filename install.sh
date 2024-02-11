#!/bin/bash
echo "Program start." >log.txt
parent_path=$(
    cd "$(dirname "${BASH_SOURCE[0]}")"
    pwd -P
)
cd "$parent_path"
echo "Parent path: $parent_path" >>log.txt

# Backups

if ! test -f backups; then
    mkdir -p backups/config && mkdir -p backups/home_dir && mkdir -p backups/etc/ssh
fi

# ssh
if test -f /etc/ssh/banner; then
    sudo mv /etc/ssh/banner backups/etc/ssh/banner.bak
    echo "Backed up /etc/ssh/banner" >>log.txt
fi

if test -f /etc/ssh/ssh_config; then
    sudo mv /etc/ssh/ssh_config backups/etc/ssh/ssh_config.bak
    echo "Backed up /etc/ssh/ssh_config." >>log.txt
fi

if test -f /etc/ssh/sshd_config; then
    sudo mv /etc/ssh/sshd_config backups/etc/ssh/sshd_config.bak
    echo "Backed up /etc/ssh/sshd_config." >>log.txt
fi

# home_dir
if test -f ~/.bashrc; then
    sudo mv ~/.bashrc backups/home_dir/bashrc.bak
    echo "Backed up ~/.bashrc." >>log.txt
fi

if test -f ~/.zshrc; then
    sudo mv ~/.zshrc backups/home_dir/zshrc.bak
    echo "Backed up ~/.zshrc." >>log.txt
fi

if test -f ~/.tmux.conf; then
    sudo mv ~/.tmux.conf backups/home_dir/tmux.conf.bak
    echo "Backed up ~/.tmux.conf." >>log.txt
fi

# .config

if test -f ~/.config/alacritty; then
    sudo mv ~/.config/alacritty backups/config/alacritty.bak
fi

if test -f ~/.config/neofetch; then
    sudo mv ~/.config/neofetch backups/config/neofetch.bak
fi

if test -f ~/.config/bpytop; then
    sudo mv ~/.config/bpytop backups/config/bpytop.bak
fi

# applications
declare -a apps=("neofetch" "ranger" "git" "bpytop" "htop" "zsh" "toilet" "figlet" "tmux" "curl" "cmake" "pkg-config" "libfreetype6-dev" "libfontconfig1-dev" "libxcb-xfixes0-dev" "libxkbcommon-dev" "python3" "zsh-doc" "scdoc")

# Install applications
sudo apt update -y
for i in "${apps[@]}"; do
    type -p "$i" >/dev/null || (sudo apt install "$i" -y) && echo "Installed application: $i" >>log.txt
done

# Download and install fonts

if ! test -f ~/.local/share/fonts; then
    mkdir ~/.local/share/fonts
    echo "Created ~/.local/share/fonts" >>log.txt
fi

cd ~/.local/share/fonts
curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Mononoki/Regular/MononokiNerdFontMono-Regular.ttf
curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Mononoki/Bold/MononokiNerdFontMono-Bold.ttf
curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/AnonymousPro/Regular/AnonymiceProNerdFontMono-Regular.ttf
sudo cp * /usr/local/share/fonts
cd $parent_path
fc-cache -f -v
echo "Installed fonts." >>log.txt

# GitHub CLI
if ! test -f /usr/bin/gh; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    sudo apt update
    sudo apt install gh -y
    echo "Installed gh." >>log.txt
fi

# rustup
echo "Checking for rustup..." >>log.txt
if ! test -f ~/.cargo/bin/rustup; then
    curl --protto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh
    echo "Installed rustup."
fi

# Clone and build Alacritty
echo "Cloning Alacritty." >>log.txt
cd $parent_path
git clone https://github.com/alacritty/alacritty.git
cd alacritty
echo "Building Alacritty..." >>log.txt
rustup override set stable
rustup update stable
cargo build --release
infocmp alacritty
sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
sudo cp target/release/alacritty /usr/local/bin
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
echo "Installed Alacritty." >>log.txt

# Alacritty manpages
echo "Bulding Alacritty manpages..." >>log.txt
sudo update-desktop-database
sudo mkdir -p /usr/local/share/man/man1
sudo mkdir -p /usr/local/share/man/man5
scdoc <extra/man/alacritty.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty.1.gz >/dev/null
scdoc <extra/man/alacritty-msg.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz >/dev/null
scdoc <extra/man/alacritty.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty.5.gz >/dev/null
scdoc <extra/man/alacritty-bindings.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty-bindings.5.gz >/dev/null

# lsd
echo "Cloning and building lsd..." >>log.txt
cd $parent_path
cargo install --git https://github.com/lsd-rs/lsd.git --branch master
echo "Installed lsd." >>log.txt

# Create banner
cd $parent_path
figlet -f pagga "$HOST" >>assets/etc/ssh/banner
sudo cp assets/etc/ssh/banner /etc/ssh/banner
echo "Created ssh banner." >>log.txt

# Oh-my-zsh
cd $parent_path
if ! test -f ~/.oh-my-zsh; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "Installed oh-my-zsh." >>log.txt
fi

# Config files

if ! test -f ~/.config; then
    mkdir ~/.config
fi

# ssh
cd $parent_path
sudo cp "assets/etc/ssh/ssh_config" "/etc/ssh/ssh_config"
sudo cp "assets/etc/ssh/sshd_config" "/etc/ssh/sshd_config"
sudo cp "assets/etc/ssh/banner" "/etc/ssh/banner"
echo "Created ssh configs." >>log.txt

# .config
sudo cp -r "assets/config/alacritty" ~/.config
sudo cp -r "assets/config/bpytop" ~/.config
sudo cp -r "assets/config/neofetch" ~/.config
echo "Created .config files." >>log.txt

# home_dir
cp -r "assets/home_dir/zshrc" ~/.zshrc
cp -r "assets/home_dir/bashrc" ~/.bashrc
cp -r "assets/home_dir/tmux.conf" ~/.tmux.conf
echo "Created shell config files." >>log.txt

echo "Done." >>log.txt
echo "Done.  Please see log.txt for more information."
