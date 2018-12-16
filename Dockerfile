FROM ubuntu

RUN DEBIAN_FRONTEND=noninteractive apt update && apt -y install \
  squashfs-tools \
  gcc \
  make \
  curl \
  libssl-dev \
  gdbmtool \
  libffi6 \
  ncurses-base \
  openssl \
  libreadline-dev \
  bundler \
  git

RUN mkdir /rubyc
WORKDIR /rubyc

RUN git clone https://github.com/tenebrousedge/ruby-packer.git

WORKDIR /rubyc/ruby-packer/
RUN bundle install
RUN bundle exec rake rubyc
RUN cp rubyc /usr/local/bin/

RUN mkdir /app
WORKDIR /app
COPY . .
RUN bundle install

RUN mkdir -p /tmp/enkaironment/rubyc_work_dir/__enclose_io_memfs__/local/bin \
  && cp /rubyc/ruby-packer/rubyc /tmp/enkaironment/rubyc_work_dir/__enclose_io_memfs__/local/bin/

RUN rubyc enkaironment -o enkaironment -d /tmp/enkaironment

RUN ./enkaironment
