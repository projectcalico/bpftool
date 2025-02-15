# Copyright (c) 2019-2024 Tigera, Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM --platform=amd64 calico/qemu-user-static:latest as qemu

FROM ubuntu:22.04 as bpftool-build

ARG SOURCE_REPO=https://github.com/libbpf/bpftool.git
ARG SOURCE_REF=main

COPY --from=qemu /usr/bin/qemu-*-static /usr/bin

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        gpg gpg-agent libelf-dev libmnl-dev libc-dev libgcc-12-dev libcap-dev \
        bash-completion binutils binutils-dev ca-certificates make git \
        xz-utils gcc pkg-config bison flex build-essential clang llvm llvm-dev && \
    apt-get purge --auto-remove && \
    apt-get clean

WORKDIR /tmp

RUN git clone --recurse-submodules --depth 1 -b $SOURCE_REF $SOURCE_REPO && \
    EXTRA_CFLAGS=--static OUTPUT=/usr/bin/ make -C bpftool/src -j "$(nproc)" && \
    strip /usr/bin/bpftool  && \
    ldd /usr/bin/bpftool 2>&1 | grep -q -e "Not a valid dynamic program" \
        -e "not a dynamic executable" || \
	    ( echo "Error: bpftool is not statically linked"; false ) && \
    rm -rf /tmp/bpftool

FROM scratch
COPY --from=bpftool-build /usr/bin/bpftool /bpftool
LABEL maintainer="maintainers@tigera.io"
