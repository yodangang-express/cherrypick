FROM debian:bullseye-slim

RUN apt update -y &&\
  apt install -y git python3 make g++ ffmpeg curl libjemalloc-dev libjemalloc2 tini &&\
  ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so &&\
  curl -SLO https://deb.nodesource.com/nsolid_setup_deb.sh &&\
  chmod 500 nsolid_setup_deb.sh &&\
  ./nsolid_setup_deb.sh 20 &&\
  apt install -y nodejs &&\
  npm i -g npm pnpm typescript vite @swc/cli typeorm

RUN apt-get install -y lsb-release &&\
  echo "deb https://packages.cloud.google.com/apt gcsfuse-$(lsb_release -c -s) main" | tee /etc/apt/sources.list.d/gcsfuse.list &&\
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - &&\
  apt-get update -y &&\
  apt-get install -y fuse gcsfuse

RUN apt clean &&\
  rm -rf /var/lib/apt/lists
