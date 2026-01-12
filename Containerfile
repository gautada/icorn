ARG ALPINE_VERSION=3.23

FROM docker.io/gautada/alpine:$ALPINE_VERSION as BUILD

ARG GITHUB_TAG=dev

RUN apk add --no-cache \
    python3 py3-pip python3-dev \
    build-base musl-dev linux-headers \
    libffi-dev openssl-dev \
    curl uv
WORKDIR /opt
RUN git clone --branch ${GITHUB_TAG} https://github.com/gautada/icorn.git icorn
WORKDIR /opt/icorn
RUN uv venv .venv \
 && uv sync --frozen --no-dev

################################################################################

FROM docker.io/gautada/alpine:$ALPINE_VERSION as CONTAINER

ARG IMAGE_NAME=icorn
ARG IMAGE_VERSION=0.0.1

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL org.opencontainers.image.title="${IMAGE_NAME}"
LABEL org.opencontainers.image.description="A ${IMAGE_NAME} ASGI server"
LABEL org.opencontainers.image.url="https://hub.docker.com/r/gautada/${IMAGE_NAME}"
LABEL org.opencontainers.image.source="https://github.com/gautada/${IMAGE_NAME}"
LABEL org.opencontainers.image.version="${IMAGE_VERSION}"
LABEL org.opencontainers.image.license="Upstream"

# ╭――――――――――――――――――――╮
# │ USER               │
# ╰――――――――――――――――――――╯
ARG USER=icorn
RUN /usr/sbin/usermod -l $USER alpine \
&& /usr/sbin/usermod -d /home/$USER -m $USER \ 
&& /usr/sbin/groupmod -n $USER alpine \
&& /bin/echo "$USER:$USER" | /usr/sbin/chpasswd 

# ╭――――――――――――――――――――╮
# │ CONTAINER          │
# ╰――――――――――――――――――――╯
COPY uvicorn.s6 /etc/services.d/uvicorn/run
RUN apk add --no-cache python3 libffi openssl ca-certificates
# Copy the venv and app code from builder
COPY --from=BUILD /opt/icorn /opt/icorn
RUN chown ${USER}:${USER} -R /opt/icorn /home/${USER}
WORKDIR /home/${USER}

