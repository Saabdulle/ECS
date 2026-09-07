# syntax=docker/dockerfile:1.7

FROM python:3.12.10-alpine AS base

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV INSTANCE_CHANGELOG_URL=https://sites.plane.so/pages/691ef037bcfe416a902e48cb55f59891/

WORKDIR /code


# ---------------------------------------------------------
# Runtime dependencies
# ---------------------------------------------------------
RUN apk add --no-cache \
    libpq \
    libxslt \
    xmlsec \
    ca-certificates \
    openssl \
    libffi-dev \
    bash


# ---------------------------------------------------------
# Python dependencies
# ---------------------------------------------------------
COPY requirements.txt ./
COPY requirements ./requirements

RUN apk add --no-cache --virtual .build-deps \
    g++ \
    gcc \
    cargo \
    git \
    make \
    postgresql-dev \
    libc-dev \
    linux-headers \
    && pip install \
        --no-cache-dir \
        --compile \
        -r requirements.txt \
    && apk del .build-deps


# ---------------------------------------------------------
# Application source
# ---------------------------------------------------------
COPY manage.py ./
COPY plane ./plane
COPY templates ./templates
COPY package.json ./
COPY bin ./bin


# ---------------------------------------------------------
# Runtime setup
# ---------------------------------------------------------
RUN mkdir -p /code/plane/logs \
    && chmod +x ./bin/*


EXPOSE 8000

CMD ["./bin/docker-entrypoint-api.sh"]