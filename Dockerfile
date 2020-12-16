FROM ubuntu:18.04
MAINTAINER root@kksg.net
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        wget \
        libprotobuf-dev libleveldb-dev libsnappy-dev libopencv-dev \
        libhdf5-serial-dev protobuf-compiler \
        cython \
        python-numpy \
        python-scipy \
        python-skimage \
        python-h5py \
        python-networkx \
        python-pandas \
        python-protobuf \
        libdc1394-22-dev \
        libatlas-base-dev \
        libboost-all-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libopencv-dev \
        libprotobuf-dev \
        libsnappy-dev \
        protobuf-compiler \
        python-dev \
        python-numpy \
        python-pip \
        libssl-dev \
	curl \
        python-scipy && \
    rm -rf /var/lib/apt/lists/*

ENV CAFFE_ROOT=/opt/caffe
WORKDIR $CAFFE_ROOT

# FIXME: clone a specific git tag and use ARG instead of ENV once DockerHub supports this.
ENV CLONE_TAG=master

RUN git clone -b ${CLONE_TAG} --depth 1 https://github.com/BVLC/caffe.git . && \
    for req in $(cat python/requirements.txt) pydot; do pip install $req; done && \
    mkdir build && cd build && \
    cmake -DCPU_ONLY=1 .. && \
    make -j"$(nproc)"

RUN curl https://bootstrap.pypa.io/get-pip.py | python
RUN pip install setuptools
RUN pip install pip-review
RUN pip install bottle
RUN pip install requests

ENV PYCAFFE_ROOT $CAFFE_ROOT/python
ENV PYTHONPATH $PYCAFFE_ROOT:$PYTHONPATH
ENV PATH $CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH
RUN echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig

EXPOSE 80

WORKDIR /workspace
COPY ./ /workspace
CMD ["/usr/bin/python", "./app.py"]
