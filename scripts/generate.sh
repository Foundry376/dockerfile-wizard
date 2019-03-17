#!/bin/bash

echo "FROM buildpack-deps:$(awk -F'_' '{print tolower($2)}' <<< $LINUX_VERSION)"

echo "RUN apt-get update"

if [ ! -e $RUBY_VERSION_NUM ] ; then
    echo "RUN apt-get install -y libssl-dev && wget http://ftp.ruby-lang.org/pub/ruby/$(awk -F'.' '{ print $1"."$2 }' <<< $RUBY_VERSION_NUM)/ruby-$RUBY_VERSION_NUM.tar.gz && \
    tar -xzvf ruby-$RUBY_VERSION_NUM.tar.gz && \
    cd ruby-$RUBY_VERSION_NUM/ && \
    ./configure && \
    make -j4 && \
    make install && \
    ruby -v"
fi

if [ ! -e $NODE_VERSION_NUM ] ; then
    echo "RUN wget https://nodejs.org/dist/v$NODE_VERSION_NUM/node-v$NODE_VERSION_NUM.tar.gz && \
    tar -xzvf node-v$NODE_VERSION_NUM.tar.gz && \
    rm node-v$NODE_VERSION_NUM.tar.gz && \
    cd node-v$NODE_VERSION_NUM && \
    ./configure && \
    make -j4 && \
    make install && \
    cd .. && \
    rm -r node-v$NODE_VERSION_NUM"
fi

if [ ! -e $PYTHON_VERSION_NUM ] ; then
    echo "RUN wget https://www.python.org/ftp/python/$PYTHON_VERSION_NUM/Python-$PYTHON_VERSION_NUM.tgz && \
    tar xzf Python-$PYTHON_VERSION_NUM.tgz && \
    rm Python-$PYTHON_VERSION_NUM.tgz && \
    cd Python-$PYTHON_VERSION_NUM && \
    ./configure && \
    make install"
fi

# install bats for testing
echo "RUN git clone https://github.com/sstephenson/bats.git \
  && cd bats \
  && ./install.sh /usr/local \
  && cd .. \
  && rm -rf bats"

# install dependencies for tap-to-junit
echo "RUN perl -MCPAN -e 'install TAP::Parser'"
echo "RUN perl -MCPAN -e 'install XML::Generator'"

# install lsb-release, etc., for testing linux distro
echo "RUN apt-get update && apt-get -y install lsb-release unzip"

cat << EOF
RUN if [ \$(grep 'VERSION_ID="8"' /etc/os-release) ] ; then \\
    echo "deb http://ftp.debian.org/debian jessie-backports main" >> /etc/apt/sources.list && \\
    apt-get update && apt-get -y install -t jessie-backports xvfb phantomjs \\
; else \\
		apt-get update && apt-get -y install xvfb phantomjs \\
; fi
EOF
echo "ENV DISPLAY :99"

# Custom for Mailspring
echo "RUN sudo add-apt-repository ppa:ubuntu-toolchain-r/test"
echo "RUN sudo apt-get update"
echo "RUN apt-get -y install build-essential clang execstack fakeroot g++-4.8 git libgnome-keyring-dev libsecret-1-dev xvfb rpm libxext-dev libxtst-dev libxkbfile-dev"
echo "sh -e /etc/init.d/xvfb start"
