# syntax=docker/dockerfile:1.7

FROM node:22-alpine AS base

WORKDIR /app

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PNPM_HOME/bin:$PATH"
ENV CI=1
ENV TURBO_TELEMETRY_DISABLED=1

RUN corepack enable pnpm


# ---------------------------------------------------------
# Stage 1 - Prepare Space workspace
# ---------------------------------------------------------
FROM base AS builder

ARG TURBO_VERSION=2.9.18

RUN pnpm add --global turbo@${TURBO_VERSION}

COPY . .

RUN turbo prune --scope=space --docker


# ---------------------------------------------------------
# Stage 2 - Install dependencies and build Space
# ---------------------------------------------------------
FROM base AS build

ENV NODE_ENV=production

ARG VITE_API_BASE_URL=""
ENV VITE_API_BASE_URL=${VITE_API_BASE_URL}

ARG VITE_API_BASE_PATH="/api"
ENV VITE_API_BASE_PATH=${VITE_API_BASE_PATH}

ARG VITE_ADMIN_BASE_URL=""
ENV VITE_ADMIN_BASE_URL=${VITE_ADMIN_BASE_URL}

ARG VITE_ADMIN_BASE_PATH="/god-mode"
ENV VITE_ADMIN_BASE_PATH=${VITE_ADMIN_BASE_PATH}

ARG VITE_SPACE_BASE_URL=""
ENV VITE_SPACE_BASE_URL=${VITE_SPACE_BASE_URL}

ARG VITE_SPACE_BASE_PATH="/spaces"
ENV VITE_SPACE_BASE_PATH=${VITE_SPACE_BASE_PATH}

ARG VITE_LIVE_BASE_URL=""
ENV VITE_LIVE_BASE_URL=${VITE_LIVE_BASE_URL}

ARG VITE_LIVE_BASE_PATH="/live"
ENV VITE_LIVE_BASE_PATH=${VITE_LIVE_BASE_PATH}

ARG VITE_WEB_BASE_URL=""
ENV VITE_WEB_BASE_URL=${VITE_WEB_BASE_URL}

ARG VITE_WEB_BASE_PATH=""
ENV VITE_WEB_BASE_PATH=${VITE_WEB_BASE_PATH}

ARG VITE_WEBSITE_URL="https://plane.so"
ENV VITE_WEBSITE_URL=${VITE_WEBSITE_URL}

ARG VITE_SUPPORT_EMAIL="support@plane.so"
ENV VITE_SUPPORT_EMAIL=${VITE_SUPPORT_EMAIL}

COPY --from=builder /app/out/json/ ./
COPY --from=builder /app/out/pnpm-lock.yaml ./pnpm-lock.yaml
COPY --from=builder /app/out/full/ ./
COPY turbo.json ./turbo.json

RUN --mount=type=cache,id=pnpm-store,target=/pnpm/store \
    pnpm fetch --store-dir=/pnpm/store

RUN --mount=type=cache,id=pnpm-store,target=/pnpm/store \
    pnpm install \
    --offline \
    --frozen-lockfile \
    --store-dir=/pnpm/store \
    --prod=false

RUN pnpm turbo run build --filter=space


# ---------------------------------------------------------
# Stage 3 - Runtime
# ---------------------------------------------------------
FROM base AS production

ENV NODE_ENV=production

RUN apk add --no-cache curl

COPY --from=build /app/apps/space/build ./apps/space/build
COPY --from=build /app/apps/space/node_modules ./apps/space/node_modules
COPY --from=build /app/node_modules ./node_modules

WORKDIR /app/apps/space

EXPOSE 3000

HEALTHCHECK \
    --interval=30s \
    --timeout=5s \
    --start-period=10s \
    --retries=3 \
    CMD curl -fsS http://127.0.0.1:3000/spaces/ >/dev/null || exit 1

CMD ["npx", "react-router-serve", "./build/server/index.js"]