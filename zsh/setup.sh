#!/bin/bash
# This script installs zsh, oh my zsh and configures powerlvl10k as the default theme for zsh
# changes the default path on WSL distributions to /home/$USER
# and installs these tools:
#  - docker

wsl_home () {
  if ! grep -q WSL /proc/version; then
    return
  fi

  if grep -q WSL ~/.zshrc; then
    return
  fi

  printf "# WSL Config\ncd\n" >> ~/.zshrc
}

# update repository and install dependencies
sudo apt-get update && sudo apt-get install curl git -y

# install and set by default zsh
# install ohmyzsh
sudo apt-get install zsh -y
sudo chsh -s $(which zsh) `whoami`
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# customize .zshrc
# download powerlvl10k and modify zshrc
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
curl https://raw.githubusercontent.com/izarte/izarte/main/zsh/zshrc > $HOME/.zshrc
curl https://raw.githubusercontent.com/izarte/izarte/main/zsh/p10k.zsh > $HOME/.p10k.zsh

# customize .zshrc if we are on WSL to use /home/$USER as default location
wsl_home

# install tools
# vim
sudo apt-get update && sudo apt-get install vim -y

# Declare a variable specific to this script
is_debian=false

# Check if /etc/os-release file exists
if [ -f /etc/os-release ]; then
    # Source the file to get variables
    . /etc/os-release
    
    # Check the value of the ID variable
    if [ "$ID" = "debian" ]; then
        is_debian=true
    fi
else
    echo "Unable to determine the operating system."
    exit 1
fi

# docker
if [ "$is_debian" = true ]; then
	# Uninstall all conflicting packages
	for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
	 # Add Docker's official GPG key:
	sudo apt-get update
	sudo apt-get install ca-certificates curl
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc
	
	# Add the repository to Apt sources:
	echo \
	  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
	  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
	  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
	# Uninstall all conflicting packages
	for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
	# Add Docker's official GPG key:
	sudo apt-get update
	sudo apt-get install ca-certificates curl
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc
	
	# Add the repository to Apt sources:
	echo \
	  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
	  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
	  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update
	
	sudo apt-get install -y ca-certificates gnupg lsb-release
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
