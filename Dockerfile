# cSpell:disable
FROM kalilinux/kali-rolling

SHELL [ "/bin/bash", "--norc", "--noprofile", "-euxo", "pipefail", "-O", "nullglob", "-c" ]
ENV LANG=C.UTF-8

ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked <<EOF
apt-get update
apt-get install --autoremove --no-install-recommends -y \
  ca-certificates curl git gnupg
EOF

ARG CURL='curl -fsSL --tlsv1.3 --proto =https'

RUN $CURL https://mise.jdx.dev/gpg-key.pub | gpg --dearmor -o /etc/apt/trusted.gpg.d/mise.gpg
RUN echo 'deb https://mise.jdx.dev/deb stable main' > /etc/apt/sources.list.d/mise.list

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked <<EOF
apt-get update
apt-get install --autoremove --no-install-recommends -y \
  bind9-dnsutils \
  file \
  fish \
  less \
  man \
  ncat \
  net-tools \
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
RUN useradd -D -s /usr/bin/fish

ENV PATH="/config/bin:~/.local/bin:$PATH"
ENV MISE_ENV=docker
COPY /setup.sh /config/
COPY /mise/ /config/mise/
RUN /config/setup.sh
RUN --mount=type=cache,target=/root/.cache/mise mise install

COPY ./ /config
WORKDIR /config
RUN mise trust

SHELL [ "/usr/bin/fish", "-c" ]

CMD ["fish", "-lc", "zellij -s main"]
