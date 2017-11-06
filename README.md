# Nominatim Docker - Differences from mediagis/nominatim-docker

Container for [Nominatim](https://github.com/twain47/Nominatim).

I'm building this for use in an automatic deployment system.  As such, this is custom built to fit
my requirements, and may or may not be useful to you.

This has been modified to allow for easy mounting of a separate data volume.

This has been modified to allow for building of the data on the data volume easily, using
command line parameters to docker.  I need to be able to build pieces of the nominatim dataset
repeatedly, and this is very convenient to be able to build only the chunks of data that are
required for a specific deployment.

With a collection of snapshot images stored of various data volumes, it is easy to deploy a running
instance for a specific dataset, without incurring the downsides of having a complete nominatim
database running on a host that doesn't need it -- storage space and memory requirements,
particularly.

# Country
To check that everything is set up correctly, download and load to Postgres PBF file with minimal size - Europe/Monacco (latest) from geofabrik.de.

If a different country should be used you can set `PBF_DATA` on build.

1. Clone repository

  ```
  # git clone git@github.com:ericblade/nominatim-docker.git
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
