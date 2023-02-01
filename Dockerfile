FROM kalilinux/kali-rolling

SHELL [ "/bin/bash", "--norc", "--noprofile", "-euxo", "pipefail", "-O", "nullglob", "-c" ]
ENV LANG C.UTF-8

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
  apt-get install --autoremove --no-install-recommends -y \
  ca-certificates curl git gnupg \
  && rm -rf -- /var/lib/apt/lists/*

RUN curl -fsSL --tlsv1.2 --proto '=https' https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg
RUN echo 'deb https://download.docker.com/linux/debian bullseye stable' > /etc/apt/sources.list.d/docker.list

RUN curl -fsSL --tlsv1.2 --proto '=https' https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/google.gpg
RUN echo 'deb https://packages.cloud.google.com/apt cloud-sdk main' > /etc/apt/sources.list.d/google-cloud-sdk.list

RUN curl -fsSL --tlsv1.2 --proto '=https' https://packagecloud.io/github/git-lfs/gpgkey | gpg --dearmor -o /etc/apt/trusted.gpg.d/git-lfs.gpg
RUN echo 'deb https://packagecloud.io/github/git-lfs/debian/ bullseye main' > /etc/apt/sources.list.d/git-lfs.list

RUN curl -fsSL --tlsv1.2 --proto '=https' https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/microsoft.gpg
RUN echo 'deb https://packages.microsoft.com/repos/azure-cli/ bullseye main' > /etc/apt/sources.list.d/azure.list

RUN curl -fsSL --tlsv1.2 --proto '=https' https://packages.stripe.dev/api/security/keypair/stripe-cli-gpg/public | gpg --dearmor -o /etc/apt/trusted.gpg.d/stripe.gpg
RUN echo 'deb https://packages.stripe.dev/stripe-cli-debian-local stable main' > /etc/apt/sources.list.d/stripe.list

RUN curl -fsSL --tlsv1.2 --proto '=https' 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | gpg --dearmor -o /etc/apt/trusted.gpg.d/doppler.gpg
RUN echo 'deb https://packages.doppler.com/public/cli/deb/debian any-version main' > /etc/apt/sources.list.d/doppler.list

RUN curl -fsSL --tlsv1.2 --proto '=https' 'https://apt.releases.hashicorp.com/gpg' | gpg --dearmor -o /etc/apt/trusted.gpg.d/hashicorp.gpg
RUN echo 'deb https://apt.releases.hashicorp.com bullseye main' > /etc/apt/sources.list.d/hashicorp.list

RUN apt-get update && \
  apt-get install --autoremove --no-install-recommends -y \
  bind9-dnsutils \
  docker-ce \
  docker-compose-plugin \
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

COPY ./ /config
RUN ln -sv /config ~/
ENV PATH="/config/bin:$PATH"
ENV EDITOR='vim'
RUN mkdir -p ~/.config && ln -s /config/fish ~/.config/fish
RUN chsh -s /usr/bin/fish
RUN useradd -D -s /usr/bin/fish
RUN fish -c fish_update_completions
RUN ln -fs /config/bash/bash.bashrc /etc/bash.bashrc
RUN ln -fs /config/tmux/tmux.conf /etc/tmux.conf
RUN ln -fs /config/vim/vimrc /etc/vim/vimrc
RUN rm -rf -- /etc/skel && mkdir /etc/skel

RUN git clone https://github.com/ytdl-org/youtube-dl /y && \
  cd /y && \
  make youtube-dl youtube-dl.fish PYTHON=python3 && \
  install -m 755 youtube-dl /usr/local/bin/ && \
  install -m 644 youtube-dl.fish /etc/fish/completions/youtube-dl.fish && \
  rm -rf /y

SHELL [ "/usr/bin/fish", "-c" ]

RUN /config/bin/install/bat
RUN /config/bin/install/direnv
RUN /config/bin/install/duf
RUN /config/bin/install/dust
# RUN /config/bin/install/exa
RUN /config/bin/install/fd
RUN /config/bin/install/fnm
RUN /config/bin/install/gh
RUN /config/bin/install/lazygit
RUN /config/bin/install/poetry
RUN /config/bin/install/ripgrep
RUN /config/bin/install/shellcheck
RUN /config/bin/install/tusk
RUN /config/bin/install/xh

RUN rm -rf -- /var/lib/apt/lists/*

CMD ["tmux"]
