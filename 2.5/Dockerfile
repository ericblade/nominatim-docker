FROM ubuntu:trusty
MAINTAINER winsent <pipetc@gmail.com>

# Make sure you mount this volume somewhere with a lot of space
VOLUME /var/lib/postgresql

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

# Install packages http://wiki.openstreetmap.org/wiki/Nominatim/Installation#Ubuntu.2FDebian
RUN apt-get -y update --fix-missing && \
    apt-get -o APT::Install-Recommends="false" -o APT::Install-Suggests="false" install -y build-essential libxml2-dev libpq-dev libbz2-dev libtool automake \
    libproj-dev libboost-dev libboost-system-dev libboost-filesystem-dev \
    libboost-thread-dev libexpat-dev gcc proj-bin libgeos-c1 libgeos++-dev \
    libexpat-dev php5 php-pear php5-pgsql php5-json php-db libapache2-mod-php5 \
    postgresql postgis postgresql-contrib postgresql-9.3-postgis-2.1 \
    postgresql-server-dev-9.3 curl git autoconf-archive cmake python \
    lua5.1 liblua5.1-dev libluabind-dev \
    osmosis && \
    apt-get purge -y libxcursor1 libx11-data xkb-data libxdamage1 libxfixes3 libxi6 libxcomposite1 \
    libxrandr2 libgtk2.0-0 libxrender1 libxext6 libgdk-pixbuf2.0-0 libxinerama1 libcairo2 && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* /var/tmp/* && \
    rm -rf /usr/share/doc/* && \
    rm -rf /usr/share/man/*

WORKDIR /app

# Configure postgres
RUN echo "host all  all    0.0.0.0/0  trust" >> /etc/postgresql/9.3/main/pg_hba.conf && \
    echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

# Nominatim install
ENV NOMINATIM_VERSION v2.5.1
RUN git clone --branch $NOMINATIM_VERSION --depth 1 --recursive --progress https://github.com/openstreetmap/Nominatim ./src && \
    rm -rf ./src/.git
RUN cd ./src && \
    ./autogen.sh && \
    ./configure && \
    sed -i.bak "s/createdb /createdb --template template0 /g" /app/src/utils/setup.php && \
    rm /app/src/utils/*.bak && \
    NUM_THREADS=`cat /proc/cpuinfo | grep "processor" | wc -l` && \
    make -j$NUM_THREADS && \
    cd /app/src/osm2pgsql && \
    make install && \
    strip /usr/local/bin/* && \
    rm -rf /app/src/osm2pgsql && \
    rm -rf /usr/local/share/man/* && \
    rm -rf /usr/include/*

# Nominatim create site
COPY local.php ./src/settings/local.php
RUN rm -rf /var/www/html/* && ./src/utils/setup.php --create-website /var/www/html

# Apache configure
COPY nominatim.conf /etc/apache2/sites-enabled/000-default.conf

# Create nominatim user
RUN useradd -m -p password1234 nominatim && \
    chown -R nominatim:nominatim ./src

EXPOSE 5432
EXPOSE 8080

COPY start.sh /app/start.sh

ENTRYPOINT ["/bin/bash", "/app/start.sh"]
CMD [ "" ]
