# vim:set ft=dockerfile:
FROM andrius/alpine-ruby:latest

LABEL maintainer="Andrius Kairiukstis <k@andrius.mobi>"

RUN apk add --update --no-cache \
      bash \
      bc \
      coreutils \
      curl \
      findutils \
      gawk \
      grep \
      libstdc++ \
      libxml2 \
      libxslt \
      libffi \
      ngrep \
      npm \
      pcre \
      ruby-irb \
      ruby-rdoc \
      ruby-io-console \
      sed \
      zlib \
      \
      build-base \
      git \
      libxml2-dev \
      libxslt-dev \
      libffi-dev \
      pcre-dev \
      ruby-dev \
\
&& npm install -g wscat \
\
&& rm -rf /usr/lib/ruby/gems/*/cache/* \
          /var/cache/apk/* \
          /tmp/* \
          /var/tmp/*

ENV WORKDIR /app
WORKDIR ${WORKDIR}

COPY . ${WORKDIR}/

RUN gem build asterisk-ajam \
&& gem=$(find *.gem -printf "%T@ %p\n" | sort -n | cut -d' ' -f 2- | tail -n 1) \
&& echo "Installing gem from file ${gem}" \
&& gem install ${gem} --no-rdoc --no-ri \
&& gem install libxml-to-hash ox pry --no-rdoc --no-ri \
\
&& rm -rf /usr/lib/ruby/gems/*/cache/* \
          /var/cache/apk/* \
          /tmp/* \
          /var/tmp/*

SHELL ["bash", "-c"]
