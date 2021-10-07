# Elyra Runtime Images for Kubeflow on ppc64le
[Elyra](https://github.com/elyra-ai/elyra) runtime images for ppc64le (IBM Power processor architecture) to be used with Kubeflow.


### Pre-Build Images
Go to my kubeflow-elyra-runtimes-ppc64le repository at [IBM's quay.io page](https://quay.io/repository/ibm/kubeflow-elyra-runtimes-ppc64le?tab=tags).

Overview:
- Python v3.8 / Elyra v3.0.0 / Conda v4.10.3: quay.io/ibm/kubeflow-elyra-runtimes-ppc64le:py3.8-conda4.10.3
- Python v3.8 / Elyra v3.0.0 / Conda v4.10.3 / Pandas 1.1.1: quay.io/ibm/kubeflow-elyra-runtimes-ppc64le:py3.8-pandas1.1.1
- Python v3.8 / Elyra v3.0.0 / Conda v4.10.3 / Tensorflow 1.15.2: quay.io/ibm/kubeflow-elyra-runtimes-ppc64le:py3.8-tensorflow1.15.2
- Python v3.8 / Elyra v3.0.0 / Conda v4.10.3 / Tensorflow 2.3.0: quay.io/ibm/kubeflow-elyra-runtimes-ppc64le:py3.8-tensorflow2.3.0
- Python v3.8 / Elyra v3.0.0 / Conda v4.10.3 / Tensorflow-cpu 1.15.2: quay.io/ibm/kubeflow-elyra-runtimes-ppc64le:py3.8-tensorflow-cpu1.15.2
- Python v3.8 / Elyra v3.0.0 / Conda v4.10.3 / Tensorflow-cpu 2.3.0: quay.io/ibm/kubeflow-elyra-runtimes-ppc64le:py3.8-tensorflow-cpu2.3.0

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

export TARGET_RUNTIME=anaconda|pandas|pytorch|r|tensorflow

export ELYRA_VERSION=v3.0.0
export PYTHON_VERSION=3.8
export CUSTOM_CONDA_VERSION=4.10.3
export MINIFORGE_PATCH_NUMBER=6
export PANDAS_VERSION=1.1.1
export TENSORFLOW_VERSION=2.3.0
export PYTORCH_VERSION=1.4
export R_VERSION=4

export REGISTRY=quay.io/ibm
export IMAGE=kubeflow-elyra-runtimes-ppc64le

case "$TARGET_RUNTIME" in
   "anaconda") export RUNTIME_VERSION=$CUSTOM_CONDA_VERSION
   ;;
   "pandas") export RUNTIME_VERSION=$PANDAS_VERSION 
   ;;
   "pytorch") export RUNTIME_VERSION=$PYTORCH_VERSION 
   ;;
   "r") export RUNTIME_VERSION=$R_VERSION
   ;;
   "tensorflow") export RUNTIME_VERSION=$TENSORFLOW_VERSION
   ;;
   "tensorflow-cpu") export RUNTIME_VERSION=$TENSORFLOW_VERSION
   ;;
esac

export TAG=py${PYTHON_VERSION}-${TARGET_RUNTIME}${RUNTIME_VERSION}
export IMAGE=$REGISTRY/${IMAGE}:${TAG}
```

##### Option (a): Podman
```
podman build --format docker --build-arg TARGET_RUNTIME=$TARGET_RUNTIME --build-arg NB_GID=0 --build-arg elyra_version=$ELYRA_VERSION --build-arg PYTHON_VERSION=$PYTHON_VERSION --build-arg conda_version=$CUSTOM_CONDA_VERSION --build-arg miniforge_patch_number=$MINIFORGE_PATCH_NUMBER --build-arg PANDAS_VERSION=$PANDAS_VERSION --build-arg PYTORCH_VERSION=$PYTORCH_VERSION --build-arg R_VERSION=$R_VERSION --build-arg TENSORFLOW_VERSION=$TENSORFLOW_VERSION -t $IMAGE -f Dockerfile .
```

##### Option (b): Docker
```
docker build --build-arg TARGET_RUNTIME=$TARGET_RUNTIME --build-arg NB_GID=0 --build-arg elyra_version=$ELYRA_VERSION --build-arg PYTHON_VERSION=$PYTHON_VERSION --build-arg conda_version=$CUSTOM_CONDA_VERSION --build-arg miniforge_patch_number=$MINIFORGE_PATCH_NUMBER --build-arg PANDAS_VERSION=$PANDAS_VERSION --build-arg PYTORCH_VERSION=$PYTORCH_VERSION --build-arg R_VERSION=$R_VERSION --build-arg TENSORFLOW_VERSION=$TENSORFLOW_VERSION -t $IMAGE -f Dockerfile .

```
