FROM python:3.12-alpine AS builder

ENV VIRTUAL_ENV=/opt/venv \
    PATH=/opt/venv/bin:$PATH

WORKDIR /app
COPY requirements.txt /tmp/

RUN set -eux && \
    apk add --no-cache \
        build-base \
        libffi-dev \
        cargo && \
    python -m venv $VIRTUAL_ENV && \
    $VIRTUAL_ENV/bin/pip install --upgrade pip && \
    $VIRTUAL_ENV/bin/pip install --no-cache-dir --disable-pip-version-check --default-timeout=100 -r /tmp/requirements.txt

FROM python:3.12-alpine

ENV PATH=/opt/venv/bin:$PATH

WORKDIR /app

RUN set -eux && \
    apk add --no-cache \
        tini \
        bash \
        gettext=0.24.1-r0 && \
    rm -rf -- /var/cache/apk/* /usr/share/man/* /usr/share/doc/* /tmp/* /var/tmp/*

COPY --from=builder /opt/venv /opt/venv
COPY . .

RUN set -eux && \
    cd locales && \
    sh ./compile.sh

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["python", "bot.py"]
