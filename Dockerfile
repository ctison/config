FROM ubuntu:20.10@sha256:a569d854594dae4c70f0efef5f5857eaa3b97cdb1649ce596b113408a0ad5f7f as ubuntu

SHELL [ "/bin/bash", "--norc", "--noprofile", "-euxo", "pipefail", "-O", "nullglob", "-c" ]
ENV LANG C.UTF-8

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
  apt-get install --autoremove --no-install-recommends -y \
  apt-transport-https ca-certificates dirmngr curl git gnupg \
  && rm -rf -- /var/lib/apt/lists/*

ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN echo 'deb https://download.docker.com/linux/ubuntu focal stable' > /etc/apt/sources.list.d/docker.list

RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN echo 'deb https://packages.cloud.google.com/apt cloud-sdk main' > /etc/apt/sources.list.d/google-cloud-sdk.list

RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
RUN echo 'deb https://deb.nodesource.com/node_14.x focal main' > /etc/apt/sources.list.d/nodesource.list

RUN curl -fsSL https://packagecloud.io/github/git-lfs/gpgkey | apt-key add -
RUN echo 'deb https://packagecloud.io/github/git-lfs/ubuntu/ focal main' > /etc/apt/sources.list.d/git-lfs.list

RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN echo 'deb https://packages.microsoft.com/repos/azure-cli/ focal main' > /etc/apt/sources.list.d/azure.list

RUN apt-get update && \
  apt-get install --autoremove --no-install-recommends -y \
  fish less tmux vim \
  && rm -rf -- /var/lib/apt/lists/*

COPY ./ /config
RUN ln -sv /config ~/
ENV PATH="/config/bin:$PATH"
ENV EDITOR='vim'
RUN rm -rf -- /etc/fish
RUN ln -s /config/fish /etc/fish
RUN chsh -s /usr/bin/fish
RUN useradd -D -s /usr/bin/fish
RUN fish -c fish_update_completions
RUN ln -fs /config/bash/bash.bashrc /etc/bash.bashrc
RUN ln -fs /config/tmux/tmux.conf /etc/tmux.conf
RUN ln -fs /config/vim/vimrc /etc/vim/vimrc
RUN rm -rf -- /etc/skel && mkdir /etc/skel

CMD ["tmux"]

FROM ubuntu as kali

ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

RUN curl -fsSL https://archive.kali.org/archive-key.asc | apt-key add -
RUN echo 'deb https://http.kali.org/kali kali-rolling main contrib non-free' > /etc/apt/sources.list.d/kali.list
RUN echo 'deb https://http.kali.org/kali kali-experimental main contrib non-free' >> /etc/apt/sources.list.d/kali.list
RUN echo 'deb https://http.kali.org/kali kali-bleeding-edge main contrib non-free' >> /etc/apt/sources.list.d/kali.list

RUN sed -Ei 's|^(path-exclude=/usr/share/man/)|# \1|' /etc/dpkg/dpkg.cfg.d/excludes

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
  apt-get install --autoremove --no-install-recommends -y \
  bind9-host \
  docker-ce \
  kubectl \
  make \
  man \
  ncat \
  net-tools \
  p7zip \
  pinfo \
  socat \
  ssh \
  unrar \
  xattr \
  zip \
  && rm -rf -- /var/lib/apt/lists/*