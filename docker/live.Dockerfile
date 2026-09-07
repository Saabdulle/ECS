# syntax=docker/dockerfile:1.7

FROM node:22-alpine AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PNPM_HOME/bin:$PATH"
ENV TURBO_TELEMETRY_DISABLED=1

RUN corepack enable


# ---------------------------------------------------------
# Stage 1 - Prepare Live workspace
# ---------------------------------------------------------
FROM base AS builder

RUN apk add --no-cache libc6-compat

WORKDIR /app

ARG TURBO_VERSION=2.9.18

RUN pnpm add --global turbo@${TURBO_VERSION}

COPY . .

RUN turbo prune --scope=live --docker


# ---------------------------------------------------------
# Stage 2 - Install dependencies and build Live
# ---------------------------------------------------------
FROM base AS build

RUN apk add --no-cache libc6-compat

WORKDIR /app

COPY --from=builder /app/out/json/ ./
COPY --from=builder /app/out/pnpm-lock.yaml ./pnpm-lock.yaml
COPY --from=builder /app/out/full/ ./
COPY turbo.json ./turbo.json

RUN --mount=type=cache,id=pnpm-store,target=/pnpm/store \
    pnpm fetch --store-dir=/pnpm/store

RUN --mount=type=cache,id=pnpm-store,target=/pnpm/store \
    CI=true pnpm install \
    --offline \
    --frozen-lockfile \
    --store-dir=/pnpm/store

RUN pnpm turbo run build --filter=live


# ---------------------------------------------------------
# Stage 3 - Production runtime
# ---------------------------------------------------------
FROM base AS production

WORKDIR /app

COPY --from=build /app/packages ./packages
COPY --from=build /app/apps/live/dist ./apps/live/dist
COPY --from=build /app/apps/live/node_modules ./apps/live/node_modules
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/apps/live/package.json ./apps/live/package.json

EXPOSE 3000

CMD ["node", "apps/live"]