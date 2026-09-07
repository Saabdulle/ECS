# syntax=docker/dockerfile:1.7

# ---------------------------------------------------------
# Base Node image
# ---------------------------------------------------------

FROM node:22-alpine AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PNPM_HOME/bin:$PATH"

RUN corepack enable


# ---------------------------------------------------------
# Stage 1 - Prepare the web workspace
# ---------------------------------------------------------
FROM base AS builder

RUN apk add --no-cache libc6-compat

WORKDIR /app

ARG TURBO_VERSION=2.9.18

RUN pnpm add --global turbo@${TURBO_VERSION}

COPY . .

RUN turbo prune web --docker


# ---------------------------------------------------------
# Stage 2 - Install dependencies and build Plane Web
# ---------------------------------------------------------
FROM base AS build

RUN apk add --no-cache libc6-compat

WORKDIR /app

# Copy only dependency metadata first
COPY --from=builder /app/out/json/ ./
COPY --from=builder /app/out/pnpm-lock.yaml ./pnpm-lock.yaml

# Install workspace dependencies
RUN --mount=type=cache,id=pnpm-store,target=/pnpm/store \
    pnpm fetch --store-dir=/pnpm/store

COPY --from=builder /app/out/full/ ./
COPY turbo.json ./turbo.json

RUN --mount=type=cache,id=pnpm-store,target=/pnpm/store \
    CI=true pnpm install \
    --offline \
    --frozen-lockfile \
    --store-dir=/pnpm/store


# ---------------------------------------------------------
# Plane build configuration
# ---------------------------------------------------------

ARG VITE_API_BASE_URL=""
ENV VITE_API_BASE_URL=${VITE_API_BASE_URL}

ARG VITE_ADMIN_BASE_URL=""
ENV VITE_ADMIN_BASE_URL=${VITE_ADMIN_BASE_URL}

ARG VITE_ADMIN_BASE_PATH="/god-mode"
ENV VITE_ADMIN_BASE_PATH=${VITE_ADMIN_BASE_PATH}

ARG VITE_LIVE_BASE_URL=""
ENV VITE_LIVE_BASE_URL=${VITE_LIVE_BASE_URL}

ARG VITE_LIVE_BASE_PATH="/live"
ENV VITE_LIVE_BASE_PATH=${VITE_LIVE_BASE_PATH}

ARG VITE_SPACE_BASE_URL=""
ENV VITE_SPACE_BASE_URL=${VITE_SPACE_BASE_URL}

ARG VITE_SPACE_BASE_PATH="/spaces"
ENV VITE_SPACE_BASE_PATH=${VITE_SPACE_BASE_PATH}

ARG VITE_WEB_BASE_URL=""
ENV VITE_WEB_BASE_URL=${VITE_WEB_BASE_URL}

ENV NEXT_TELEMETRY_DISABLED=1
ENV TURBO_TELEMETRY_DISABLED=1

RUN pnpm turbo run build --filter=web


# ---------------------------------------------------------
# Stage 3 - Production Nginx image
# ---------------------------------------------------------
FROM nginx:1.31-alpine AS production

# curl is installed specifically for the ECS/container
# health check.
RUN apk add --no-cache curl

COPY apps/web/nginx/nginx.conf /etc/nginx/nginx.conf

COPY --from=build \
    /app/apps/web/build/client \
    /usr/share/nginx/html

EXPOSE 3000

HEALTHCHECK \
    --interval=30s \
    --timeout=5s \
    --start-period=10s \
    --retries=3 \
    CMD curl -f http://127.0.0.1:3000/ || exit 1

CMD ["nginx", "-g", "daemon off;"]