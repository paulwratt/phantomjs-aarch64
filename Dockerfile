#FROM gounthar/adelie:1.0
FROM alpine:latest
# Sneak the stf executable into $PATH.
ENV PATH /app/bin:$PATH

# Export default app port, not enough for all processes but it should do
# for now.
EXPOSE 3000

# Install app requirements. Trying to optimize push speed for dependant apps
# by reducing layers as much as possible. Note that one of the final steps
# installs development files for node-gyp so that npm install won't have to
# wait for them on the first native module installation.
RUN apk update && apk upgrade 
RUN mkdir -p /opt/phantomjs
COPY . /opt/phantomjs   
RUN apk add --no-cache --virtual build-dependencies \
        alpine-sdk \
        autoconf \
        bash \
        bison \
        build-base \
        cmake \
        flex \
        fontconfig-dev \
        freetype-dev \
        g++ \
        gcc \
        git \
        gperf \
        qt5-qtwebkit-dev \
        icu-dev \
        libpng-dev \ 
        jpeg \
        make \
        nodejs \
        npm \
        openssl-dev \ 
        protobuf-dev \
        python3 \
        qt5-qtbase-dev \
        ruby \
        sqlite-dev \
        wget \
        && cd /opt/phantomjs && \
        adduser -S -s /usr/sbin/nologin -D poddingue && \
        addgroup poddingue abuild && \
        mkdir -p /var/cache/distfiles && chmod a+w /var/cache/distfiles && \
        ln -s /usr/bin/python3 /usr/bin/python
        
# Switch over to the build user.
# because of sudo: a terminal is required to read the password; either use the -S option to read from standard input or configure an askpass helper
#USER poddingue

RUN git config --global user.name "Bruno Verachten" && \
        git config --global user.email "gounthar@users.noreply.github.com" && \
        cd /opt/phantomjs && git submodule init && git submodule update && \
        cd /opt/phantomjs && ./configure && make && make install

USER poddingue
RUN /usr/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js install && cd /opt/phantomjs && ./bin/phantomjs --version

CMD phantomjs
