#!/bin/bash

sudo service postgresql start

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    --createdb)
    PBF_DATA="$2"
    shift
    shift
    ;;
    --threads)
    NUM_THREADS="$2"
    shift
    shift
    ;;
    *)
    POSITIONAL+=("$1")
    shift
    ;;
esac
done
set -- "${POSITIONAL[@]}"

if [ ! -z ${PBF_DATA+x} ]
then
    if [ -z ${NUM_THREADS+x} ]
    then
        NUM_THREADS=`cat /proc/cpuinfo | grep "processor" | wc -l`
    fi
    echo "Creating database from $PBF_DATA using $NUM_THREADS threads..."

    sudo chown postgres /var/lib/postgresql
    sudo -u postgres /usr/lib/postgresql/9.3/bin/initdb -D /var/lib/postgresql/9.3/main

    sudo service postgresql start

    curl -L $PBF_DATA --create-dirs -o /app/src/data.osm.pbf
    sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='nominatim'" | grep -q 1 || sudo -u postgres createuser -s nominatim && \
    sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='www-data'" | grep -q 1 || sudo -u postgres createuser -SDR www-data && \
    sudo -u postgres psql postgres -c "DROP DATABASE IF EXISTS nominatim" && \
    sudo -u nominatim ./src/utils/setup.php --osm-file /app/src/data.osm.pbf --all --threads $NUM_THREADS
    sudo service postgresql stop
    exit
fi

/usr/sbin/apache2ctl -D FOREGROUND
