FROM postgres:17.2-alpine

WORKDIR /

RUN apk add --no-cache curl python3 &&\
  curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-arm.tar.gz &&\
  tar -xf google-cloud-cli-linux-arm.tar.gz &&\
  /google-cloud-sdk/install.sh
