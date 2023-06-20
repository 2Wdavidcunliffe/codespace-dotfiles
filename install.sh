export DEBIAN_FRONTEND=noninteractive
export INSTALL_ZSH=true
export USERNAME=`whoami`

## update and install required packages
# Update Ubuntu and get standard repository programs
sudo apt update 
sudo apt full-upgrade -y
sudo apt-get update
sudo apt-get -y install --no-install-recommends apt-utils dialog 2>&1
sudo apt-get install -y \
  curl \
  git \
  gnupg2 \
  jq \
  sudo \
  openssh-client \
  less \
  iproute2 \
  procps \
  wget \
  unzip \
  apt-transport-https \
  lsb-release \
  apt-transport-https \
  ca-certificates \
  gnupg \
  gnupg-agent \
  software-properties-common \
  htop

# Install TFENV and configure for latest release of Terraform
git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv
sudo ln -s ~/.tfenv/bin/* /usr/local/bin
tfenv install latest
tfenv use latest

# Install AWS CLI
pushd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-$(lscpu | grep Architecture | cut -d ":" -f 2 | xargs).zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
popd

# Install GCloud CLI
# sudo apt-get update
# sudo apt-get install -y apt-transport-https ca-certificates gnupg curl sudo
# sudo apt -y --fix-broken install
echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y \
 google-cloud-cli \
 google-cloud-sdk-gke-gcloud-auth-plugin \
 google-cloud-sdk-kubectl-oidc \
 kubectl

# Install Azure CLI
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list.d/azure-cli.list
curl -sL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - 2>/dev/null
sudo apt-get update
sudo apt-get install -y azure-cli;

# Install Docker
echo "🐋 Installing Docker"
# sudo apt update
# sudo apt-get install -y \
#     apt-transport-https \
#     ca-certificates \
#     curl \
#     gnupg-agent \
#     software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt update
sudo apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io

# Install & Configure Zsh
if [ "$INSTALL_ZSH" = "true" ]
then
    sudo apt-get install -y \
    fonts-powerline \
    zsh

    curl https://raw.githubusercontent.com/2Wdavidcunliffe/codespace-dotfiles/main/dotfiles/.zshrc -o ~/.zshrc
    sudo chsh -s /usr/bin/zsh $USERNAME
    wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
    echo "source $PWD/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
fi

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

# Cleanup
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt-get autoremove -y
sudo rm -rf /var/lib/apt/lists/*

# Symlink overwrite current zshrc