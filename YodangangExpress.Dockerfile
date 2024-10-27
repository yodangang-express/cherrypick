FROM debian:bullseye-20241016-slim AS base

RUN rm /var/lib/dpkg/info/libc-bin.* &&\
    apt clean -y &&\
    apt update -y &&\
    apt install -y libc-bin \
    git \
    python3 \
    make \
    g++ \
    ffmpeg \
    curl \
    libjemalloc-dev \
    libjemalloc2 \
    tini &&\
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

FROM base AS builder
COPY . /cherrypick
WORKDIR /cherrypick
USER root
ENV NODE_ENV=production
RUN git submodule update --init &&\
  corepack enable &&\
  pnpm install &&\
  pnpm build

FROM base
WORKDIR /cherrypick
USER root
RUN mkdir -p /cherrypick/packages/backend &&\
  mkdir -p /cherrypick/packages/frontend &&\
  mkdir -p /cherrypick/packages/cherrypick-js &&\
  mkdir -p /cherrypick/packages/misskey-reversi &&\
  mkdir -p /cherrypick/.config &&\
  mkdir -p /cherrypick/files
COPY --from=builder /cherrypick/built /cherrypick/built
COPY --from=builder /cherrypick/package.json /cherrypick/package.json
COPY --from=builder /cherrypick/pnpm-workspace.yaml /cherrypick/pnpm-workspace.yaml
COPY --from=builder /cherrypick/healthcheck.sh /cherrypick/healthcheck.sh
COPY --from=builder /cherrypick/node_modules /cherrypick/node_modules
COPY --from=builder /cherrypick/packages/backend/package.json /cherrypick/packages/backend/package.json
COPY --from=builder /cherrypick/packages/backend/scripts/check_connect.js /cherrypick/packages/backend/scripts/check_connect.js
COPY --from=builder /cherrypick/packages/backend/ormconfig.js /cherrypick/packages/backend/ormconfig.js
COPY --from=builder /cherrypick/packages/backend/node_modules /cherrypick/packages/backend/node_modules
COPY --from=builder /cherrypick/packages/backend/built /cherrypick/packages/backend/built
COPY --from=builder /cherrypick/packages/backend/assets /cherrypick/packages/backend/assets
COPY --from=builder /cherrypick/packages/backend/migration /cherrypick/packages/backend/migration
COPY --from=builder /cherrypick/packages/frontend/assets /cherrypick/packages/frontend/assets
COPY --from=builder /cherrypick/packages/cherrypick-js/package.json /cherrypick/packages/cherrypick-js/package.json
COPY --from=builder /cherrypick/packages/cherrypick-js/built /cherrypick/packages/cherrypick-js/built
COPY --from=builder /cherrypick/packages/cherrypick-js/node_modules /cherrypick/packages/cherrypick-js/node_modules
COPY --from=builder /cherrypick/packages/misskey-reversi/package.json /cherrypick/packages/misskey-reversi/package.json
COPY --from=builder /cherrypick/packages/misskey-reversi/built /cherrypick/packages/misskey-reversi/built
COPY --from=builder /cherrypick/packages/misskey-reversi/node_modules /cherrypick/packages/misskey-reversi/node_modules
COPY --from=builder /cherrypick/packages/misskey-bubble-game/package.json /cherrypick/packages/misskey-bubble-game/package.json
COPY --from=builder /cherrypick/packages/misskey-bubble-game/built /cherrypick/packages/misskey-bubble-game/built
COPY --from=builder /cherrypick/packages/misskey-bubble-game/node_modules /cherrypick/packages/misskey-bubble-game/node_modules
COPY --from=builder /cherrypick/fluent-emojis /cherrypick/fluent-emojis
ENV LD_PRELOAD=/usr/local/lib/libjemalloc.so
ENV NODE_ENV=production
HEALTHCHECK --interval=5s --retries=20 CMD ["/bin/bash", "/cherrypick/healthcheck.sh"]
ENTRYPOINT ["/usr/bin/tini", "--"]
EXPOSE 3000
CMD pnpm run migrateandstart
