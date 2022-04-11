FROM python:3.9
# uncomment below for GPU-based builds
#ARG NVIDIA_RELEASE 22.03
#FROM nvcr.io/nvidia/pytorch:$NVIDIA_RELEASE-py3

WORKDIR /work

COPY requirements.txt /tmp

RUN cd /tmp && pip install -r requirements.txt
