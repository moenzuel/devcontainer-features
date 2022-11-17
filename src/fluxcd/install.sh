#!/bin/sh
set -e

FLUX_VERSION=${VERSION:-"latest"}

# do install
curl -s https://raw.githubusercontent.com/fluxcd/flux2/main/install/flux.sh | sudo bash

# bash completion
flux completion bash > /etc/bash_completion.d/fluxcd

# zsh completion
if [ -e "${USERHOME}}/.oh-my-zsh" ]; then
    mkdir -p "${USERHOME}/.oh-my-zsh/completions"
    flux completion zsh > "${USERHOME}/.oh-my-zsh/completions/_fluxcd"
    chown -R "${USERNAME}" "${USERHOME}/.oh-my-zsh"
fi
