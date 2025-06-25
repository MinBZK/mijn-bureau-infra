#!/usr/bin/env bash

cd /tmp/

# install node version manager
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# install node version
nvm install v22.15.1

# get architecture an system properties
ARCH=$(dpkg --print-architecture)
if [ "$ARCH" = amd64 ]; then
  ARCH_X86_FIX=x86_64
else
  ARCH_X86_FIX="$ARCH"
fi
SYSTEM=$(uname)

# install prettier
npm install -g prettier

# install pip
sudo apt update
sudo apt-get -y install python3-pip

# install pre-commit hook
pip3 install pre-commit gitlint requests

# install helm
wget -O - https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# install helmfile
wget -O helmfile.tar.gz https://github.com/helmfile/helmfile/releases/download/v1.0.0/helmfile_1.0.0_${SYSTEM}_${ARCH}.tar.gz
tar -xzf helmfile.tar.gz
sudo mv helmfile /usr/local/bin

# install helm plugins
helm plugin install https://github.com/jkroepke/helm-secrets
helm plugin install https://github.com/databus23/helm-diff
helm plugin install https://github.com/aslafy-z/helm-git
helm plugin install https://github.com/hypnoglow/helm-s3

# install conftest
LATEST_VERSION=$(wget -O - "https://api.github.com/repos/open-policy-agent/conftest/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | cut -c 2-)
wget "https://github.com/open-policy-agent/conftest/releases/download/v${LATEST_VERSION}/conftest_${LATEST_VERSION}_${SYSTEM}_${ARCH_X86_FIX}.tar.gz"
tar xzf conftest_${LATEST_VERSION}_${SYSTEM}_${ARCH_X86_FIX}.tar.gz
sudo mv conftest /usr/local/bin

# install open plicy agent
wget -O opa https://github.com/open-policy-agent/opa/releases/download/v1.4.2/opa_${SYSTEM}_${ARCH}_static
sudo mv opa /usr/local/bin
chmod +x /usr/local/bin/opa

# install regal
wget -O regal https://github.com/StyraInc/regal/releases/latest/download/regal_${SYSTEM}_${ARCH_X86_FIX}
sudo mv regal /usr/local/bin
sudo chmod +x /usr/local/bin/regal

# install kubectl
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list   # helps tools such as command-not-found to work correctly
sudo apt-get update
sudo apt-get install -y kubectl

# install sops
# Download the binary
curl -LO https://github.com/getsops/sops/releases/download/v3.10.2/sops-v3.10.2.linux.${ARCH}
# Move the binary in to your PATH
sudo mv sops-v3.10.2.linux.${ARCH} /usr/local/bin/sops
# Make the binary executable
sudo chmod +x /usr/local/bin/sops
