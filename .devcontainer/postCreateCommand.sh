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
helm plugin install https://github.com/losisin/helm-values-schema-json.git

# install conftest
LATEST_VERSION=$(wget -O - "https://api.github.com/repos/open-policy-agent/conftest/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | cut -c 2-)
wget "https://github.com/open-policy-agent/conftest/releases/download/v${LATEST_VERSION}/conftest_${LATEST_VERSION}_${SYSTEM}_${ARCH_X86_FIX}.tar.gz"
tar xzf conftest_${LATEST_VERSION}_${SYSTEM}_${ARCH_X86_FIX}.tar.gz
sudo mv conftest /usr/local/bin

# install open policy agent
wget -O opa https://github.com/open-policy-agent/opa/releases/download/v1.4.2/opa_${SYSTEM}_${ARCH}_static
sudo mv opa /usr/local/bin
chmod +x /usr/local/bin/opa

# install regal
wget -O regal https://github.com/StyraInc/regal/releases/latest/download/regal_${SYSTEM}_${ARCH_X86_FIX}
sudo mv regal /usr/local/bin
sudo chmod +x /usr/local/bin/regal

# install age
sudo apt install age

# install sops
curl -LO https://github.com/getsops/sops/releases/download/v3.10.2/sops-v3.10.2.${SYSTEM}.${ARCH}
sudo mv sops-v3.10.2.${SYSTEM}.${ARCH} /usr/local/bin/sops
sudo chmod +x /usr/local/bin/sops

# kubeconform
wget -O kubeconform.tar.gz https://github.com/yannh/kubeconform/releases/download/v0.7.0/kubeconform-${SYSTEM}-${ARCH}.tar.gz
tar -xzf kubeconform.tar.gz
sudo mv kubeconform /usr/local/bin/kubeconform
sudo chmod +x /usr/local/bin/kubeconform
