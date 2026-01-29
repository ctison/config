FROM kalilinux/kali-rolling

SHELL [ "/bin/bash", "--norc", "--noprofile", "-euxo", "pipefail", "-O", "nullglob", "-c" ]
ENV LANG=C.UTF-8

ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt <<EOF
apt-get update
apt-get install --autoremove --no-install-recommends -y \
  ca-certificates curl git gnupg
EOF

ARG CURL='curl -fsSL --tlsv1.3 --proto =https'

RUN $CURL https://mise.jdx.dev/gpg-key.pub | gpg --dearmor -o /etc/apt/trusted.gpg.d/mise.gpg
RUN echo 'deb https://mise.jdx.dev/deb stable main' > /etc/apt/sources.list.d/mise.list

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,target=/var/lib/apt <<EOF
apt-get update
apt-get install --autoremove --no-install-recommends -y \
  aptitude \
  apt-file \
  bind9-dnsutils \
  file \
  iproute2 \
  iptables \
  less \
  man \
  ncat \
  net-tools \
  nmap \
  p7zip \
  mise \
  socat \
  ssh \
  unrar \
  unzip \
  vim \
  xattr \
  xz-utils \
  zip
EOF

RUN rm -rf -- ~/.* ~/* /etc/skel/
RUN mkdir -pm 0700 ~/.config /etc/skel

COPY ./ /config

ENV MISE_ENV=docker
ARG MISE_ALWAYS_KEEP_DOWNLOAD=true
RUN --mount=type=cache,sharing=locked,target=/root/.local/share/mise/downloads \
    mise install

ENTRYPOINT [ "nu", "-l" ]
CMD [ "mise trust" ]
