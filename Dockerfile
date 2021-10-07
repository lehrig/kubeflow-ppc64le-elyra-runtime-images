# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG ROOT_CONTAINER=docker.io/library/ubuntu:focal
FROM $ROOT_CONTAINER

LABEL maintainer="Sebastian Lehrig <sebastian.lehrig1@ibm.com>"

ARG TARGET_RUNTIME="anaconda"
ARG elyra_version="v3.0.0"
ARG PANDAS_VERSION="1.1.1"
ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"
ARG conda_version="4.10.3"
ARG miniforge_patch_number="6"
ARG miniforge_python="Mambaforge"
ARG miniforge_version="${conda_version}-${miniforge_patch_number}"
ARG IBM_POWERAI_LICENSE_ACCEPT=yes
ARG PYTHON_VERSION=default
ARG PYTORCH_VERSION=1.9.0
ARG R_VERSION=4
ARG TENSORFLOW_VERSION=2.4.1

ENV DEBIAN_FRONTEND noninteractive
ENV XDG_CACHE_HOME="/home/${NB_USER}/.cache/"
ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    NB_USER=$NB_USER \
    NB_UID=$NB_UID \
    NB_GID=$NB_GID \
    NB_PREFIX=/
ENV PATH="${CONDA_DIR}/bin:${PATH}" \
    HOME="/home/${NB_USER}" \
    CONDA_VERSION="${conda_version}" \
    MINIFORGE_VERSION="${miniforge_version}"

# Fix DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# Copy a script that we will use to correct permissions after running certain commands
COPY fix-permissions /usr/local/bin/fix-permissions
RUN chmod a+rx /usr/local/bin/fix-permissions

# Runs executed as root
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    # ----
    curl \
    wget \
    ca-certificates \
    sudo \
    locales \
    fonts-liberation \
    run-one \
    # ----
    vim-tiny \
    git \
    libsm6 \
    libxext-dev \
    libxrender1 \
    lmodern \
    netcat \
    openssh-client \
    # ----
    nano-tiny \
    openssl \
    libffi-dev \
    python-dev \
    gcc \
    g++ \
    && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    echo $NB_USER" ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    update-alternatives --install /usr/bin/nano nano /bin/nano-tiny 10 && \
    sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc && \
    echo 'eval "$(command conda shell.bash hook 2> /dev/null)"' >> /etc/skel/.bashrc && \
    echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \
    sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers && \
    sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers && \
    groupadd -f --gid 1337 $NB_USER && \
    useradd -l -m -s /bin/bash -N -u "${NB_UID}" "${NB_USER}" && \
    mkdir -p "${CONDA_DIR}" && \
    chown "${NB_USER}:${NB_GID}" "${CONDA_DIR}" && \
    chmod g+w /etc/passwd && \
    fix-permissions "${HOME}" && \
    fix-permissions "${CONDA_DIR}"

ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

USER ${NB_UID}

WORKDIR /tmp

# Runs executed as NB_UID
RUN case "$TARGET_RUNTIME" in \
       "anaconda") export RUNTIME_INSTALL="" \
       ;; \
       "pandas") export RUNTIME_INSTALL=\"pandas=$PANDAS_VERSION\" \
       ;; \
       "pytorch-cpu") export RUNTIME_INSTALL=\"pytorch-cpu=$PYTORCH_VERSION\" \
       ;; \
       "pytorch") export RUNTIME_INSTALL=\"pytorch=$PYTORCH_VERSION\" \
       ;; \
       "r") export RUNTIME_INSTALL="r-environment r-essentials r-base" \
       ;; \
       "tensorflow-cpu") export RUNTIME_INSTALL=\"tensorflow-cpu=$TENSORFLOW_VERSION\" \
       ;; \
       "tensorflow") export RUNTIME_INSTALL=\"tensorflow=$TENSORFLOW_VERSION\" \
       ;; \
    esac && \
    mkdir "/home/${NB_USER}/work" && \
    # Prerequisites installation: conda, mamba, pip, tini
    set -x && \
    miniforge_arch=$(uname -m) && \
    export miniforge_arch && \
    miniforge_installer="${miniforge_python}-${miniforge_version}-Linux-${miniforge_arch}.sh" && \
    export miniforge_installer && \
    wget --quiet "https://github.com/conda-forge/miniforge/releases/download/${miniforge_version}/${miniforge_installer}" && \
    /bin/bash "${miniforge_installer}" -f -b -p "${CONDA_DIR}" && \
    rm "${miniforge_installer}" && \
    wget --quiet "https://raw.githubusercontent.com/elyra-ai/elyra/${elyra_version}/etc/generic/requirements-elyra.txt" && \
    # Conda configuration see https://conda.io/projects/conda/en/latest/configuration.html
    echo "conda ${CONDA_VERSION}" >> "${CONDA_DIR}/conda-meta/pinned" && \
    conda config --system --set auto_update_conda false && \
    conda config --system --set show_channel_urls true && \
    conda config --system --set channel_priority true && \
    #conda config --system --prepend channels https://ftp.osuosl.org/pub/open-ce/1.2.2/ && \
    conda config --system --prepend channels https://opence.mit.edu/ && \
    conda config --system --prepend channels https://public.dhe.ibm.com/ibmdl/export/pub/software/server/ibm-ai/conda/ && \
    if [[ "${PYTHON_VERSION}" != "default" ]]; then conda install --yes python="${PYTHON_VERSION}"; fi && \
    conda list python | grep '^python ' | tr -s ' ' | cut -d ' ' -f 1,2 >> "${CONDA_DIR}/conda-meta/pinned" && \
    conda install --quiet --yes \
    # ----
    "conda=${CONDA_VERSION}" \
    'pip' \
    # ----
    ${RUNTIME_INSTALL} \
    # ----
    && \
    conda update --all --quiet --yes && \
    pip install --quiet --no-cache-dir \
    ##################
    # pip packages
    -r requirements-elyra.txt \
    ##################
    && \
    rm requirements-elyra.txt && \
    rm -rf "/home/${NB_USER}/.cache/yarn" && \
    # Clean-Up
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

