#!/bin/sh
set -e

FLUX_VERSION=${VERSION:-"latest"}

# do install
curl -s https://raw.githubusercontent.com/fluxcd/flux2/main/install/flux.sh | bash

# bash completion
flux completion bash > /etc/bash_completion.d/fluxcd

# zsh completion
if [ -e "${_REMOTE_USER_HOME}/.oh-my-zsh" ]; then
    mkdir -p "${_REMOTE_USER_HOME}/.oh-my-zsh/completions"
    flux completion zsh > "${_REMOTE_USER_HOME}/.oh-my-zsh/completions/_fluxcd"
    chown -R "${_REMOTE_USER_HOME}" "${_REMOTE_USER_HOME}/.oh-my-zsh"
fi
