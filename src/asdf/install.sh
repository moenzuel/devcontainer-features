#!/bin/bash
set -e

VERSION="${VERSION:-"latest"}"

INSTALL_DIR="/.asdf"

if [[ "${VERSION}" != "latest" ]]; then
    SUFFIX_URL="tags/v${VERSION}"
else
    SUFFIX_URL="latest"
fi

METADATA_URL="https://api.github.com/repos/asdf-vm/asdf/releases/${SUFFIX_URL}"

{
    TMP_DIR=$(mktemp -d -t asdf-metadata.XXXXXXXXXX)
    TMP_METADATA="${TMP_DIR}/asdf.json"

    cleanup() {
        local code=$?
        set +e
        trap - EXIT
        rm -rf "${TMP_DIR}"
        exit ${code}
    }
    trap cleanup INT EXIT
}


echo "Downloading metadata ${METADATA_URL}"
curl -o "${TMP_METADATA}" -sfL "${METADATA_URL}"

VERSION_TAG=$(grep '"tag_name":' "${TMP_METADATA}" | sed -E 's/.*"([^"]+)".*/\1/' | cut -c 2-)
if [[ -n "${VERSION_TAG}" ]]; then
    echo "Using ${VERSION_TAG} as release"
else
    echo "Unable to determine release version" >&2
    exit 1
fi

git clone https://github.com/asdf-vm/asdf.git ${INSTALL_DIR} --branch v$VERSION_TAG

# TODO - add no git option

# setup asdf for installs
export ASDF_DIR="${INSTALL_DIR}"
export ASDF_DATA_DIR="${INSTALL_DIR}"
. /${INSTALL_DIR}/asdf.sh

# bash
cat >>/etc/bash.bashrc <<EOL
export ASDF_DIR=${INSTALL_DIR}
export ASDF_DATA_DIR=${INSTALL_DIR}
. ${INSTALL_DIR}/asdf.sh
. ${INSTALL_DIR}/completions/asdf.bash
EOL

# zsh
cat >>${_REMOTE_USER_HOME}/.zshrc <<EOL
export ASDF_DIR=${INSTALL_DIR}
export ASDF_DATA_DIR=${INSTALL_DIR}
. ${INSTALL_DIR}/asdf.sh
fpath=(${INSTALL_DIR}/completions \$fpath)
autoload -Uz compinit && compinit
EOL

# TODO other shells maybe?

# add plugins
if [ ! -z "${PLUGINS}" ] && [ "${PLUGINS}" != "none" ]; then
    echo "Adding plugins \"${PLUGINS}\"..."
    IFS=, read -ra PLUGIN_ARRAY <<< "$PLUGINS"
    for i in "${PLUGIN_ARRAY[@]}"
    do
        asdf plugin add ${i}
    done
fi

# install versions
if [ ! -z "${TOOLVERSIONS}" ] && [ "${TOOLVERSIONS}" != "none" ]; then
    echo "Installing tool versions \"${TOOLVERSIONS}\"..."
    IFS=, read -ra TOOL_ARRAY <<< "$TOOLVERSIONS"
    for i in "${TOOL_ARRAY[@]}"
    do
        parts=( $i )
        if [ "${parts[1]}" == "latest" ]; then
            parts[1]="$(asdf latest ${parts[0]})"
        fi

        asdf install ${parts[0]} ${parts[1]}
        # set root global so tool can be used for other installs
        asdf global ${parts[0]} ${parts[1]}
        echo "${parts[0]} ${parts[1]}" >> ${_REMOTE_USER_HOME}/.tool-versions
    done
fi

chown ${_REMOTE_USER} -R ${INSTALL_DIR}
