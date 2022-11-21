FROM python:3.10-slim-buster
# uncomment below for GPU-based builds
#ARG NVIDIA_RELEASE 22.03
#FROM nvcr.io/nvidia/pytorch:$NVIDIA_RELEASE-py3


# mlflow uses git to version your files
RUN apt-get update -y && \
	apt-get install -yqq \
	git \
	&& \
	rm -rf /var/lib/apt/lists* && \
	apt-get clean -yqq

WORKDIR /work

COPY requirements.txt /tmp

RUN cd /tmp && pip install -r requirements.txt
