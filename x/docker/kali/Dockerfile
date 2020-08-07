FROM debian:10.4@sha256:aaaaf56b44807c64d294e6c8059b479f35350b454492398225034174808d1726

SHELL [ "/bin/bash", "-euxo", "pipefail", "-c" ]

ENV LANG C.UTF-8

RUN apt-get update && \
	apt-get install --no-install-recommends -y \
	apt-transport-https ca-certificates dirmngr curl git gnupg wget \
	&& rm -rf /var/lib/apt/lists/*

RUN rm -rf /root && mkdir -m 700 /root
RUN rm -f /etc/apt/sources.list

# Suppress an apt-key warning about stdout not being a terminal.
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

RUN curl -sS https://archive.kali.org/archive-key.asc | apt-key add -
RUN echo 'deb https://http.kali.org/kali kali-rolling main contrib non-free' > /etc/apt/sources.list.d/kali.list
RUN echo 'deb https://http.kali.org/kali kali-experimental main contrib non-free' >> /etc/apt/sources.list.d/kali.list
RUN echo 'deb https://http.kali.org/kali kali-bleeding-edge main contrib non-free' >> /etc/apt/sources.list.d/kali.list

RUN echo 'deb https://packages.cloud.google.com/apt cloud-sdk main' > /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl -sS https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

RUN echo 'deb https://deb.nodesource.com/node_14.x buster main' > /etc/apt/sources.list.d/nodesource.list
RUN curl -sS https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -

RUN echo 'deb https://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -

RUN echo 'deb https://packagecloud.io/github/git-lfs/debian/ buster main' > /etc/apt/sources.list.d/git-lfs.list
RUN curl -sSL https://packagecloud.io/github/git-lfs/gpgkey | apt-key add -

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y && \
	apt-get install --autoremove --no-install-recommends -y \
	bind9-host \
	docker.io \
	fish \
	git \
	htop \
	jq \
	kubectl \
	less \
	locales \
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
	vim \
	xattr \
	zip \
	&& rm -rf /var/lib/apt/lists/*

COPY ./ /config
RUN ln -sv /config ~/

ENV PATH="/root/config/bin:$PATH"
ENV EDITOR='vim'

RUN /config/x/docker/kali/configure

CMD ["tmux"]

RUN /config/bin/install/k9s
RUN /config/bin/install/tusk