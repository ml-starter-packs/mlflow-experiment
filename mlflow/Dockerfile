FROM python:3.10-slim-buster
# on arm64 systems, shap needs to build from source
# we uninstall the compiler afterwards to save space
RUN apt-get update -y && \
	apt-get install -yqq \
	libpq-dev \
	libssl-dev \
	&& \
	rm -rf /var/lib/apt/lists* && \
	apt-get clean -yqq

# Install python packages
COPY requirements.txt /tmp
RUN pip install -r /tmp/requirements.txt
