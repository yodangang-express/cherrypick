FROM debian:bookworm-20250317-slim

RUN apt-get update -y &&\
  apt-get install -y lsb-release curl python3 &&\
  apt clean &&\
  rm -rf /var/lib/apt/lists

WORKDIR /google

RUN mkdir /google &&\
  cd /google &&\
  curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz &&\
  tar -xf google-cloud-cli-linux-x86_64.tar.gz &&\
  ./google-cloud-sdk/install.sh
