# Elyra Runtime Images for Kubeflow on ppc64le

[Elyra](https://github.com/elyra-ai/elyra) runtime images for ppc64le (IBM Power processor architecture) to be used with Kubeflow.

### Building Images

#### Prerequisites
1. Install podman (`yum install docker -y`) or docker (see [OpenPOWER@UNICAMP guide](https://openpower.ic.unicamp.br/post/installing-docker-from-repository/)).
2. `sudo systemctl enable --now docker`

#### Builds
Single-step images are used (smaller file size).

##### Configuration
```
git clone https://github.com/lehrig/kubeflow-ppc64le-elyra-runtime-images
cd kubeflow-ppc64le-elyra-runtime-images

export elyra_version=v3.0.0
export PYTHON_VERSION=3.8
export conda_version=4.10.3
export miniforge_patch_number=6

export ANACONDA_IMAGE=quay.io/ibm/kubeflow-elyra-runtime-anaconda-ppc64le:py$PYTHON_VERSION-conda$conda_version
```

##### Podman
```
podman build --format docker --build-arg NB_GID=0 --build-arg elyra_version=$elyra_version --build-arg PYTHON_VERSION=$PYTHON_VERSION --build-arg conda_version=$conda_version --build-arg miniforge_patch_number=$miniforge_patch_number -t $ANACONDA_IMAGE -f Dockerfile.anaconda .
```
