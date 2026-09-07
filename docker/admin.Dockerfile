# syntax=docker/dockerfile:1.7

# ---------------------------------------------------------
# Base Node image
# ---------------------------------------------------------
FROM node:22-alpine AS base

WORKDIR /app

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PNPM_HOME/bin:$PATH"

ENV CI=1
ENV TURBO_TELEMETRY_DISABLED=1

RUN corepack enable pnpm


# ---------------------------------------------------------
# Stage 1 - Prepare the admin workspace
# ---------------------------------------------------------
FROM base AS builder

ARG TURBO_VERSION=2.9.18

RUN pnpm add --global turbo@${TURBO_VERSION}

COPY . .

RUN turbo prune --scope=admin --docker


# ---------------------------------------------------------
# Stage 2 - Install dependencies and build Plane Admin
# ---------------------------------------------------------
FROM base AS build

ENV NODE_ENV=production

# API configuration
ARG VITE_API_BASE_URL=""
ENV VITE_API_BASE_URL=${VITE_API_BASE_URL}

ARG VITE_API_BASE_PATH="/api"
ENV VITE_API_BASE_PATH=${VITE_API_BASE_PATH}

# Admin configuration
ARG VITE_ADMIN_BASE_URL=""
ENV VITE_ADMIN_BASE_URL=${VITE_ADMIN_BASE_URL}

ARG VITE_ADMIN_BASE_PATH="/god-mode"
ENV VITE_ADMIN_BASE_PATH=${VITE_ADMIN_BASE_PATH}

# Space configuration
ARG VITE_SPACE_BASE_URL=""
ENV VITE_SPACE_BASE_URL=${VITE_SPACE_BASE_URL}

ARG VITE_SPACE_BASE_PATH="/spaces"
ENV VITE_SPACE_BASE_PATH=${VITE_SPACE_BASE_PATH}

# Live configuration
ARG VITE_LIVE_BASE_URL=""
ENV VITE_LIVE_BASE_URL=${VITE_LIVE_BASE_URL}

ARG VITE_LIVE_BASE_PATH="/live"
ENV VITE_LIVE_BASE_PATH=${VITE_LIVE_BASE_PATH}

# Web configuration
ARG VITE_WEB_BASE_URL=""
ENV VITE_WEB_BASE_URL=${VITE_WEB_BASE_URL}

ARG VITE_WEB_BASE_PATH=""
ENV VITE_WEB_BASE_PATH=${VITE_WEB_BASE_PATH}

# Plane public settings
ARG VITE_WEBSITE_URL="https://plane.so"
ENV VITE_WEBSITE_URL=${VITE_WEBSITE_URL}

ARG VITE_SUPPORT_EMAIL="support@plane.so"
ENV VITE_SUPPORT_EMAIL=${VITE_SUPPORT_EMAIL}


# Copy pruned dependency metadata
COPY --from=builder /app/out/json/ ./
COPY --from=builder /app/out/pnpm-lock.yaml ./pnpm-lock.yaml

# Copy the pruned workspace
COPY --from=builder /app/out/full/ ./
COPY turbo.json ./turbo.json


# Install dependencies
RUN --mount=type=cache,id=pnpm-store,target=/pnpm/store \
    pnpm fetch --store-dir=/pnpm/store

RUN --mount=type=cache,id=pnpm-store,target=/pnpm/store \
    pnpm install \
    --offline \
    --frozen-lockfile \
    --store-dir=/pnpm/store \
    --prod=false


# Build the admin frontend
RUN pnpm turbo run build --filter=admin


# ---------------------------------------------------------
# Stage 3 - Production Nginx container
# ---------------------------------------------------------
FROM nginx:1.31-alpine AS production

RUN apk add --no-cache curl

COPY apps/admin/nginx/nginx.conf /etc/nginx/nginx.conf

COPY --from=build \
    /app/apps/admin/build/client \
    /usr/share/nginx/html/god-mode

EXPOSE 3000

HEALTHCHECK \
    --interval=30s \
    --timeout=5s \
    --start-period=10s \
    --retries=3 \
    CMD curl -fsS http://127.0.0.1:3000/ >/dev/null || exit 1

CMD ["nginx", "-g", "daemon off;"]