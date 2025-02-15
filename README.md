# Calico bpftool

Base image including a statically compiled bpftool for other calico projects to use.

## Building the image
To build the multi-arch image:

Make sure you have configured docker for multi-arch builds: [enable the 
containerd image store](https://docs.docker.com/engine/storage/containerd/).  Then:

```
make image
```

To build a single-arch image for your system:
```
make image-single-platform
```

To build for specific platforms, use the `DOCKER_PLATFORMS` variable:
```
make image DOCKER_PLATFORMS=linux/amd64,linux/arm64/v8,linux/ppc64le,linux/riscv64,linux/s390x
```

To build/push the image:
```
make push
```
