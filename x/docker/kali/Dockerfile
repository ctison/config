FROM debian

ENV LC_ALL='C.UTF-8'
RUN echo "LANG=$LC_ALL" > /etc/locale.conf

RUN rm -rf -- /root && mkdir -m 700 /root

RUN apt-get update
RUN apt-get install -y apt-transport-https dirmngr curl git gnupg wget

RUN curl -sS https://archive.kali.org/archive-key.asc | apt-key add -
RUN echo 'deb https://http.kali.org/kali kali-rolling main contrib non-free' > /etc/apt/sources.list.d/kali.list
RUN echo 'deb https://http.kali.org/kali kali-experimental main contrib non-free' >> /etc/apt/sources.list.d/kali.list
RUN echo 'deb https://http.kali.org/kali kali-bleeding-edge main contrib non-free' >> /etc/apt/sources.list.d/kali.list

RUN echo 'deb https://packages.cloud.google.com/apt cloud-sdk main' > /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl -sS https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

RUN echo 'deb https://deb.nodesource.com/node_12.x stretch main' > /etc/apt/sources.list.d/nodesource.list
RUN curl -sS https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -

RUN echo 'deb https://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -

# Set bash to access shell expansion
SHELL ["/bin/bash", "-c"]

ARG DEBIAN_FRONTEND=noninteractive
RUN rm -f /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install --autoremove -y \
	amass \
	apt \
	bind9-host \
	certbot \
	docker.io \
	dpkg \
	ffmpeg \
	fish \
	fping \
	git \
	google-cloud-sdk \
	htop \
	imagemagick \
	kubectl \
	libimage-exiftool-perl \
	liblz4-tool \
	locales \
	make \
	man \
	ncat \
	nodejs \
	mediainfo \
	net-tools \
	nmap \
	p7zip \
	pinfo \
	pipx \
	python3 \
	python3-pip \
	socat \
	ssh \
	tmux \
	traceroute \
	tree \
	unrar \
	vim \
	wget \
	whois \
	whowatch \
	xattr \
	yarn \
	zip

COPY ./ /config
RUN ln -sv /config ~/

ENV PATH="/root/config/bin:$PATH"
ENV EDITOR='vim'

RUN /config/x/docker/kali/configure

CMD ["tmux"]

RUN pip3 install -U pip
RUN pip3 install awscli
RUN pip3 install certbot-dns-route53
# RUN pip3 install grpcio grpcio-tools googleapis-common-protos

# Golang
RUN /config/bin/install/golang
ENV PATH="$PATH:/root/go/bin"

RUN /config/bin/install/docker-compose
RUN /config/bin/install/jq
RUN /config/bin/install/k9s
RUN /config/bin/install/tusk