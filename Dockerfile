FROM kalilinux/kali-rolling

SHELL [ "/bin/bash", "--norc", "--noprofile", "-euxo", "pipefail", "-O", "nullglob", "-c" ]
ENV LANG C.UTF-8

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
  apt-get install --autoremove --no-install-recommends -y \
  ca-certificates curl git gnupg \
  && rm -rf -- /var/lib/apt/lists/*

ARG CURL='curl -fsSL --tlsv1.2 --proto =https'

RUN $CURL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg
RUN echo 'deb https://download.docker.com/linux/debian bullseye stable' > /etc/apt/sources.list.d/docker.list

RUN $CURL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes.gpg
RUN echo "deb https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" > /etc/apt/sources.list.d/kubernetes.list

RUN $CURL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/google.gpg
RUN echo 'deb https://packages.cloud.google.com/apt cloud-sdk main' > /etc/apt/sources.list.d/google-cloud-sdk.list

RUN $CURL https://packagecloud.io/github/git-lfs/gpgkey | gpg --dearmor -o /etc/apt/trusted.gpg.d/git-lfs.gpg
RUN echo 'deb https://packagecloud.io/github/git-lfs/debian/ bullseye main' > /etc/apt/sources.list.d/git-lfs.list

RUN $CURL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/microsoft.gpg
RUN echo 'deb https://packages.microsoft.com/repos/azure-cli/ bullseye main' > /etc/apt/sources.list.d/azure.list

RUN $CURL https://packages.stripe.dev/api/security/keypair/stripe-cli-gpg/public | gpg --dearmor -o /etc/apt/trusted.gpg.d/stripe.gpg
RUN echo 'deb https://packages.stripe.dev/stripe-cli-debian-local stable main' > /etc/apt/sources.list.d/stripe.list

RUN $CURL 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | gpg --dearmor -o /etc/apt/trusted.gpg.d/doppler.gpg
RUN echo 'deb https://packages.doppler.com/public/cli/deb/debian any-version main' > /etc/apt/sources.list.d/doppler.list

RUN $CURL 'https://apt.releases.hashicorp.com/gpg' | gpg --dearmor -o /etc/apt/trusted.gpg.d/hashicorp.gpg
RUN echo 'deb https://apt.releases.hashicorp.com bullseye main' > /etc/apt/sources.list.d/hashicorp.list

RUN apt-get update && \
  apt-get install --autoremove --no-install-recommends -y \
  bind9-dnsutils \
  docker-ce \
  file \
  fish \
  htop \
  jq \
  less \
  make \
  man \
  ncat \
  net-tools \
  p7zip \
  pinfo \
  socat \
  ssh \
  tmux \
  unrar \
  unzip \
  vim \
  xattr \
  xz-utils \
  zip

RUN rm -rf -- ~/.* ~/* /etc/skel/
RUN mkdir -pm 0700 ~/.config /etc/skel

# Set fish as default shell for future users
RUN useradd -D -s /usr/bin/fish

ENV PATH="/config/bin:~/.local/bin:$PATH"
COPY /setup.sh /config/
COPY /bin/install-nushell /bin/gpm /config/bin/
RUN /config/setup.sh

RUN rm -rf -- /var/lib/apt/lists/*

COPY ./ /config

SHELL [ "/usr/bin/fish", "-c" ]

CMD ["fish", "-lc", "zellij -s main"]
