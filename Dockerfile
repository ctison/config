# cSpell:disable
FROM kalilinux/kali-rolling

SHELL [ "/bin/bash", "--norc", "--noprofile", "-euxo", "pipefail", "-O", "nullglob", "-c" ]
ENV LANG=C.UTF-8

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
  apt-get install --autoremove --no-install-recommends -y \
  ca-certificates curl git gnupg \
  && rm -rf -- /var/lib/apt/lists/*

ARG CURL='curl -fsSL --tlsv1.3 --proto =https'

RUN $CURL https://mise.jdx.dev/gpg-key.pub | gpg --dearmor -o /etc/apt/trusted.gpg.d/mise.gpg
RUN echo 'deb https://mise.jdx.dev/deb stable main' > /etc/apt/sources.list.d/mise.list

RUN apt-get update && \
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
  zip \
  && rm -rf -- /var/lib/apt/lists/*

RUN rm -rf -- ~/.* ~/* /etc/skel/
RUN mkdir -pm 0700 ~/.config /etc/skel
RUN useradd -D -s /usr/bin/fish

ENV PATH="/config/bin:~/.local/bin:$PATH"
COPY /setup.sh /config/
RUN /config/setup.sh

COPY ./ /config

WORKDIR /config
RUN mise trust && mise install

SHELL [ "/usr/bin/fish", "-c" ]

CMD ["fish", "-lc", "zellij -s main"]
