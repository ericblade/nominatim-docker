# Nominatim Docker

100% working container for [Nominatim](https://github.com/twain47/Nominatim).

[![](https://images.microbadger.com/badges/image/mediagis/nominatim.svg)](https://microbadger.com/images/mediagis/nominatim "Get your own image badge on microbadger.com")

# Supported tags and respective `Dockerfile` links #

- [`2.5.0`, `2.5`, `latest`  (*2.5/Dockerfile*)](https://github.com/mediagis/nominatim-docker/tree/master/2.5)


Run [http://wiki.openstreetmap.org/wiki/Nominatim](http://wiki.openstreetmap.org/wiki/Nominatim) in a docker container. Clones the current master and builds it. This is always the latest version, be cautious as it may be unstable.

Uses Ubuntu 14.04 and PostgreSQL 9.3

# Country
To check that everything is set up correctly, download and load to Postgres PBF file with minimal size - Europe/Monacco (latest) from geofabrik.de.

If a different country should be used you can set `PBF_DATA` on build.

1. Clone repository

  ```
  # git clone git@github.com:mediagis/nominatim-docker.git
  # cd nominatim-docker/2.5
  ```

2. Configure incremental update in the file local.php. By default CONST_Replication_Url is configured for Monaco.
If you want a different update source, you will need to change `CONST_Replication_Url` in local.php. Documentation [here] (https://github.com/twain47/Nominatim/blob/master/docs/Import_and_update.md#updates). For example, to use the daily country extracts diffs for Gemany from geofabrik add the following:
  ```
  @define('CONST_Replication_Url', 'http://download.geofabrik.de/europe/germany-updates');
  ```
  California map updates: http://download.geofabrik.de/north-america/us/california-updates/

3. Build Container

  ```
  docker build -t nominatim .
  ```

4. Create Database
  Assume you have a volume mounted for your postgresql at /mnt/postgresql, otherwise change the path
  in -v, also change the path to the .osm.pbf file if you're intending on using a different set of
  source data.
  ```
  docker run -v /mnt/postgresql:/var/lib/postgresql --name nominatim nominatim --createdb http://download.geofabrik.de/europe/monaco-latest.osm.pbf
  ```
  California map data: http://download.geofabrik.de/north-america/us/california-latest.osm.pbf

5. Run
  Assume you have a volume mounted for your postgresql at /mnt/postgresql, otherwise change the path
  in -v.
  ```
  docker run -v /mnt/postgresql:/var/lib/postgresql --restart=always -d -p 8080:8080 nominatim
  ```
  If this succeeds, open [http://localhost:8080/](http:/localhost:8080) in a web browser

# Running

You can run Docker image from docker hub.

```
docker run -v /mnt/postgresql:/var/lib/postgresql --name nominatim mediagis/nominatim:latest --createdb http://download.geofabrik.de/europe/monaco-latest.osm.pbf
docker run -v /mnt/postgresql:/var/lib/postgresql --restart=always -d -p 8080:8080 --name nominatim mediagis/nominatim:latest
```
Service will run on [http://localhost:8080/](http:/localhost:8080)

# Update

Full documentation for Nominatim update available [here](https://github.com/twain47/Nominatim/blob/master/docs/Import_and_update.md#updates). For a list of other methods see the output of:
  ```
  docker exec -it nominatim sudo -u nominatim ./src/utils/update.php --help
  ```

The following command will keep your database constantly up to date:
  ```
  docker exec -it nominatim sudo -u nominatim ./src/utils/update.php --import-osmosis-all --no-npi
  ```
If you have imported multiple country extracts and want to keep them
up-to-date, have a look at the script in
[issue #60](https://github.com/twain47/Nominatim/issues/60).
