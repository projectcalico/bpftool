# Calico bpftool

Base image including a statically compiled bpftool for other calico projects to use.

## Building the image
To build the image:

```
make build
```

The above will build for whatever architecture you are running on. To force a different architecture:

```
ARCH=<somearch> make build
```
