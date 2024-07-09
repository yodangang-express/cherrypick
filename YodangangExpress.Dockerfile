FROM juunini/cherrypick:builder-0.1 AS base

FROM base AS builder
COPY . /cherrypick
WORKDIR /cherrypick
USER root
ENV NODE_ENV=production
ENV VITE_CLOUD_STORAGE_ORIGIN=https://storage.googleapis.com/yodangang-express/
RUN git submodule update --init &&\
  corepack enable &&\
  pnpm install &&\
  pnpm build

FROM base
WORKDIR /cherrypick
RUN mkdir -p /cherrypick/packages/backend &&\
  mkdir -p /cherrypick/packages/frontend &&\
  mkdir -p /cherrypick/packages/cherrypick-js &&\
  mkdir -p /cherrypick/packages/misskey-reversi &&\
  mkdir -p /cherrypick/.config
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
CMD ["pnpm", "run", "migrateandstart"]
